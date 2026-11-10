// CloudKitPlugin.swift
//
// CloudKit sync bridge for Playground Tracker.
// Registered from AppDelegate.didInitializeImplicitFlutterEngine.
//
// REQUIREMENTS (already configured in this project):
//   - CloudKit capability + container iCloud.com.playground.tracker (Runner.entitlements)
//   - Background mode "remote-notification" (Info.plist) for silent change pushes
//
// SHARING BETWEEN DIFFERENT APPLE IDs:
//   - Owner calls openShareSheet() and sends the link
//   - Partner taps the URL → iOS calls SceneDelegate.windowScene(_:userDidAcceptCloudKitShareWith:)
//     which forwards to acceptShare(metadata:)
//   - Owner writes to privateCloudDatabase; partner writes to sharedCloudDatabase
//   - withZone() auto-detects which database to use

import CloudKit
import Flutter
import UIKit

@objc public class CloudKitPlugin: NSObject, FlutterPlugin {

    // MARK: - Constants

    private static let channelName   = "com.playground.tracker/cloudkit"
    private static let containerID   = "iCloud.com.playground.tracker"
    private static let zoneName      = "PlaygroundZone"
    private static let shareTitle    = "Playground Tracker"

    // UserDefaults keys
    private let kPrivateToken      = "ck_private_token"
    private let kSharedToken       = "ck_shared_token"
    private let kPrivateSubCreated = "ck_private_sub_created"
    private let kSharedSubCreated  = "ck_shared_sub_created"
    // Which zone this device syncs with ("private|<owner>" / "shared|<owner>"),
    // and what the Dart side still has to be told about a switch.
    private let kZoneKey           = "ck_zone_key"
    private let kZoneChanged       = "ck_zone_changed"
    private let kJoined            = "ck_joined_share"

    // MARK: - Properties

    private let ckContainer: CKContainer
    private var channel: FlutterMethodChannel?
    private var cachedZone: CKRecordZone?
    private var cachedDB: CKDatabase?

    // MARK: - Init

    public override init() {
        ckContainer = CKContainer(identifier: Self.containerID)
        super.init()
    }

    // MARK: - Availability

