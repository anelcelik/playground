# Screenshots and GIFs

Rendered from the real app (real fonts, sample family "Mom, Dad, Mia, Leo"),
not mock-ups.

## app-store/ — upload to App Store Connect

Eight images at **1320 × 2868**, the iPhone 6.9" size App Store Connect asks
for (iPhone 16 / 17 Pro Max). Smaller iPhones are scaled from these, so this
one set is enough. Upload them in this order:

| File | Caption |
|---|---|
| 01-log-a-visit.png | Log every playground visit in two taps |
| 02-who-went.png | Who went, and why not |
| 03-every-day.png | See how often you really get outside |
| 04-who-took-them.png | Who took them, and why nobody went |
| 05-recap.png | Your year in fresh air |
| 06-plans.png | Plans that keep score |
| 07-themes.png | Seven looks, or your own colors |
| 08-private.png | No account. No ads. No tracking. |

## plain/ — the bare app screens

The same screens without caption or frame (1320 × 2868, status bar 9:41),
for the website or a different layout. `theme-*.png` is the Today screen in
four other themes.

## gifs/ — website and README

Each flow as a looping GIF (540 × 1060, iPhone frame on yellow) and as an MP4
of the same size. The MP4 is a fraction of the size and smoother; use it on
the website (`<video autoplay muted loop playsinline>`) and the GIF where
video doesn't play (GitHub README, email).

| File | Shows |
|---|---|
| log-visit | Logging the evening visit: who went, how long, Save |
| new-plan | Creating a plan with a reminder, added to Reminders |
| themes | Switching themes, then picking your own colors |
| history | September's calendar, the stats, then the Recap |
| onboarding | First launch: names, reminders, plans, theme |

## Regenerating after UI changes

From `IOS/` (needs Flutter, ffmpeg and Google Chrome):

```sh
flutter test tool/store_media/store_media_test.dart   # renders screens + frames
python3 tool/store_media/compose.py                   # captions, frames, GIFs
```

Captions and colors are in `tool/store_media/compose.py` (`SLIDES`), the
scripted taps in `tool/store_media/store_media_test.dart`.
