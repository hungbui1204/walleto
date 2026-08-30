#!/usr/bin/env python3
"""Generate Walleto launcher, splash, and notification assets.

Icon grammar (Cash App / Nubank / Phosphor wallet / Material account_balance_wallet):
  full-bleed enamel teal, one landscape billfold, a card peeking from the sleeve,
  a snap as a circular counter. No 3/4 tracing, no mug-handle tab, no nested
  iOS squircle, no wordmark inside the icon.

Splash grammar (Cinema Mobile / Revolut / Linear):
  OLED stage, ambient teal, the mark itself — not a screenshot of a home-screen
  tile — plus Space Grotesk wordmark.
"""

from __future__ import annotations

import io
import random
from pathlib import Path

import cairosvg
from PIL import (
    Image,
    ImageChops,
    ImageDraw,
    ImageFilter,
    ImageFont,
    ImageOps,
)

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "assets" / "images"
FONTS = ROOT / "assets" / "fonts"
DRAWABLE = ROOT / "android" / "app" / "src" / "main" / "res" / "drawable"
PREVIEW = ROOT / "tools" / "brand_preview"

# MASTER.md — Noir Glass
OLED = (0x05, 0x05, 0x06, 255)
TEAL = (0x2D, 0xD4, 0xBF)
TEAL_SOFT = (0x5E, 0xEA, 0xD4)
TEAL_MIST = (0xCC, 0xFB, 0xF1)
TEAL_INK = (0x11, 0x5E, 0x59)
TEAL_RGBA = (*TEAL, 255)
ON_PRIMARY = (0x04, 0x2F, 0x2E)
INK_DEEP = (0x02, 0x1C, 0x1B)
CARD_FACE = (0xEC, 0xFD, 0xF8)
TEXT = (0xED, 0xED, 0xEF, 255)
WORDMARK_FONT = FONTS / "SpaceGrotesk-SemiBold.ttf"

# iOS squircle can sit larger. Circle crops (adaptive / A12 / mono) stay inside the 66dp disk.
ICON_OCCUPANCY = 0.66
ADAPTIVE_OCCUPANCY = 0.54
A12_OCCUPANCY = 0.55
MONO_OCCUPANCY = 0.54
NOTIF_OCCUPANCY = 0.86