    /// False when this build was signed without the iCloud entitlement — e.g. a
    /// free-Apple-ID sideload (xtool install), which strips CloudKit. CKContainer
    /// traps (SIGTRAP) on init in that case, so AppDelegate skips registration and
    /// the Dart side sees MissingPluginException → SyncStatus.unavailable.
    /// App Store / TestFlight builds carry no embedded profile: treat as available.
    static var isAvailable: Bool {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              // The profile is a CMS envelope around a plain XML plist.
              let start = data.range(of: Data("<?xml".utf8)),
              let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex),
              let plist = try? PropertyListSerialization.propertyList(
                  from: data.subdata(in: start.lowerBound..<end.upperBound), format: nil
              ) as? [String: Any],
              let entitlements = plist["Entitlements"] as? [String: Any]
        else { return true }
        return entitlements["com.apple.developer.icloud-services"] != nil
    }

    // MARK: - FlutterPlugin registration

    /// The registered instance — AppDelegate / SceneDelegate use this for
    /// share acceptance and remote-notification handling.
    private(set) static var shared: CloudKitPlugin?

    /// A share accepted before the plugin was registered (the invitation
    /// link launched the app); accepted as soon as it is.
    private static var pendingShare: CKShare.Metadata?

    /// Entry point for SceneDelegate, whether the app was running or not.
    static func userAcceptedShare(_ metadata: CKShare.Metadata) {
        guard isAvailable else { return }
        if let plugin = shared {
            plugin.acceptShare(metadata: metadata)
        } else {
            pendingShare = metadata
        }
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = CloudKitPlugin()
        instance.channel = channel
        CloudKitPlugin.shared = instance
        registrar.addMethodCallDelegate(instance, channel: channel)
        if let metadata = pendingShare {
            pendingShare = nil
            instance.acceptShare(metadata: metadata)
        }
    }

    // MARK: - Method dispatch

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "saveEntries":
            guard let args = call.arguments as? [[String: Any]] else {
                finish(result, err("ARGS", "saveEntries requires a list of maps")); return
            }
            withZone(result) { db, zoneID in
                self.saveEntries(args, db: db, zoneID: zoneID, result: result)
            }

        case "saveRecords":
            guard let args = call.arguments as? [[String: Any]] else {
                finish(result, err("ARGS", "saveRecords requires a list of maps")); return
            }
            withZone(result) { db, zoneID in
                self.saveRecords(args, db: db, zoneID: zoneID, result: result)
            }

        case "fetchChanges":
            withZone(result) { db, zoneID in
                self.fetchChanges(db: db, zoneID: zoneID, result: result)
            }

        case "saveConfig":
            guard let args = call.arguments as? [String: Any] else {
                finish(result, err("ARGS", "saveConfig requires a map")); return
            }
            withZone(result) { db, zoneID in
                self.saveConfig(args, db: db, zoneID: zoneID, result: result)
            }

        case "ensureSubscriptions":
            withZone(result) { db, _ in
                self.ensureSubscription(db: db, result: result)
            }

        case "openShareSheet":
            withZone(result) { db, zoneID in
                self.openShareSheet(db: db, zoneID: zoneID, result: result)
            }

        case "getParticipants":
            withZone(result) { db, zoneID in
                self.getParticipants(db: db, zoneID: zoneID, result: result)
            }

        case "revokeParticipant":
            guard let participantID = call.arguments as? String else {
                finish(result, err("ARGS", "revokeParticipant requires a string")); return
            }
            withZone(result) { db, zoneID in
                self.revokeParticipant(participantID, db: db, zoneID: zoneID, result: result)
            }

        case "deleteAllData":
            deleteAllData(result)

        default:
            finish(result, FlutterMethodNotImplemented)
        }
    }

    /// All FlutterResult completions must happen on the main thread;
    /// CloudKit callbacks arrive on arbitrary queues.
    private func finish(_ result: @escaping FlutterResult, _ value: Any?) {
        DispatchQueue.main.async { result(value) }
    }

    // MARK: - Delete all data

    /// Settings › Delete all data. Deletes this family's zone from iCloud so
    /// sync can't bring the log back: the owner's private zone (its CKShare
    /// goes with it, so invited family lose access) and, for a participant,
    /// the shared zone, which leaves the share. A zone that isn't there counts
    /// as deleted; any failure (offline) is reported, so the Dart side keeps
    /// the local data too.
    private func deleteAllData(_ result: @escaping FlutterResult) {
        ckContainer.accountStatus { status, _ in
            guard status == .available else {
                self.finish(result, self.err(
                    "ICLOUD_UNAVAILABLE", "iCloud is not available (status \(status.rawValue))"))
                return
            }
            let group = DispatchGroup()
            let lock = NSLock()
            var failure: Error?
            func fail(_ error: Error) {
                lock.lock(); failure = failure ?? error; lock.unlock()
            }
            for db in [self.ckContainer.privateCloudDatabase, self.ckContainer.sharedCloudDatabase] {
                group.enter()
                db.fetchAllRecordZones { zones, error in
                    if let error = error {
                        fail(error)
                        group.leave()
                        return
                    }
                    let ids = (zones ?? []).map(\.zoneID).filter { $0.zoneName == Self.zoneName }
                    guard !ids.isEmpty else {
                        group.leave()
                        return
                    }
                    let op = CKModifyRecordZonesOperation(
                        recordZonesToSave: nil, recordZoneIDsToDelete: ids)
                    op.modifyRecordZonesResultBlock = { outcome in
                        if case .failure(let error) = outcome { fail(error) }
                        group.leave()
                    }
                    db.add(op)
                }
            }
            group.notify(queue: .main) {
                if let error = failure {
                    self.finish(result, self.err("DELETE_FAILED", error.localizedDescription))
                    return
                }
                for key in [self.kPrivateToken, self.kSharedToken,
                            self.kZoneKey, self.kZoneChanged, self.kJoined] {
                    UserDefaults.standard.removeObject(forKey: key)
                }
                self.cachedZone = nil
                self.cachedDB = nil
                self.finish(result, nil)
            }
        }
    }

    // MARK: - Zone discovery / creation

    /// Finds the PlaygroundZone in private or shared database, creating it if
    /// needed. On any failure the FlutterResult is completed with an error so
    /// the Dart side never hangs (e.g. when not signed into iCloud).
    private func withZone(
        _ result: @escaping FlutterResult,
        action: @escaping (CKDatabase, CKRecordZone.ID) -> Void
    ) {
        if let zone = cachedZone, let db = cachedDB {
            action(db, zone.zoneID)
            return
        }
        ckContainer.accountStatus { status, _ in
            guard status == .available else {
                self.finish(result, self.err(
                    "ICLOUD_UNAVAILABLE",
                    "iCloud is not available (status \(status.rawValue)). " +
                    "Sign into iCloud in Settings to enable sync."
                ))
                return
            }
            self.discoverOrCreateZone { zone, db in
                guard let zone = zone, let db = db else {
                    self.finish(result, self.err(
                        "NO_ZONE", "Could not find or create the CloudKit zone"))
                    return
                }
                self.noteZone(zone, db: db)
                self.cachedZone = zone
                self.cachedDB   = db
                action(db, zone.zoneID)
            }
        }
    }

    /// Remembers which zone this device syncs with. When it is a different
    /// one than last time (joined a family's share, or lost access to it and
    /// fell back to the own zone), the change tokens are useless and the new
    /// zone has none of this device's records: the next fetchChanges tells
    /// the Dart side, which pushes everything again.
    private func noteZone(_ zone: CKRecordZone, db: CKDatabase) {
        let shared = db.databaseScope == .shared
        let key = (shared ? "shared|" : "private|") + zone.zoneID.ownerName
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: kZoneKey) != key else { return }
        defaults.set(key, forKey: kZoneKey)
        defaults.set(true, forKey: kZoneChanged)
        defaults.set(shared, forKey: kJoined)
        defaults.removeObject(forKey: kPrivateToken)
        defaults.removeObject(forKey: kSharedToken)
    }

    /// The zone this device was using is gone: the owner deleted the log or
    /// removed this person from the share. Forget it, so the next sync looks
    /// again instead of failing against the old zone until the app restarts.
    private func forgetZoneIfGone(_ error: Error) {
        guard let ck = error as? CKError else { return }
        let gone: (CKError) -> Bool = { $0.code == .zoneNotFound || $0.code == .userDeletedZone }
        let partial = (ck.partialErrorsByItemID ?? [:]).values.compactMap { $0 as? CKError }
        guard gone(ck) || partial.contains(where: gone) else { return }
        cachedZone = nil
        cachedDB = nil
    }

    private func discoverOrCreateZone(
        completion: @escaping (CKRecordZone?, CKDatabase?) -> Void
    ) {
        // 1. Shared database first: someone who accepted a family's share
        //    syncs with that log, even though their own app created a private
        //    zone the first time it was opened. A failed lookup stops here
        //    (no guessing: picking the wrong zone would move the data).
        let sharedDB = ckContainer.sharedCloudDatabase
        let privateDB = ckContainer.privateCloudDatabase
        sharedDB.fetchAllRecordZones { sharedZones, sharedError in
            if let error = sharedError {
                print("[CloudKit] shared zone lookup failed: \(error)")
                completion(nil, nil)
                return
            }
            if let zone = sharedZones?.first(where: { $0.zoneID.zoneName == Self.zoneName }) {
                completion(zone, sharedDB)
                return
            }
            // 2. The own private zone (owner, or not sharing at all)
            privateDB.fetchAllRecordZones { zones, error in
                if let error = error {
                    print("[CloudKit] private zone lookup failed: \(error)")
                    completion(nil, nil)
                    return
                }
                if let zone = zones?.first(where: { $0.zoneID.zoneName == Self.zoneName }) {
                    completion(zone, privateDB)
                    return
                }
                // 3. No zone anywhere → create it (this device becomes owner)
                self.createZone(completion: completion)
            }
        }
    }

    private func createZone(completion: @escaping (CKRecordZone?, CKDatabase?) -> Void) {
        let zoneID = CKRecordZone.ID(
            zoneName: Self.zoneName,
            ownerName: CKCurrentUserDefaultName
        )
        let zone = CKRecordZone(zoneID: zoneID)
        let op = CKModifyRecordZonesOperation(
            recordZonesToSave: [zone],
            recordZoneIDsToDelete: nil
        )
        op.modifyRecordZonesResultBlock = { result in
            switch result {
            case .success:
                completion(zone, self.ckContainer.privateCloudDatabase)
            case .failure(let error):
                print("[CloudKit] createZone failed: \(error)")
                completion(nil, nil)
            }
        }
        ckContainer.privateCloudDatabase.add(op)
    }

    // MARK: - saveEntry / saveEntries

    private func entryRecord(_ map: [String: Any], zoneID: CKRecordZone.ID) -> CKRecord? {
        guard let uuid = map["uuid"] as? String, !uuid.isEmpty else { return nil }

        let recordID = CKRecord.ID(recordName: "entry_\(uuid)", zoneID: zoneID)
        let record   = CKRecord(recordType: "PlaygroundEntry", recordID: recordID)

        record["uuid"]          = uuid as CKRecordValue
        record["date"]          = (map["date"]  as? String ?? "") as CKRecordValue
        record["shift"]         = (map["shift"] as? String ?? "morning") as CKRecordValue
        record["user"]          = (map["user"]  as? String ?? "") as CKRecordValue
        record["vacation"]      = ((map["vacation"]      as? Bool ?? false) ? 1 : 0) as CKRecordValue
        record["no_playground"] = ((map["no_playground"] as? Bool ?? false) ? 1 : 0) as CKRecordValue
        record["last_modified"] = (map["last_modified"] as? Int ?? 0) as CKRecordValue
        record["is_deleted"]    = ((map["is_deleted"]   as? Bool ?? false) ? 1 : 0) as CKRecordValue

        if let created = map["created_at"] as? String, !created.isEmpty {
            record["created_at"] = created as CKRecordValue
        }
        // Always written, "" for none: with .changedKeys an unset key would
        // keep its old value on the server, so clearing a field on one phone
        // would never reach the other.
        for key in ["duration", "kids", "activities", "excuse", "start_time", "end_time"] {
            record[key] = (map[key] as? String ?? "") as CKRecordValue
        }

        return record
    }

    private func saveEntries(
        _ maps: [[String: Any]],
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        result: @escaping FlutterResult
    ) {
        let records = maps.compactMap { entryRecord($0, zoneID: zoneID) }
        guard !records.isEmpty else { finish(result, nil); return }

        saveRecordsInChunks(records, db: db) { error in
            if let error = error {
                print("[CloudKit] saveEntries error: \(error)")
                self.finish(result, self.err("SAVE_FAILED", error.localizedDescription))
            } else {
                self.finish(result, nil)
            }
        }
    }

    // MARK: - saveRecords (plans and their days)

    /// Records whose fields the Dart side decides: each map has "type",
    /// "name" (the record name) and "fields" (text and whole numbers).
    private func saveRecords(
        _ maps: [[String: Any]],
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        result: @escaping FlutterResult
    ) {
        let records: [CKRecord] = maps.compactMap { map in
            guard let type = map["type"] as? String, !type.isEmpty,
                  let name = map["name"] as? String, !name.isEmpty,
                  let fields = map["fields"] as? [String: Any] else { return nil }
            let record = CKRecord(
                recordType: type, recordID: CKRecord.ID(recordName: name, zoneID: zoneID))
            for (key, value) in fields {
                if let text = value as? String {
                    record[key] = text as CKRecordValue
                } else if let number = value as? NSNumber {
                    record[key] = number.int64Value as CKRecordValue
                }
            }
            return record
        }
        guard !records.isEmpty else { finish(result, nil); return }

        saveRecordsInChunks(records, db: db) { error in
            if let error = error {
                print("[CloudKit] saveRecords error: \(error)")
                self.forgetZoneIfGone(error)
                self.finish(result, self.err("SAVE_FAILED", error.localizedDescription))
            } else {
                self.finish(result, nil)
            }
        }
    }

    /// The reverse of saveRecords: every text and whole-number field.
    private func fieldsToMap(_ record: CKRecord) -> [String: Any] {
        var m: [String: Any] = [:]
        for key in record.allKeys() {
            if let text = record[key] as? String {
                m[key] = text
            } else if let number = record[key] as? Int64 {
                m[key] = number
            }
        }
        return m
    }

    /// Saves records in batches (CloudKit caps one operation at 400 records).
    /// savePolicy .changedKeys overwrites by key without needing the server
    /// change tag — required because we build fresh CKRecord objects, and the
    /// default .ifServerRecordUnchanged would reject every update.
    private func saveRecordsInChunks(
        _ records: [CKRecord],
        db: CKDatabase,
        completion: @escaping (Error?) -> Void
    ) {
        let chunk = Array(records.prefix(200))
        let rest  = Array(records.dropFirst(200))

        let op = CKModifyRecordsOperation(recordsToSave: chunk, recordIDsToDelete: nil)
        op.savePolicy = .changedKeys
        op.qualityOfService = .userInitiated
        op.modifyRecordsResultBlock = { opResult in
            switch opResult {
            case .success:
                if rest.isEmpty {
                    completion(nil)
                } else {
                    self.saveRecordsInChunks(rest, db: db, completion: completion)
                }
            case .failure(let error):
                completion(error)
            }
        }
        db.add(op)
    }

    private func nonEmpty(_ s: String?) -> String? {
        guard let s = s, !s.isEmpty else { return nil }
        return s
    }

    // MARK: - fetchChanges

    /// Fetches only records changed since the last CKServerChangeToken (delta sync).
    /// Returns a JSON string compatible with DatabaseHelper.mergeFromJson().
    /// Handles expired change tokens (clears the token and retries once from scratch)
    /// and server-side record deletions (reported as "deleted_uuids").
    private func fetchChanges(
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        retryOnExpiredToken: Bool = true,
        result: @escaping FlutterResult
    ) {
        let tokenKey = db.databaseScope == .private ? kPrivateToken : kSharedToken
        let prevToken: CKServerChangeToken? = {
            guard let data = UserDefaults.standard.data(forKey: tokenKey) else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: CKServerChangeToken.self, from: data
            )
        }()

        var changedEntries: [[String: Any]] = []
        var deletedUuids: [String]          = []
        var changedPlans: [[String: Any]]   = []
        var changedPlanLogs: [[String: Any]] = []
        var configMap: [String: Any]?       = nil
        var newToken: CKServerChangeToken?  = nil
        var zoneError: Error?               = nil

        var zoneCfg = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        zoneCfg.previousServerChangeToken = prevToken

        let op = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneID],
            configurationsByRecordZoneID: [zoneID: zoneCfg]
        )
        op.qualityOfService = .userInitiated

        op.recordWasChangedBlock = { _, recordResult in
            guard case .success(let record) = recordResult else { return }
            if record.recordType == "PlaygroundEntry" {
                changedEntries.append(self.entryToMap(record))
            } else if record.recordType == "FamilyConfig" {
                configMap = self.configToMap(record)
            } else if record.recordType == "PlaygroundPlan" {
                changedPlans.append(self.fieldsToMap(record))
            } else if record.recordType == "PlaygroundPlanLog" {
                changedPlanLogs.append(self.fieldsToMap(record))
            }
        }

        op.recordWithIDWasDeletedBlock = { recordID, _ in
            // A record hard-deleted on the server → propagate as a soft delete
            let name = recordID.recordName
            if name.hasPrefix("entry_") {
                deletedUuids.append(String(name.dropFirst("entry_".count)))
            }
        }

        op.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            newToken = token
        }

        op.recordZoneFetchResultBlock = { _, fetchResult in
            switch fetchResult {
            case .success(let (token, _, _)):
                newToken = token
            case .failure(let error):
                zoneError = error
            }
        }

        op.fetchRecordZoneChangesResultBlock = { opResult in
            var failure: Error? = zoneError
            if case .failure(let error) = opResult { failure = error }

            if let error = failure {
                // Expired token → server can no longer compute the delta.
                // Drop the token and re-fetch everything once.
                if retryOnExpiredToken,
                   let ck = error as? CKError, ck.code == .changeTokenExpired {
                    UserDefaults.standard.removeObject(forKey: tokenKey)
                    self.fetchChanges(db: db, zoneID: zoneID,
                                      retryOnExpiredToken: false, result: result)
                    return
                }
                print("[CloudKit] fetchChanges error: \(error)")
                self.forgetZoneIfGone(error)
                self.finish(result, FlutterError(
                    code: "FETCH_FAILED",
                    message: error.localizedDescription,
                    details: nil
                ))
                return
            }

            // Persist new token
            if let token = newToken,
               let data = try? NSKeyedArchiver.archivedData(
                   withRootObject: token, requiringSecureCoding: true
               ) {
                UserDefaults.standard.set(data, forKey: tokenKey)
            }

            // A switch of zone is reported once (see noteZone).
            let defaults = UserDefaults.standard
            let zoneChanged = defaults.bool(forKey: self.kZoneChanged)
            let joined = defaults.bool(forKey: self.kJoined)
            defaults.removeObject(forKey: self.kZoneChanged)
            defaults.removeObject(forKey: self.kJoined)

            // Build payload compatible with DatabaseHelper.mergeFromJson
            let payload: [String: Any] = [
                "zone_changed":      zoneChanged,
                "joined":            joined,
                "entries":           changedEntries,
                "deleted_uuids":     deletedUuids,
                "plans":             changedPlans,
                "plan_logs":         changedPlanLogs,
                "parents":           configMap?["parents"] ?? [],
                "kids":              configMap?["kids"]    ?? [],
                "activity_tags":     configMap?["activity_tags"] ?? [],
                "excuse_tags":       configMap?["excuse_tags"]   ?? [],
                "family_updated_at": configMap?["family_updated_at"] ?? 0,
                "exported_at":       Int64(Date().timeIntervalSince1970 * 1000),
            ]

            guard let data = try? JSONSerialization.data(withJSONObject: payload),
                  let str  = String(data: data, encoding: .utf8) else {
                self.finish(result, "{}")
                return
            }
            self.finish(result, str)
        }

        db.add(op)
    }

    // MARK: - saveConfig

    private func saveConfig(
        _ map: [String: Any],
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        result: @escaping FlutterResult
    ) {
        let recordID = CKRecord.ID(recordName: "family_config", zoneID: zoneID)
        let record   = CKRecord(recordType: "FamilyConfig", recordID: recordID)

        func jsonString(_ value: Any?) -> String? {
            guard let v = value,
                  let data = try? JSONSerialization.data(withJSONObject: v),
                  let str  = String(data: data, encoding: .utf8) else { return nil }
            return str
        }

        if let s = jsonString(map["parents"])        { record["parents_json"]       = s as CKRecordValue }
        if let s = jsonString(map["kids"])           { record["kids_json"]           = s as CKRecordValue }
        if let s = jsonString(map["activity_tags"])  { record["activity_tags_json"]  = s as CKRecordValue }
        if let s = jsonString(map["excuse_tags"])    { record["excuse_tags_json"]    = s as CKRecordValue }
        if let ts = map["family_updated_at"] as? Int { record["updated_at"] = ts as CKRecordValue }

        // .changedKeys: overwrite without the server change tag (see saveRecordsInChunks)
        let op = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        op.savePolicy = .changedKeys
        op.qualityOfService = .userInitiated
        op.modifyRecordsResultBlock = { opResult in
            switch opResult {
            case .success:
                self.finish(result, nil)
            case .failure(let error):
                print("[CloudKit] saveConfig error: \(error)")
                self.finish(result, self.err("SAVE_FAILED", error.localizedDescription))
            }
        }
        db.add(op)
    }

    // MARK: - Subscriptions (silent push on remote changes)

    /// Creates a CKDatabaseSubscription so the server sends a silent push when
    /// the other device changes data. Best-effort: polling remains the fallback,
    /// so failures here are not surfaced as errors.
    private func ensureSubscription(db: CKDatabase, result: @escaping FlutterResult) {
        let isShared = db.databaseScope == .shared
        let flagKey  = isShared ? kSharedSubCreated : kPrivateSubCreated
        guard !UserDefaults.standard.bool(forKey: flagKey) else {
            finish(result, nil); return
        }

        let sub = CKDatabaseSubscription(
            subscriptionID: isShared ? "pg-shared-changes" : "pg-private-changes")
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true   // silent push — no user permission needed
        sub.notificationInfo = info

        let op = CKModifySubscriptionsOperation(
            subscriptionsToSave: [sub], subscriptionIDsToDelete: nil)
        op.modifySubscriptionsResultBlock = { opResult in
            switch opResult {
            case .success:
                UserDefaults.standard.set(true, forKey: flagKey)
            case .failure(let error):
                print("[CloudKit] ensureSubscription error: \(error)")
            }
            self.finish(result, nil)
        }
        db.add(op)
    }

    /// Called by AppDelegate when a CloudKit silent push arrives,
    /// and after a share is accepted — tells Dart to sync now.
    public func notifyRemoteChange() {
        DispatchQueue.main.async {
            self.channel?.invokeMethod("remoteChange", arguments: nil)
        }
    }

    // MARK: - Share acceptance (called from SceneDelegate)

    public func acceptShare(metadata: CKShare.Metadata) {
        let op = CKAcceptSharesOperation(shareMetadatas: [metadata])
        op.acceptSharesResultBlock = { result in
            switch result {
            case .success:
                // Invalidate cache so the shared database is discovered on next
                // sync, reset the shared-DB change token, and sync immediately.
                self.cachedZone = nil
                self.cachedDB   = nil
                UserDefaults.standard.removeObject(forKey: self.kSharedToken)
                print("[CloudKit] Share accepted successfully")
                self.notifyRemoteChange()
            case .failure(let error):
                print("[CloudKit] Accept share error: \(error)")
            }
        }
        ckContainer.add(op)
    }

    // MARK: - The zone's share

    /// A zone-wide share always has this record name; CloudKit picks it,
    /// the app cannot choose its own.
    private static func shareID(in zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: zoneID)
    }

    /// The zone's share, created (invitation-only) if there is none yet.
    private func fetchOrCreateShare(
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        completion: @escaping (CKShare?, Error?) -> Void
    ) {
        db.fetch(withRecordID: Self.shareID(in: zoneID)) { existing, error in
            if let share = existing as? CKShare {
                completion(share, nil)
                return
            }
            if let ck = error as? CKError, ck.code != .unknownItem {
                completion(nil, ck)
                return
            }

            let share = CKShare(recordZoneID: zoneID)
            share[CKShare.SystemFieldKey.title] = Self.shareTitle as CKRecordValue
            share.publicPermission = .none  // invitation-only
            var saved: CKShare? = nil

            let op = CKModifyRecordsOperation(recordsToSave: [share], recordIDsToDelete: nil)
            op.qualityOfService = .userInitiated
            op.perRecordSaveBlock = { _, outcome in
                if case .success(let record) = outcome { saved = record as? CKShare }
            }
            op.modifyRecordsResultBlock = { opResult in
                switch opResult {
                case .success:
                    completion(saved ?? share, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
            db.add(op)
        }
    }

    // MARK: - openShareSheet

    /// Presents Apple's native UICloudSharingController.
    /// Handles invite, participant management, and revoke — all in Apple's own UI.
    private func openShareSheet(
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        result: @escaping FlutterResult
    ) {
        guard db.databaseScope == .private else {
            finish(result, err("NOT_OWNER", "Only the share owner can manage the share"))
            return
        }

        fetchOrCreateShare(db: db, zoneID: zoneID) { share, error in
            DispatchQueue.main.async {
                guard let share = share else {
                    print("[CloudKit] openShareSheet error: \(String(describing: error))")
                    result(self.err("SHARE_FAILED",
                                    error?.localizedDescription ?? "Could not prepare the share"))
                    return
                }
                let controller = UICloudSharingController(
                    share: share, container: self.ckContainer)
                controller.availablePermissions = [.allowReadWrite, .allowPrivate]
                controller.delegate = self

                let window = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
                var top = window?.rootViewController
                while let presented = top?.presentedViewController {
                    top = presented
                }
                guard let presenter = top else {
                    result(self.err("NO_VC", "Could not find a view controller"))
                    return
                }
                presenter.present(controller, animated: true)
                result(nil)
            }
        }
    }

    // MARK: - getParticipants

    private func getParticipants(
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        result: @escaping FlutterResult
    ) {
        let shareID = Self.shareID(in: zoneID)

        db.fetch(withRecordID: shareID) { record, error in
            guard let share = record as? CKShare else {
                // No share exists yet — just return owner-only list
                self.finish(result, [[
                    "id": "",
                    "name": "",
                    "email": "",
                    "role": "owner",
                    "status": "accepted",
                    "me": true,
                ]])
                return
            }

            let participants: [[String: Any]] = share.participants.map { p in
                let nameComponents = p.userIdentity.nameComponents
                // "" when iCloud gives no name; the Dart side has the wording.
                let name = [nameComponents?.givenName, nameComponents?.familyName]
                    .compactMap { $0 }.joined(separator: " ")
                // The owner's database is the private one; a participant sees
                // their own identity under the current-user record name.
                let me = db.databaseScope == .private
                    ? p.role == .owner
                    : p.userIdentity.userRecordID?.recordName == CKCurrentUserDefaultName
                let email = p.userIdentity.lookupInfo?.emailAddress ?? ""
                let role  = p.role == .owner ? "owner" : "participant"
                let status: String = {
                    switch p.acceptanceStatus {
                    case .accepted:  return "accepted"
                    case .pending:   return "pending"
                    case .removed:   return "removed"
                    default:         return "unknown"
                    }
                }()
                return [
                    "id":     p.userIdentity.userRecordID?.recordName ?? "",
                    "name":   name,
                    "email":  email,
                    "role":   role,
                    "status": status,
                    "me":     me,
                ]
            }
            self.finish(result, participants)
        }
    }

    // MARK: - revokeParticipant

    private func revokeParticipant(
        _ participantRecordName: String,
        db: CKDatabase,
        zoneID: CKRecordZone.ID,
        result: @escaping FlutterResult
    ) {
        let shareID = Self.shareID(in: zoneID)

        db.fetch(withRecordID: shareID) { record, error in
            guard let share = record as? CKShare else {
                self.finish(result, self.err("NO_SHARE", "Share not found")); return
            }
            guard let participant = share.participants.first(where: {
                $0.userIdentity.userRecordID?.recordName == participantRecordName
            }) else {
                self.finish(result, self.err("NOT_FOUND", "Participant not found")); return
            }

            share.removeParticipant(participant)

            let op = CKModifyRecordsOperation(recordsToSave: [share])
            op.savePolicy = .changedKeys
            op.modifyRecordsResultBlock = { opResult in
                switch opResult {
                case .success:
                    self.finish(result, nil)
                case .failure(let error):
                    self.finish(result, self.err("REVOKE_FAILED", error.localizedDescription))
                }
            }
            db.add(op)
        }
    }

    // MARK: - Record → Map helpers

    private func entryToMap(_ record: CKRecord) -> [String: Any] {
        var m: [String: Any] = [:]
        m["uuid"]          = record["uuid"]          as? String ?? ""
        m["date"]          = record["date"]          as? String ?? ""
        m["shift"]         = record["shift"]         as? String ?? "morning"
        m["user"]          = record["user"]          as? String ?? ""
        m["vacation"]      = (record["vacation"]      as? Int64 ?? 0) == 1
        m["no_playground"] = (record["no_playground"] as? Int64 ?? 0) == 1
        m["duration"]      = nonEmpty(record["duration"]   as? String)
        m["kids"]          = nonEmpty(record["kids"]       as? String)
        m["activities"]    = nonEmpty(record["activities"] as? String)
        m["excuse"]        = nonEmpty(record["excuse"]     as? String)
        m["start_time"]    = nonEmpty(record["start_time"] as? String)
        m["end_time"]      = nonEmpty(record["end_time"]   as? String)
        m["last_modified"] = record["last_modified"] as? Int64 ?? 0
        m["is_deleted"]    = (record["is_deleted"]   as? Int64 ?? 0) == 1
        m["created_at"]    = record["created_at"]    as? String
        return m
    }

    private func configToMap(_ record: CKRecord) -> [String: Any] {
        var m: [String: Any] = [:]

        func parseJSON(_ key: String) -> Any? {
            guard let str  = record[key] as? String,
                  let data = str.data(using: .utf8) else { return nil }
            return try? JSONSerialization.jsonObject(with: data)
        }

        m["parents"]           = parseJSON("parents_json")       ?? []
        m["kids"]              = parseJSON("kids_json")          ?? []
        m["activity_tags"]     = parseJSON("activity_tags_json") ?? []
        m["excuse_tags"]       = parseJSON("excuse_tags_json")   ?? []
        m["family_updated_at"] = record["updated_at"] as? Int64 ?? 0
        return m
    }

    // MARK: - Helpers

    private func err(_ code: String, _ msg: String) -> FlutterError {
        FlutterError(code: code, message: msg, details: nil)
    }
}

// MARK: - UICloudSharingControllerDelegate

extension CloudKitPlugin: UICloudSharingControllerDelegate {

    public func cloudSharingController(
        _ csc: UICloudSharingController,
        failedToSaveShareWithError error: Error
    ) {
        print("[CloudKit] UICloudSharingController save failed: \(error)")
    }

    public func cloudSharingControllerDidSaveShare(
        _ csc: UICloudSharingController
    ) {
        // Invalidate cached zone so the next sync re-discovers participants
        cachedZone = nil
        cachedDB   = nil
    }

    public func cloudSharingControllerDidStopSharing(
        _ csc: UICloudSharingController
    ) {
        cachedZone = nil
        cachedDB   = nil
    }

    public func itemTitle(for csc: UICloudSharingController) -> String? {
        Self.shareTitle
    }

    public func itemThumbnailData(
        for csc: UICloudSharingController
    ) -> Data? { nil }

    public func itemType(for csc: UICloudSharingController) -> String? { nil }
}
