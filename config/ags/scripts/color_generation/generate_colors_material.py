#!/usr/bin/env python3
import argparse
import math
import json
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.hct import Hct
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.utils.color_utils import (rgba_from_argb, argb_from_rgb, argb_from_rgba)
from materialyoucolor.utils.math_utils import (sanitize_degrees_double, difference_degrees, rotation_direction)
import os
import colorsys
import sys

home_dir = os.path.expanduser("~")
parser = argparse.ArgumentParser(description='Color generation script')
parser.add_argument('--path', type=str, default=None, help='generate colorscheme from image')
parser.add_argument('--size', type=int , default=128 , help='bitmap image size')
parser.add_argument('--color', type=str, default=None, help='generate colorscheme from color')
parser.add_argument('--mode', type=str, choices=['dark', 'light'], default='dark', help='dark or light mode')
parser.add_argument('--scheme', type=str, default='vibrant', help='material scheme to use')
parser.add_argument('--smart', action='store_true', default=False, help='decide scheme type based on image color')
parser.add_argument('--apply', action='store_true', default=False, help='apply or not')
parser.add_argument('--ags', action='store_true', default=False, help='ags restart')
parser.add_argument('--transparency', type=str, choices=['opaque', 'transparent'], default='opaque', help='enable transparency')
parser.add_argument('--termscheme', type=str, default=None, help='JSON file containg the terminal scheme for generating term colors')
parser.add_argument('--harmony', type=float , default=0.8, help='(0-1) Color hue shift towards accent')
parser.add_argument('--harmonize_threshold', type=float , default=100, help='(0-180) Max threshold angle to limit color hue shift')
parser.add_argument('--term_fg_boost', type=float , default=0.35, help='Make terminal foreground more different from the background')
parser.add_argument('--blend_bg_fg', action='store_true', default=False, help='Shift terminal background or foreground towards accent')
parser.add_argument('--cache', type=str, default=None, help='file path to store the generated color')
parser.add_argument('--debug', action='store_true', default=False, help='debug mode')
args = parser.parse_args()

rgba_to_hex = lambda rgba: "#{:02X}{:02X}{:02X}".format(rgba[0], rgba[1], rgba[2])
argb_to_hex = lambda argb: "#{:02X}{:02X}{:02X}".format(*map(round, rgba_from_argb(argb)))
hex_to_argb = lambda hex_code: argb_from_rgb(int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16))
display_color = lambda rgba : "\x1B[38;2;{};{};{}m{}\x1B[0m".format(rgba[0], rgba[1], rgba[2], "\x1b[7m   \x1b[7m")
def apply_ags(thing):
    forags = f""
    forags += f"$darkmode: {darkmode};\n"
    forags += f"$transparent: {transparent};\n"
    for color,code in thing:
        forags += f"${color}: {code};\n"
    with open(os.path.join(home_dir, ".config", "ags", "scss", "_color.scss"), "w") as f:
        f.write(forags)
    sass_file = home_dir+"/.config/ags/scss/main.scss"
    css_file = home_dir+"/.config/ags/style.css"
    os.system(f"sass {sass_file} {css_file}")
    # compiled_css = sass.compile(filename=sass_file)
    # with open(css_file, 'w') as file:
    #     file.write(compiled_css)
    # os.system(f"sass {home_dir}/.config/ags/scss/main.scss {home_dir}/.config/ags/style.css")
    # os.system(f"ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'")
    # os.system(f"ags run-js 'App.applyCss(\"{home_dir}/.cache/ags/user/generated/style.css\");'")
def applygradience(thing):
    a = 'adw-gtk3-dark'
    b = '"prefer-dark"'
    if args.mode == 'light':
        a = 'adw-gtk3'
        b = '"prefer-light"'
    os.system(f"gradience-cli apply -p {home_dir}/.cache/ags/user/generated/gradience/preset.json --gtk both")
    os.system(f"gsettings set org.gnome.desktop.interface gtk-theme {a}")
    os.system(f"gsettings set org.gnome.desktop.interface color-scheme {b}")
    
def colorapply(path,thing):
    file_path = os.path.expanduser(path)
    with open(file_path, 'r') as file:
        file_data = file.read()
    # Replace placeholders with corresponding values
    for color,code in thing:
        placeholder = "{{ $" + color + " }}"
        # print(placeholder)
        value = code.strip("#")
        file_data = file_data.replace(placeholder, value)
        # print(file_data)

    # Write the modified content back to the file
    with open(file_path, 'w') as file:
        file.write(file_data)