def _rel_luminance(rgb: tuple[int, int, int]) -> float:
    def channel(v: int) -> float:
        x = v / 255.0
        return x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4

    r, g, b = (channel(v) for v in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    l1, l2 = _rel_luminance(a), _rel_luminance(b)
    lighter, darker = max(l1, l2), min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def _d(vb: int, x: float, y: float) -> str:
    """64-unit design space → viewBox point."""
    return f"{x * vb / 64.0:.3f} {y * vb / 64.0:.3f}"


def _arc(vb: int, r: float, x: float, y: float, sweep: int = 1) -> str:
    rad = r * vb / 64.0
    return f"A {rad:.3f} {rad:.3f} 0 0 {sweep} {_d(vb, x, y)}"


def _rounded_rect_d(
    vb: int, x: float, y: float, w: float, h: float, r: float
) -> str:
    r = min(r, w / 2.0, h / 2.0)
    return (
        f"M {_d(vb, x + r, y)} "
        f"L {_d(vb, x + w - r, y)} {_arc(vb, r, x + w, y + r)} "
        f"L {_d(vb, x + w, y + h - r)} {_arc(vb, r, x + w - r, y + h)} "
        f"L {_d(vb, x + r, y + h)} {_arc(vb, r, x, y + h - r)} "
        f"L {_d(vb, x, y + r)} {_arc(vb, r, x + r, y)} Z"
    )


def _circle_d(vb: int, cx: float, cy: float, r: float) -> str:
    return (
        f"M {_d(vb, cx - r, cy)} "
        f"A {r * vb / 64.0:.3f} {r * vb / 64.0:.3f} 0 1 1 {_d(vb, cx + r, cy)} "
        f"A {r * vb / 64.0:.3f} {r * vb / 64.0:.3f} 0 1 1 {_d(vb, cx - r, cy)} Z"
    )


def _hex(rgb: tuple[int, int, int]) -> str:
    return f"#{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}"


# Landscape sleeve + thin payment card + snap counter.
# Card radius is tighter than the leather (plastic vs hide). Snap sits fully
# inside the sleeve so evenodd cannot bite the card.
_CARD = (11.8, 14.2, 36.4, 11.2, 3.2)
_FACE = (13.2, 15.4, 33.6, 8.2, 2.2)
_SLOT = (9.8, 21.5, 44.4, 1.4, 0.6)
_BODY = (7.2, 21.8, 49.6, 26.8, 7.0)
_SNAP = (45.4, 35.6, 3.9)


def _paths(vb: int) -> dict[str, str]:
    return {
        "card": _rounded_rect_d(vb, *_CARD),
        "face": _rounded_rect_d(vb, *_FACE),
        "slot": _rounded_rect_d(vb, *_SLOT),
        "body": _rounded_rect_d(vb, *_BODY),
        "snap": _circle_d(vb, *_SNAP),
    }


def mark_svg(
    *,
    ink: str | None = None,
    face: str | None = None,
    vb: int = 1024,
) -> str:
    """Colored mark (ink + card face) or a single-fill silhouette."""
    p = _paths(vb)
    ink = ink or _hex(ON_PRIMARY)
    if face:
        inner = (
            f'  <path d="{p["card"]}" fill="{ink}"/>\n'
            f'  <path d="{p["face"]}" fill="{face}"/>\n'
            f'  <path d="{p["slot"]}" fill="{_hex(INK_DEEP)}" fill-opacity="0.35"/>\n'
            f'  <path d="{p["body"]} {p["snap"]}" fill="{ink}" fill-rule="evenodd"/>'
        )
    else:
        inner = (
            f'  <path d="{p["card"]}" fill="{ink}"/>\n'
            f'  <path d="{p["body"]} {p["snap"]}" fill="{ink}" fill-rule="evenodd"/>'
        )
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{vb}" height="{vb}" '
        f'viewBox="0 0 {vb} {vb}">\n{inner}\n</svg>\n'
    )


def svg_to_image(svg: str, size: int) -> Image.Image:
    png = cairosvg.svg2png(
        bytestring=svg.encode("utf-8"),
        output_width=size,
        output_height=size,
        background_color="rgba(0,0,0,0)",
    )
    return Image.open(io.BytesIO(png)).convert("RGBA")


def alpha_bbox(im: Image.Image, threshold: int = 10) -> tuple[int, int, int, int]:
    alpha = im.split()[-1]
    bbox = alpha.point(lambda p: 255 if p > threshold else 0).getbbox()
    if bbox is None:
        raise RuntimeError("mark is empty")
    return bbox


