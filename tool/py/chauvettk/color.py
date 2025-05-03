from colormath.color_objects import sRGBColor, LabColor
from colormath.color_conversions import convert_color


def rgb_norm(rgb16bitdec):
    """
    Normalize 16bit color tuple
    """
    return tuple(c / 255.0 for c in rgb16bitdec)


def rgb_to_lab(rgb):
    srgb = sRGBColor(*rgb)
    return convert_color(srgb, LabColor)


def rgbhex_norm(rgbhex):
    rgb16bitdec = tuple(int(rgbhex.lstrip('#')[j:j+2], 16) for j in (0, 2, 4))
    return rgb_norm(rgb16bitdec)


def rgbhex_to_lab(rgbhex):
    rgb = rgbhex_norm(rgbhex)
    return rgb_to_lab(rgb)

#