def calculate_optimal_size (width: int, height: int, bitmap_size: int) -> (int, int):
    image_area = width * height;
    bitmap_area = bitmap_size ** 2
    scale = math.sqrt(bitmap_area/image_area) if image_area > bitmap_area else 1
    new_width = round(width * scale)
    new_height = round(height * scale)
    if new_width == 0:
        new_width = 1
    if new_height == 0:
        new_height = 1
    return new_width, new_height

def harmonize (design_color: int, source_color: int, threshold: float = 35, harmony: float = 0.5) -> int:
    from_hct = Hct.from_int(design_color)
    to_hct = Hct.from_int(source_color)
    difference_degrees_ = difference_degrees(from_hct.hue, to_hct.hue)
    rotation_degrees = min(difference_degrees_ * harmony, threshold)
    output_hue = sanitize_degrees_double(
        from_hct.hue + rotation_degrees * rotation_direction(from_hct.hue, to_hct.hue)
    )
    return Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone).to_int()

def boost_chroma_tone (argb: int, chroma: float = 1, tone: float = 1) -> int:
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma * chroma, hct.tone * tone).to_int()

darkmode = (args.mode == 'dark')
transparent = (args.transparency == 'transparent')

if args.path is not None:
    image = Image.open(args.path)
    wsize, hsize = image.size
    wsize_new, hsize_new = calculate_optimal_size(wsize, hsize, args.size)
    if wsize_new < wsize or hsize_new < hsize:
        image = image.resize((wsize_new, hsize_new), Image.Resampling.BICUBIC)
    colors = QuantizeCelebi(list(image.getdata()), 128)
    argb = Score.score(colors)[0]

    if args.cache is not None:
        with open(args.cache, 'w') as file:
            file.write(argb_to_hex(argb))
    hct = Hct.from_int(argb)
    if(args.smart):
        if(hct.chroma < 20):
            args.scheme = 'neutral'
        if(hct.tone > 60):
            darkmode = False
elif args.color is not None:
    argb = hex_to_argb(args.color)
    hct = Hct.from_int(argb)
else:
    print("Please specify --path")
    print("For example: ./generate_colors_material --path /path/wallpaper.png")
    sys.exit(1)

if args.scheme == 'fruitsalad':
    from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad as Scheme
elif args.scheme == 'expressive':
    from materialyoucolor.scheme.scheme_expressive import SchemeExpressive as Scheme
elif args.scheme == 'monochrome':
    from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome as Scheme
elif args.scheme == 'rainbow':
    from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow as Scheme
elif args.scheme == 'tonalspot':
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
elif args.scheme == 'neutral':
    from materialyoucolor.scheme.scheme_neutral import SchemeNeutral as Scheme
elif args.scheme == 'fidelity':
    from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity as Scheme
elif args.scheme == 'content':
    from materialyoucolor.scheme.scheme_content import SchemeContent as Scheme
elif args.scheme == 'vibrant':
    from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant as Scheme
else: 
    print("Please specify --scheme [fruitsalad|expressive|monochrome|rainbow|tonalspot|neutral|fidelity|content|vibrant]")
    sys.exit(1)

# Generate
scheme = Scheme(hct, darkmode, 0.0)

material_colors = {}
term_colors = {}

for color in vars(MaterialDynamicColors).keys():
    color_name = getattr(MaterialDynamicColors, color)
    if hasattr(color_name, "get_hct"):
        rgba = color_name.get_hct(scheme).to_rgba()
        material_colors[color] = rgba_to_hex(rgba)

# Extended material
if darkmode == True:
    material_colors['success'] = '#B5CCBA'
    material_colors['onSuccess'] = '#213528'
    material_colors['successContainer'] = '#374B3E'
    material_colors['onSuccessContainer'] = '#D1E9D6'
else:
    material_colors['success'] = '#4F6354'
    material_colors['onSuccess'] = '#FFFFFF'
    material_colors['successContainer'] = '#D1E8D5'
    material_colors['onSuccessContainer'] = '#0C1F13'

# Terminal Colors
if args.termscheme is not None:
    with open(args.termscheme, 'r') as f:
        json_termscheme = f.read()
    term_source_colors = json.loads(json_termscheme)['dark' if darkmode else 'light']

    primary_color_argb = hex_to_argb(material_colors['primary_paletteKeyColor'])
    for color, val in term_source_colors.items():
        if(args.scheme == 'monochrome') :
            term_colors[color] = val
            continue
        if args.blend_bg_fg and color == "term0":
            harmonized = boost_chroma_tone(hex_to_argb(material_colors['surfaceContainerLow']), 1.2, 0.95)
        elif args.blend_bg_fg and color == "term15":
            harmonized = boost_chroma_tone(hex_to_argb(material_colors['onSurface']), 3, 1)
        else:
            harmonized = harmonize(hex_to_argb(val), primary_color_argb, args.harmonize_threshold, args.harmony)
            harmonized = boost_chroma_tone(harmonized, 1, 1 + (args.term_fg_boost * (1 if darkmode else -1)))
        term_colors[color] = argb_to_hex(harmonized)

