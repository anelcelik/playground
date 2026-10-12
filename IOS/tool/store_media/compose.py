#!/usr/bin/env python3
"""App Store screenshots and website GIFs from the frames that
store_media_test.dart renders.

    python3 tool/store_media/compose.py            # everything
    python3 tool/store_media/compose.py shots      # App Store images only
    python3 tool/store_media/compose.py gifs       # GIFs / MP4s only

Captions are laid out in HTML and photographed with headless Chrome; the
GIFs are assembled with ffmpeg. Output: ../webpagepreparation/screenshots/.
"""
import shutil
import subprocess
import sys
from pathlib import Path

IOS = Path(__file__).resolve().parents[2]
SRC = IOS / 'build/store_media'
OUT = IOS.parent / 'webpagepreparation/screenshots'
TMP = SRC / 'compose'
FONTS = IOS / 'assets/fonts'
CHROME = shutil.which('google-chrome-stable') or shutil.which('chromium')

YELLOW, GREEN, ORANGE, CREAM = '#FFB31F', '#12443A', '#F0512E', '#FFF4D6'

# (file, background, headline colour, sub colour, headline, sub, screens)
SLIDES = [
    ('01-log-a-visit', YELLOW, GREEN, GREEN,
     'Log every playground visit in two taps',
     'Morning or evening: who went, which kids, how long.',
     ['01-today']),
    ('02-who-went', GREEN, YELLOW, CREAM,
     'Who went, and why not',
     'Rain, sick, busy, or your own words.',
     ['02-visit']),
    ('03-every-day', CREAM, GREEN, GREEN,
     'See how often you really get outside',
     'One square per day: both parents, one, or nobody.',
     ['03-month']),
    ('04-who-took-them', ORANGE, '#FFFFFF', '#FFFFFF',
     'Who took them, and why nobody went',
     'Visits per parent and child, reasons and time outside.',
     ['04-stats']),
    ('05-recap', YELLOW, GREEN, GREEN,
     'Your year in fresh air',
     'Streaks, top activities and who went the most.',
     ['05-recap']),
    ('06-plans', GREEN, YELLOW, CREAM,
     'Plans that keep score',
     'Football, swimming, birthdays: done, skipped or missed. '
     'One tap to Calendar or Reminders.',
     ['06-plan']),
    ('07-themes', CREAM, GREEN, GREEN,
     'Seven looks, or your own colors',
     'Light, dark, high contrast, or pick every color yourself.',
     ['theme-modernist-light', 'theme-swing-dark', 'theme-my-colors']),
    ('08-private', YELLOW, GREEN, GREEN,
     'No account. No ads. No tracking.',
     'Your log stays on your iPhone and in your own iCloud.',
     ['08-welcome']),
]

FONT_CSS = '\n'.join(
    f"@font-face {{ font-family: Archivo; font-weight: {w}; "
    f"src: url('{(FONTS / f'Archivo-{n}.ttf').as_uri()}'); }}"
    for w, n in [(400, 'Regular'), (500, 'Medium'), (600, 'SemiBold'),
                 (700, 'Bold'), (800, 'ExtraBold')])


def phone_css(screen_w):
    """An iPhone 16 Pro Max-like frame around a screen [screen_w] px wide."""
    pt = screen_w / 440            # px per point
    bezel = round(11 * pt)
    radius = round(55 * pt)
    return f"""
.phone {{ position: absolute; width: {screen_w}px;
  height: {round(screen_w * 2868 / 1320)}px; padding: {bezel}px;
  border-radius: {radius + bezel}px; background: #141414;
  box-shadow: 0 0 0 {max(2, round(1.3 * pt))}px #4a4a4a,
              0 {round(18 * pt)}px {round(40 * pt)}px rgba(0,0,0,.28); }}
.phone img {{ display: block; width: 100%; height: 100%;
  border-radius: {radius}px; }}
.phone .island {{ position: absolute; left: 50%;
  top: {bezel + round(11 * pt)}px; width: {round(126 * pt)}px;
  height: {round(37 * pt)}px; margin-left: -{round(63 * pt)}px;
  border-radius: {round(19 * pt)}px; background: #000; }}
"""


def phone_html(img, left, top, extra=''):
    return f"""<div class="phone" style="left:{left}px; top:{top}px; {extra}">
  <img src="{img.as_uri()}"><div class="island"></div>
</div>"""


