# forestplotR
Journal-ready forest plots with uniform spacing, embedded fonts, and automated sizing for Mendelian-randomization (or any β/CI) results.

forestplotR turns a tidy CSV of β estimates and confidence intervals into publication-quality SVG forest plots—every figure sized to the journal column width you choose, every font embedded for true vector fidelity.
Built around ggplot2, ggpubr, and svglite, the script auto-iterates over outcomes (or exposures), applies crisp, uniform spacing, and saves each plot to a dedicated folder. Ready for Cell, Nature, or your next bioRxiv pre-print.

*Uniform spacing, automatic sizing, zero Illustrator fuss.*

---

##  Why use this script?
* **Plug-and-plot** – drop in a tidy CSV of β / CI values and run.
* **True vector output** – fonts embedded in‐file via **showtext** + **svglite**.
* **Auto-sizing** – choose a *single* (88 mm) or *double* (180 mm) column; row height scales automatically.
* **Batch mode** – one SVG per outcome (or exposure) written to `figs_highimpact/`.
* **Journal aesthetics** – built on `theme_pubr()`, dashed zero line, consolidated legend.

---

## 🗂 Input format

| column          | example value                 | notes                                        |
|-----------------|-------------------------------|----------------------------------------------|
| `exposure`      | *Serine*                     | becomes y-axis label                         |
| `outcome`       | *Type 2 Diabetes*            | used to split output files (`SPLIT_VAR`)     |
| `method`        | *IVW*                        | plotted as colour / shape                    |
| `beta`          | `-0.17`                      | point estimate                               |
| `ci_lower`      | `-0.24`                      | 95 % CI lower bound                          |
| `ci_upper`      | `-0.10`                      | 95 % CI upper bound                          |
| *(alt.)* `SE`   | `0.037`                      | script converts SE → CI if CI columns absent |

Save as `your_results.csv` (or change `CSV` parameter).

---

##  Quick start

```bash
# clone
git clone https://github.com/SidSin0809/forestplotR.git
cd forestplotR


# run
Rscript forestplotR.r \
    --csv         your_results.csv \
    --split_var    outcome \
    --col_width    single \
    --out_dir      figs_highimpact
```
#  Customising

Column width – switch COL_WIDTH to "double" for 180 mm figures.

Facet wrap – default is facet_wrap(~ outcome, ncol = 5); edit for columns / label wrapping.

Colours & shapes – palette is RColorBrewer::Dark2; adjust in make_forest().

Row height – tweak row_h_mm in opt_dims() if labels overlap.

##  Citation
If this script accelerates your manuscript, a citation or acknowledgment is appreciated

