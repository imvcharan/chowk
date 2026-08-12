from PIL import Image, ImageDraw, ImageOps
from pathlib import Path

root = Path('c:/xampp/htdocs/chawk')
logo_path = root / 'assets' / 'images' / 'chowk_hindi_final.jpeg'
logo = Image.open(logo_path).convert('RGBA')


def crop_to_content(image, threshold=240, padding=0.04):
    pixels = image.load()
    width, height = image.size
    minx, miny = width, height
    maxx, maxy = 0, 0

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if r < threshold or g < threshold or b < threshold:
                minx, miny = min(minx, x), min(miny, y)
                maxx, maxy = max(maxx, x), max(maxy, y)

    if minx >= maxx or miny >= maxy:
        return image

    pad_x = int((maxx - minx) * padding)
    pad_y = int((maxy - miny) * padding)
    return image.crop(
        (
            max(0, minx - pad_x),
            max(0, miny - pad_y),
            min(width, maxx + pad_x),
            min(height, maxy + pad_y),
        )
    )

logo = crop_to_content(logo)

# Common square template generator

def create_icon(size, output_path):
    canvas = Image.new('RGBA', (size, size), (255, 255, 255, 255))
    border = int(size * 0.05)
    draw = ImageDraw.Draw(canvas)
    draw.ellipse(
        [border, border, size - border, size - border],
        fill=(255, 255, 255, 255),
        outline=(255, 106, 0, 255),
        width=max(2, int(size * 0.05)),
    )

    target = int(size * 0.88)
    logo_ratio = logo.width / logo.height
    if logo_ratio >= 1:
        logo_w = target
        logo_h = int(target / logo_ratio)
    else:
        logo_h = target
        logo_w = int(target * logo_ratio)

    resized = logo.resize((logo_w, logo_h), Image.LANCZOS)
    x = (size - logo_w) // 2
    y = (size - logo_h) // 2
    canvas.alpha_composite(resized, (x, y))
    canvas = canvas.convert('RGB')
    canvas.save(output_path, format='PNG')


def create_splash(size, output_path):
    canvas = Image.new('RGB', (size, size), (255, 255, 255))
    target = int(size * 0.78)
    logo_ratio = logo.width / logo.height
    if logo_ratio >= 1:
        logo_w = target
        logo_h = int(target / logo_ratio)
    else:
        logo_h = target
        logo_w = int(target * logo_ratio)
    resized = logo.resize((logo_w, logo_h), Image.LANCZOS)
    x = (size - logo_w) // 2
    y = (size - logo_h) // 2
    canvas.paste(resized, (x, y), resized)
    canvas.save(output_path, format='PNG')


# Android mipmap sizes
mipmap_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}
for folder, size in mipmap_sizes.items():
    path = root / 'android' / 'app' / 'src' / 'main' / 'res' / folder / 'ic_launcher.png'
    create_icon(size, path)
    print('Created', path)

# Android splash image
splash_path = root / 'android' / 'app' / 'src' / 'main' / 'res' / 'drawable' / 'launch_image.png'
create_splash(1024, splash_path)
print('Created', splash_path)

# iOS icon sizes from AppIcon contents
ios_icon_files = [
    ('Icon-App-20x20@2x.png', 40),
    ('Icon-App-20x20@3x.png', 60),
    ('Icon-App-29x29@1x.png', 29),
    ('Icon-App-29x29@2x.png', 58),
    ('Icon-App-29x29@3x.png', 87),
    ('Icon-App-40x40@1x.png', 40),
    ('Icon-App-40x40@2x.png', 80),
    ('Icon-App-40x40@3x.png', 120),
    ('Icon-App-60x60@2x.png', 120),
    ('Icon-App-60x60@3x.png', 180),
    ('Icon-App-20x20@1x.png', 20),
    ('Icon-App-20x20@2x.png', 40),
    ('Icon-App-20x20@3x.png', 60),
    ('Icon-App-29x29@1x.png', 29),
    ('Icon-App-29x29@2x.png', 58),
    ('Icon-App-29x29@3x.png', 87),
    ('Icon-App-40x40@1x.png', 40),
    ('Icon-App-40x40@2x.png', 80),
    ('Icon-App-40x40@3x.png', 120),
    ('Icon-App-60x60@2x.png', 120),
    ('Icon-App-60x60@3x.png', 180),
    ('Icon-App-76x76@1x.png', 76),
    ('Icon-App-76x76@2x.png', 152),
    ('Icon-App-83.5x83.5@2x.png', 167),
    ('Icon-App-1024x1024@1x.png', 1024),
]
for filename, size in ios_icon_files:
    path = root / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset' / filename
    create_icon(size, path)
    print('Created', path)

# iOS splash launch images
launch_image_sizes = [
    ('LaunchImage.png', 1200),
    ('LaunchImage@2x.png', 2400),
    ('LaunchImage@3x.png', 3600),
]
for filename, size in launch_image_sizes:
    path = root / 'ios' / 'Runner' / 'Assets.xcassets' / 'LaunchImage.imageset' / filename
    create_splash(size, path)
    print('Created', path)
