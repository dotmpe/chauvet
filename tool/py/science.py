#! /usr/bin/env python3
import colour

# Perceptual color difference (CIEDE2000, CIECAM02, etc.)
#colour.delta_E([50, 25, -10], [50, 30, -5], method='CIE 2000')

# Color appearance model (accounts for viewing conditions, adaptation)
colour.XYZ_to_CIECAM02(XYZ, XYZ_w, L_A=318.31, Y_b=20.0)

# Gamut volume (Monte Carlo)
#colour.RGB_colourspace_volume_MonteCarlo(colour.sRGB_COLOURSPACE)

# Chromaticity diagram with multiple gamuts overlaid
#colour.plot_chromaticity_diagram_CIE1931(colourspaces=['sRGB', 'Adobe RGB', 'DCI-P3'])

# Full conversion chain: spectral → XYZ → Lab → CAM16
#colour.convert(spectral_data, "Spectral Distribution", "CIE 1931 XYZ")

# vim:fenc=utf-8
