---
jupytext:
  formats: ipynb,md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.19.6
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

```{code-cell} ipython3
import colour, matplotlib.pyplot as plt

# FIXME: the chromacities are not plotting
#fig, ax = plt.subplots(figsize=(7, 6))
colour.plotting.plot_chromaticity_diagram_CIE1931(
    colourspaces=['sRGB', 'Adobe RGB', 'DCI-P3'],
)
colour.plotting.plot_chromaticity_diagram_CIE1931(
    #axes=ax,
    colourspaces=['sRGB', 'Adobe RGB', 'DCI-P3'],
    chromaticities={'CG247X approx': [[0.64, 0.33], [0.30, 0.60], [0.15, 0.06]]},
)
pass
#ax.set_title("CG247X gamut (approximated as Adobe RGB)")
#plt.tight_layout()
#plt.show()
```

```{code-cell} ipython3
figure, axes = colour.plotting.plot_chromaticity_diagram_CIE1931(
    cmfs='CIE 1931 2 Degree Standard Observer',
    #show_diagram_colours=False, # The color fill
    #show_spectral_locus=False, # The curve outline, graduated <460 to 700 nm
    show=False
)
axes.set_title("")
plt.xlim([0, 0.8])
plt.ylim([0, 0.9])
plt.show()
```

```{code-cell} ipython3

```