def center_mark(
    src: Image.Image,
    canvas: int,
    occupancy: float,
    *,
    y_nudge: float = 0.0,
) -> Image.Image:
    bbox = alpha_bbox(src)
    cropped = src.crop(bbox)
    target = int(canvas * occupancy)
    scale = target / max(cropped.size)
    new_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    fitted = cropped.resize(new_size, Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    x = (canvas - fitted.width) // 2
    y = (canvas - fitted.height) // 2 + round(canvas * y_nudge)
    out.paste(fitted, (x, y), fitted)
    return out


def flatten_rgb(
    im: Image.Image,
    color: tuple[int, int, int, int] = OLED,
) -> Image.Image:
    bg = Image.new("RGBA", im.size, color)
    return Image.alpha_composite(bg, im).convert("RGB")


def _radial_overlay(
    size: int,
    color: tuple[int, int, int],
    cx: float,
    cy: float,
    radius: float,
    alpha: float,
) -> Image.Image:
    d = max(8, int(radius * 2 * size))
    blob = Image.radial_gradient("L").resize((d, d), Image.Resampling.BICUBIC)
    blob = blob.point(lambda p: int((255 - p) * alpha))
    tint = Image.new("RGBA", (d, d), (*color, 255))
    tint.putalpha(blob)
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    layer.paste(tint, (int(cx * size - d / 2), int(cy * size - d / 2)), tint)
    return layer


def _linear_wash(
    size: int,
    color: tuple[int, int, int],
    top_alpha: float,
    bot_alpha: float,
) -> Image.Image:
    ramp = Image.linear_gradient("L").resize((size, size), Image.Resampling.BICUBIC)

    def map_p(p: int) -> int:
        t = p / 255.0
        return int(max(0.0, min(1.0, top_alpha + (bot_alpha - top_alpha) * t)) * 255)

    alpha = ramp.point(map_p)
    layer = Image.new("RGBA", (size, size), (*color, 255))
    layer.putalpha(alpha)
    return layer


def _silk_sheen(size: int) -> Image.Image:
    w = h = size * 2
    band = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(band)
    draw.ellipse(
        (int(w * 0.02), int(h * 0.30), int(w * 0.98), int(h * 0.46)),
        fill=255,
    )
    band = band.filter(ImageFilter.GaussianBlur(radius=int(size * 0.14)))
    band = band.rotate(32, resample=Image.Resampling.BICUBIC)
    left = (w - size) // 2
    top = (h - size) // 2
    band = band.crop((left, top, left + size, top + size))
    tint = Image.new("RGBA", (size, size), (*TEAL_MIST, 255))
    tint.putalpha(band.point(lambda p: int(p * 0.08)))
    return tint


def _grain_overlay(rgb: Image.Image, intensity: float = 0.018, seed: int = 11) -> Image.Image:
    size = rgb.size[0]
    rnd = random.Random(seed)
    tile = 256
    small = Image.new("L", (tile, tile))
    px = small.load()
    for y in range(tile):
        for x in range(tile):
            px[x, y] = rnd.randint(0, 255)
    noise = small.resize((size, size), Image.Resampling.BICUBIC)
    noise = noise.filter(ImageFilter.GaussianBlur(radius=0.55))
    grain = Image.merge("RGB", (noise, noise, noise))
    mixed = ImageChops.soft_light(rgb, grain)
    return Image.blend(rgb, mixed, intensity)


def paint_field(size: int) -> Image.Image:
    """Calm enamel — average still reads as brand teal, without gel-toy sheen."""
    deep_sat = (0x1A, 0xB8, 0xA6)
    base = Image.new("RGBA", (size, size), TEAL_RGBA)
    layers = (
        _linear_wash(size, TEAL_SOFT, 0.22, 0.0),
        _linear_wash(size, deep_sat, 0.0, 0.16),
        _radial_overlay(size, TEAL_MIST, 0.20, 0.10, 0.42, 0.18),
        _radial_overlay(size, deep_sat, 0.90, 0.92, 0.58, 0.14),
        _silk_sheen(size),
    )
    for layer in layers:
        base = Image.alpha_composite(base, layer)
    glazed = _grain_overlay(base.convert("RGB"), intensity=0.016, seed=17)
    return glazed.convert("RGBA")


def _alpha(im: Image.Image) -> Image.Image:
    return im.split()[-1]


def _inner_light(
    alpha: Image.Image,
    dx: int,
    dy: int,
    blur: float,
    opacity: float,
) -> Image.Image:
    size = alpha.size[0]
    inv = ImageOps.invert(alpha)
    shifted = Image.new("L", (size, size), 0)
    shifted.paste(inv, (dx, dy))
    shifted = shifted.filter(ImageFilter.GaussianBlur(radius=blur))
    clipped = ImageChops.multiply(shifted, alpha)
    return clipped.point(lambda p: int(p * opacity))


def _tint_alpha(alpha: Image.Image, color: tuple[int, int, int]) -> Image.Image:
    layer = Image.new("RGBA", alpha.size, (*color, 255))
    layer.putalpha(alpha)
    return layer


def _contact_shadow(mark: Image.Image) -> Image.Image:
    canvas = mark.size[0]
    alpha = _alpha(mark)
    shadow = Image.new("L", (canvas, canvas), 0)
    offset = max(1, canvas // 140)
    shadow.paste(alpha, (0, offset))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=max(1.8, canvas * 0.016)))
    shadow = shadow.point(lambda p: int(p * 0.20))
    return _tint_alpha(shadow, (0x02, 0x14, 0x14))