material_colors["crim"] = args.mode
if args.mode == 'light':
    material_colors["onAny"] = "#000000"
else:
    material_colors["onAny"] = "#ffffff"
if args.debug == True:
    print(f"$darkmode: {darkmode};")
    print(f"$transparent: {transparent};")
    for color, code in material_colors.items():
        print(f"${color}: {code};")
    for color, code in term_colors.items():
        print(f"${color}: {code};")
# else:
#     if args.path is not None:
#         print('\n--------------Image properties-----------------')
#         print(f"Image size: {wsize} x {hsize}")
#         print(f"Resized image: {wsize_new} x {hsize_new}")
#     print('\n---------------Selected color------------------')
#     print(f"Dark mode: {darkmode}")
#     print(f"Scheme: {args.scheme}")
#     print(f"Accent color: {display_color(rgba_from_argb(argb))} {argb_to_hex(argb)}")
#     print(f"HCT: {hct.hue:.2f}  {hct.chroma:.2f}  {hct.tone:.2f}")
#     print('\n---------------Material colors-----------------')
#     for color, code in material_colors.items():
#         rgba = rgba_from_argb(hex_to_argb(code))
#         print(f"{color.ljust(32)} : {display_color(rgba)}  {code}")
#     print('\n----------Harmonize terminal colors------------')
#     for color, code in term_colors.items():
#         rgba = rgba_from_argb(hex_to_argb(code))
#         code_source = term_source_colors[color]
#         rgba_source = rgba_from_argb(hex_to_argb(code_source))
#         print(f"{color.ljust(6)} : {display_color(rgba_source)} {code_source} --> {display_color(rgba)} {code}")
#     print('-----------------------------------------------')
#

def boost_saturation(hex_color, factor=1.5):
    """
    Boosts the saturation of a given hex color by multiplying its saturation by the factor.
    
    Parameters:
        hex_color (str): The hex color code (e.g., '#RRGGBB').
        factor (float): The factor by which to boost the saturation (e.g., 1.5 means 50% more saturation).
        
    Returns:
        str: The color with boosted saturation in hex format.
    """
    if hex_color.startswith('#'):
        hex_color = hex_color[1:]
    
    # Convert hex to RGB
    r = int(hex_color[0:2], 16) / 255.0
    g = int(hex_color[2:4], 16) / 255.0
    b = int(hex_color[4:6], 16) / 255.0
    
    # Convert RGB to HSV
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    
    # Boost saturation
    s = min(1.0, s * factor)
    
    # Convert HSV back to RGB
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    
    # Convert RGB to hex
    boosted_hex = f'#{int(r * 255):02X}{int(g * 255):02X}{int(b * 255):02X}'
    
    return boosted_hex

def copy_everything(src_dir, dest_dir):
    import shutil
    os.makedirs(dest_dir, exist_ok=True)

    for item in os.listdir(src_dir):
        src_path = os.path.join(src_dir, item)
        dest_path = os.path.join(dest_dir, item)

        if os.path.isdir(src_path):
            shutil.copytree(src_path, dest_path, dirs_exist_ok=True)
        else:
            shutil.copy2(src_path, dest_path)

# for color,code in material_colors.items():
#     material_colors[color] = boost_saturation(code,1)
if args.apply:
    target_dir = os.path.join(home_dir, ".config", "ags", "scripts", "templates")
    copy_everything(target_dir, home_dir)
    # os.system(f"cp -r {target_dir}/.* {home_dir}")
    # Define the target directory
    # Walk through the directory
    for root, dirs, files in os.walk(target_dir):
        for file in files:
            relative_path = os.path.relpath(os.path.join(root, file), target_dir)
            colorapply(os.path.join(os.getenv("HOME"),relative_path),material_colors.items())
    apply_ags(material_colors.items())
    applygradience(material_colors.items())
    datawrite = ""
    datawrite += args.mode + "\n"
    datawrite += args.transparency + "\n"
    datawrite += args.scheme 
    file_path = os.path.join(home_dir, ".cache", "ags", "user", "colormode.txt")
    with open(file_path, 'w') as file:
        file.write(datawrite)
if args.ags:
    os.system("killall simple-bar; ~/.config/ags/simple-bar")
