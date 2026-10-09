# Web page preparation

The text for the Playground Tracker website, one file per page. Text only: no
styling, no layout. Build the pages from these whenever the site is made.

## Pages Apple needs

| Page | File | Needed for | Required? |
| --- | --- | --- | --- |
| Privacy policy | privacy-policy.md | App Store Connect "Privacy Policy URL" | Yes, for every app |
| Support | support.md | App Store Connect "Support URL" | Yes |
| Home | index.md | App Store Connect "Marketing URL" | No, optional |

app-store-connect.md is not a web page: it holds the texts to paste into App
Store Connect when the app is submitted (subtitle, description, keywords,
review notes and so on).

## Placeholders to fill in

- `{{SUPPORT_EMAIL}}`: the address people write to for help.
- `{{APP_STORE_LINK}}`: the app's App Store link, known once the app is live.
- `{{PRICE}}`: the price you pick in App Store Connect.
- `{{YOUR_NAME}}`: your legal name. Individual developer accounts show it as
  the seller on the App Store.

## Keep the privacy policy in sync

privacy-policy.md is the same text the app shows under Settings > Privacy
(IOS/lib/screens/privacy_screen.dart). When one changes, change the other,
and update its "Effective" date.