def _shade_ink(mark: Image.Image) -> Image.Image:
    """Whisper of leather volume — not a gel bevel."""
    canvas = mark.size[0]
    alpha = _alpha(mark)
    body = Image.new("RGBA", (canvas, canvas), (*ON_PRIMARY, 255))
    body.putalpha(alpha)
    highlight = _inner_light(
        alpha,
        -max(1, canvas // 140),
        -max(1, canvas // 120),
        max(0.6, canvas * 0.006),
        0.14,
    )
    shade = _inner_light(
        alpha,
        max(1, canvas // 130),
        max(1, canvas // 100),
        max(0.6, canvas * 0.007),
        0.11,
    )
    body = Image.alpha_composite(body, _tint_alpha(highlight, (0xE6, 0xFF, 0xFA)))
    body = Image.alpha_composite(body, _tint_alpha(shade, INK_DEEP))
    return body


def render_mark(
    canvas: int,
    occupancy: float,
    *,
    colored: bool = True,
    fill: tuple[int, int, int] | None = None,
    material: bool = False,
    y_nudge: float = 0.0,
) -> Image.Image:
    if colored:
        svg = mark_svg(face=_hex(CARD_FACE))
    else:
        svg = mark_svg(ink=_hex(fill or (255, 255, 255)), face=None)
    oversample = max(1536, canvas * 2)
    raw = svg_to_image(svg, oversample)
    fitted = center_mark(raw, canvas, occupancy, y_nudge=y_nudge)
    if not (colored and material):
        return fitted

    # Re-render ink without the cream so lighting only hits leather.
    ink_only = center_mark(
        svg_to_image(mark_svg(face=None), oversample),
        canvas,
        occupancy,
        y_nudge=y_nudge,
    )
    cream = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    cream_src = fitted.copy()
    # Keep pixels that are closer to card face than to ink.
    px_f = cream_src.load()
    px_c = cream.load()
    ink = ON_PRIMARY
    face = CARD_FACE
    for y in range(canvas):
        for x in range(canvas):
            r, g, b, a = px_f[x, y]
            if a < 16:
                continue
            d_face = abs(r - face[0]) + abs(g - face[1]) + abs(b - face[2])
            d_ink = abs(r - ink[0]) + abs(g - ink[1]) + abs(b - ink[2])
            if d_face < d_ink and d_face < 80:
                px_c[x, y] = (r, g, b, a)
    leather = _shade_ink(ink_only)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out = Image.alpha_composite(out, leather)
    out = Image.alpha_composite(out, cream)
    return out


def compose_icon(canvas: int = 1024, occupancy: float = ICON_OCCUPANCY) -> Image.Image:
    tile = paint_field(canvas)
    glyph = render_mark(canvas, occupancy, colored=True, material=True)
    tile = Image.alpha_composite(tile, _contact_shadow(glyph))
    return Image.alpha_composite(tile, glyph)


def paint_ambient(
    canvas: Image.Image,
    radius: int,
    alpha: int,
    *,
    cx: float = 0.5,
    cy: float = 0.42,
) -> Image.Image:
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    x = int(canvas.width * cx)
    y = int(canvas.height * cy)
    draw.ellipse(
        (x - radius, y - radius, x + radius, y + radius),
        fill=(*TEAL, alpha),
    )
    layer = layer.filter(ImageFilter.GaussianBlur(radius=int(radius * 0.52)))
    return Image.alpha_composite(canvas, layer)


def _squircle_mask(size: int) -> Image.Image:
    r = int(size * 0.223)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=r, fill=255
    )
    return mask


def _circle_mask(size: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((1, 1, size - 2, size - 2), fill=255)
    return mask


def _apply_mask(rgb: Image.Image, mask: Image.Image) -> Image.Image:
    out = Image.new("RGBA", rgb.size, (0, 0, 0, 0))
    rgba = rgb.convert("RGBA")
    out.paste(rgba, (0, 0))
    out.putalpha(mask)
    return flatten_rgb(out)


def as_squircle(rgb: Image.Image, size: int) -> Image.Image:
    tile = rgb.resize((size, size), Image.Resampling.LANCZOS)
    masked = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    masked.paste(tile.convert("RGBA"), (0, 0))
    masked.putalpha(_squircle_mask(size))
    return masked


def draw_wordmark(canvas: Image.Image, y: int, font_size: int) -> None:
    font = ImageFont.truetype(str(WORDMARK_FONT), font_size)
    text = "Walleto"
    tracking = font_size * 0.06
    draw = ImageDraw.Draw(canvas)
    widths = [draw.textlength(ch, font=font) for ch in text]
    total = sum(widths) + tracking * (len(text) - 1)
    x = (canvas.width - total) / 2
    for ch, w in zip(text, widths):
        draw.text((x, y), ch, font=font, fill=TEXT)
        x += w + tracking


def compose_splash(canvas: int = 1152) -> Image.Image:
    splash = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    splash = paint_ambient(splash, radius=500, alpha=34, cx=0.50, cy=0.40)
    splash = paint_ambient(splash, radius=250, alpha=18, cx=0.36, cy=0.32)
    splash = paint_ambient(splash, radius=210, alpha=12, cx=0.66, cy=0.50)

    glyph_box = 252
    font_size = 40
    gap = 30
    lockup_h = glyph_box + gap + font_size
    top = (canvas - lockup_h) // 2 - 18

    glyph = center_mark(
        svg_to_image(mark_svg(ink=_hex(TEAL), face=_hex(CARD_FACE)), 1536),
        glyph_box,
        occupancy=0.92,
        y_nudge=0.0,
    )

    glow = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    gx = (canvas - glyph_box) // 2
    gdraw.ellipse(
        (gx + 28, top + 36, gx + glyph_box - 28, top + glyph_box - 20),
        fill=(*TEAL, 26),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=38))
    splash = Image.alpha_composite(splash, glow)
    splash.paste(glyph, (gx, top), glyph)
    draw_wordmark(splash, top + glyph_box + gap - 8, font_size)
    return splash


def write_previews(
    *,
    logo: Image.Image,
    adaptive: Image.Image,
    android12: Image.Image,
    splash: Image.Image,
    mono: Image.Image,
) -> None:
    PREVIEW.mkdir(parents=True, exist_ok=True)
    adaptive_on_bg = flatten_rgb(adaptive, TEAL_RGBA)
    a12_on_teal = flatten_rgb(android12, TEAL_RGBA)
    splash_on_bg = flatten_rgb(splash)

    for size in (64, 120, 180, 256, 512):
        logo.resize((size, size), Image.Resampling.LANCZOS).save(
            PREVIEW / f"logo_{size}.png", "PNG", optimize=True
        )
        adaptive_on_bg.resize((size, size), Image.Resampling.LANCZOS).save(
            PREVIEW / f"adaptive_{size}.png", "PNG", optimize=True
        )
        a12_on_teal.resize((size, size), Image.Resampling.LANCZOS).save(
            PREVIEW / f"a12_{size}.png", "PNG", optimize=True
        )

    circled = _apply_mask(
        logo.resize((256, 256), Image.Resampling.LANCZOS), _circle_mask(256)
    )
    circled.save(PREVIEW / "a12_circle_256.png", "PNG", optimize=True)
    squircles = _apply_mask(
        logo.resize((256, 256), Image.Resampling.LANCZOS), _squircle_mask(256)
    )
    squircles.save(PREVIEW / "ios_squircle_256.png", "PNG", optimize=True)
    tiny = _apply_mask(
        logo.resize((64, 64), Image.Resampling.LANCZOS), _squircle_mask(64)
    )
    tiny.save(PREVIEW / "ios_squircle_64.png", "PNG", optimize=True)

    splash_on_bg.save(PREVIEW / "splash_on_oled.png", "PNG", optimize=True)
    flatten_rgb(mono).resize((180, 180), Image.Resampling.LANCZOS).save(
        PREVIEW / "mono_180.png", "PNG", optimize=True
    )

    sheet = Image.new("RGB", (920, 280), (0x12, 0x12, 0x14))
    samples = [
        tiny,
        _apply_mask(logo.resize((120, 120), Image.Resampling.LANCZOS), _squircle_mask(120)),
        squircles,
        circled,
    ]
    x = 36
    for im in samples:
        sheet.paste(im, (x, (280 - im.height) // 2))
        x += im.width + 28
    sheet.save(PREVIEW / "qa_homescreen.png", "PNG", optimize=True)

    aso = Image.new("RGB", (720, 280), (0x12, 0x12, 0x14))
    light = Image.new("RGB", (720, 280), (0xF2, 0xF2, 0xF7))
    sizes = (29, 40, 60, 120)
    for row, _bg in ((aso, aso), (light, light)):
        x = 36
        for s in sizes:
            icon = _apply_mask(
                logo.resize((s, s), Image.Resampling.LANCZOS), _squircle_mask(s)
            )
            row.paste(icon, (x, (280 - s) // 2), icon.convert("RGBA"))
            x += s + 48
    stacked = Image.new("RGB", (720, 580), (0x12, 0x12, 0x14))
    stacked.paste(aso, (0, 0))
    stacked.paste(light, (0, 300))
    stacked.save(PREVIEW / "qa_aso_sizes.png", "PNG", optimize=True)


def build() -> None:
    IMAGES.mkdir(parents=True, exist_ok=True)
    DRAWABLE.mkdir(parents=True, exist_ok=True)

    ratio = contrast_ratio(ON_PRIMARY, TEAL)
    if ratio < 4.5:
        raise SystemExit(f"W/field contrast {ratio:.2f}:1 is below 4.5:1")
    card_on_ink = contrast_ratio(CARD_FACE, ON_PRIMARY)
    if card_on_ink < 4.5:
        raise SystemExit(f"Card/ink contrast {card_on_ink:.2f}:1 is below 4.5:1")

    logo = compose_icon(1024, ICON_OCCUPANCY).convert("RGB")
    field = [
        logo.getpixel((x, y))
        for y in range(0, 1024, 8)
        for x in range(0, 1024, 8)
        if logo.getpixel((x, y))[1] > 140
    ]
    field_avg = tuple(sum(p[i] for p in field) // len(field) for i in range(3))
    logo.save(IMAGES / "walleto_logo.png", "PNG", optimize=True)

    Image.new("RGB", (1024, 1024), TEAL).save(IMAGES / "adaptive-icon.png", "PNG")
    adaptive = render_mark(1024, ADAPTIVE_OCCUPANCY, colored=True, material=True)
    adaptive.save(IMAGES / "walleto_adaptive_foreground.png", "PNG", optimize=True)

    android12 = render_mark(1152, A12_OCCUPANCY, colored=True, material=True)
    android12.save(IMAGES / "walleto_android12_splash.png", "PNG", optimize=True)

    splash = compose_splash()
    splash.save(IMAGES / "walleto_splash_screen.png", "PNG", optimize=True)

    mono = render_mark(
        1024, MONO_OCCUPANCY, colored=False, fill=(255, 255, 255), material=False
    )
    mono.save(IMAGES / "walleto_monochrome.png", "PNG", optimize=True)

    notif = render_mark(
        96, NOTIF_OCCUPANCY, colored=False, fill=(255, 255, 255), material=False
    )
    notif.save(DRAWABLE / "notification_icon.png", "PNG", optimize=True)

    (IMAGES / "walleto_mark.svg").write_text(
        mark_svg(face=_hex(CARD_FACE)), encoding="utf-8"
    )
    write_previews(
        logo=logo,
        adaptive=adaptive,
        android12=android12,
        splash=splash,
        mono=mono,
    )
    print("Wrote brand assets to", IMAGES)
    print("Wrote previews to", PREVIEW)
    print(f"Wallet on teal contrast {ratio:.2f}:1")
    print(f"Card on ink contrast {card_on_ink:.2f}:1")
    print(f"Field average RGB {field_avg} (brand teal {TEAL})")


if __name__ == "__main__":
    build()
