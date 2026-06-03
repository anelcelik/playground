# 🌳 Playground Tracker

A simple, private family PWA to track daily playground outings — who went, when, how long, what the kids did, and why the other parent stayed home.

## Features

- 📅 **Date navigation** — day-by-day arrows, future dates locked to vacation-only
- 👨‍👩‍👧‍👦 **Family setup** — enter your own parent and kid names on first launch
- 🌅 **Morning & evening** — log each session separately with its own details
- ⏱️ **Duration chips** — 15 min → 2+ hours
- 🏷️ **Reusable activity tags** — add your own, saved in SQLite and shared across all family devices
- 💬 **Excuse field** — optional note when only one parent goes (e.g. "Work", "Sick")
- 🏖️ **Vacation days** — mark whole days without detail
- 📊 **Dashboard** — Week / Month / Year / All Time periods
- 📈 **Charts** — Morning vs Evening, Who Goes More, Top Activities (no external libs)
- ⏱️ **Stats** — average and total time per period
- 📱 **PWA** — installable on iOS and Android, tap header to force-refresh

## Stack

- Python Flask + SQLite
- Vanilla HTML / CSS / JS — zero external dependencies
- Nginx reverse proxy
- Systemd service

## Setup

### 1. Clone & install

```bash
git clone https://github.com/yourusername/playground-tracker.git /opt/playground
cd /opt/playground
pip3 install flask
```

### 2. Nginx config

```nginx
server {
    listen 80;
    server_name _;
    client_max_body_size 1m;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
    }
}
```

### 3. Systemd service

Create `/etc/systemd/system/playground.service`:

```ini
[Unit]
Description=Playground Tracker
After=network.target

[Service]
WorkingDirectory=/opt/playground
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
systemctl enable --now playground
```

### 4. First launch

Open `http://your-server-ip` and complete the one-time family setup — enter parent names and kid names. Everything is stored in `playground.db` (SQLite). No accounts, no cloud, no localStorage.

### 5. PWA install

- **iOS**: Safari → Share → Add to Home Screen
- **Android**: Chrome menu → Add to Home Screen

## Icons

Place your icon files at:
- `static/icons/icon-192.png` (192×192 px)
- `static/icons/icon-512.png` (512×512 px)

A simple green circle with 🌳 works great.

## Notes

- All data stays on your server — no external services
- Activity and excuse tags are shared across all devices via SQLite
- You can update parent/kid names by calling `POST /api/config` again (or add a settings screen)
- The app handles 2 parents and 2 kids — extend `config` table if needed