def slide_html(bg, head, sub_col, headline, sub, screens):
    W, H = 1320, 2868
    if len(screens) == 1:
        sw = 960
        phones = phone_html(SRC / f'screens/{screens[0]}.png',
                            (W - sw) // 2 - 22, 640)
        css = phone_css(sw)
    else:
        sw = 600
        css = phone_css(sw)
        left, mid, right = (SRC / f'screens/{s}.png' for s in screens)
        phones = (
            phone_html(left, 40, 1050, 'transform: rotate(-7deg);') +
            phone_html(right, W - sw - 84, 1050, 'transform: rotate(7deg);') +
            phone_html(mid, (W - sw) // 2 - 22, 860, 'z-index: 2;'))
    return f"""<!doctype html><html><head><meta charset="utf-8"><style>
{FONT_CSS}
html, body {{ margin: 0; width: {W}px; height: {H}px; overflow: hidden;
  background: {bg}; font-family: Archivo; -webkit-font-smoothing: antialiased; }}
.cap {{ position: absolute; left: 96px; right: 96px; top: 150px; }}
h1 {{ margin: 0; font-weight: 800; font-size: 118px; line-height: 1.0;
  letter-spacing: -3px; color: {head}; }}
p {{ margin: 34px 0 0; font-weight: 500; font-size: 46px; line-height: 1.3;
  color: {sub_col}; opacity: .88; }}
{css}
</style></head><body>
<div class="cap"><h1>{headline}</h1><p>{sub}</p></div>
{phones}
</body></html>"""


def chrome_shot(html, out, w, h, transparent=False):
    page = TMP / (out.stem + '.html')
    page.write_text(html)
    args = [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
            '--force-device-scale-factor=1', f'--window-size={w},{h}',
            '--allow-file-access-from-files', f'--screenshot={out}']
    if transparent:
        args.append('--default-background-color=00000000')
    subprocess.run(args + [page.as_uri()], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def shots():
    dest = OUT / 'app-store'
    dest.mkdir(parents=True, exist_ok=True)
    for name, bg, head, sub_col, headline, sub, screens in SLIDES:
        out = dest / f'{name}.png'
        chrome_shot(slide_html(bg, head, sub_col, headline, sub, screens),
                    out, 1320, 2868)
        print('  ', out.relative_to(IOS.parent))
    raw = OUT / 'plain'
    raw.mkdir(parents=True, exist_ok=True)
    for png in sorted((SRC / 'screens').glob('*.png')):
        shutil.copy(png, raw / png.name)


# ── GIFs ─────────────────────────────────────────────────────────────

GW, GH = 540, 1060          # GIF canvas
SW = 440                    # screen width inside it (1 px per point)
SX, SY = (GW - SW) // 2, 52


def gif_frame_overlay():
    """Yellow card with an iPhone frame whose screen is a transparent hole."""
    pt = SW / 440
    bezel, radius = round(11 * pt), round(55 * pt)
    sh = round(SW * 2868 / 1320)
    html = f"""<!doctype html><html><head><style>
html, body {{ margin: 0; width: {GW}px; height: {GH}px; background: transparent; }}
svg {{ position: absolute; left: 0; top: 0; }}
</style></head><body>
<svg width="{GW}" height="{GH}" xmlns="http://www.w3.org/2000/svg">
  <defs><mask id="hole">
    <rect width="{GW}" height="{GH}" fill="#fff"/>
    <rect x="{SX}" y="{SY}" width="{SW}" height="{sh}" rx="{radius}" fill="#000"/>
  </mask></defs>
  <g mask="url(#hole)">
    <rect width="{GW}" height="{GH}" fill="{YELLOW}"/>
    <rect x="{SX - bezel - 2}" y="{SY - bezel - 2}" width="{SW + 2 * bezel + 4}"
      height="{sh + 2 * bezel + 4}" rx="{radius + bezel + 2}" fill="#4a4a4a"/>
    <rect x="{SX - bezel}" y="{SY - bezel}" width="{SW + 2 * bezel}"
      height="{sh + 2 * bezel}" rx="{radius + bezel}" fill="#141414"/>
  </g>
  <rect x="{GW / 2 - 63 * pt}" y="{SY + 11 * pt}" width="{126 * pt}"
    height="{37 * pt}" rx="{18.5 * pt}" fill="#000"/>
</svg></body></html>"""
    out = TMP / 'gif-frame.png'
    chrome_shot(html, out, GW, GH, transparent=True)
    return out


def gifs():
    dest = OUT / 'gifs'
    dest.mkdir(parents=True, exist_ok=True)
    overlay = gif_frame_overlay()
    sh = round(SW * 2868 / 1320)
    for frames in sorted((SRC / 'frames').iterdir()):
        name = frames.name
        base = (f"[0:v]scale={SW}:{sh}:flags=lanczos,"
                f"pad={GW}:{GH}:{SX}:{SY}:color=black[s];[s][1:v]overlay=0:0")
        inputs = ['-framerate', '25', '-i', str(frames / 'f%04d.png'),
                  '-i', str(overlay)]
        subprocess.run(
            ['ffmpeg', '-y', '-loglevel', 'error', *inputs, '-filter_complex',
             base + ",split[a][b];[a]palettegen=max_colors=256:"
             "stats_mode=full[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:"
             "diff_mode=rectangle", '-loop', '0', str(dest / f'{name}.gif')],
            check=True)
        subprocess.run(
            ['ffmpeg', '-y', '-loglevel', 'error', *inputs, '-filter_complex',
             base, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20',
             '-movflags', '+faststart', str(dest / f'{name}.mp4')],
            check=True)
        size = (dest / f'{name}.gif').stat().st_size / 1e6
        print(f'   gifs/{name}.gif  {size:.1f} MB  (+ .mp4)')


if __name__ == '__main__':
    TMP.mkdir(parents=True, exist_ok=True)
    what = sys.argv[1:] or ['shots', 'gifs']
    if 'shots' in what:
        shots()
    if 'gifs' in what:
        gifs()
