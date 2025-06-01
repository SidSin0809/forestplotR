#!/usr/bin/env Rscript
# ============================================================
#  Journal‑ready forest plots: uniform spacing, embedded fonts
# ============================================================

## 0 ▸ install/load ---------------------------------------------------
pkgs <- c("tidyverse", "patchwork", "ggpubr", "svglite", "showtext")
for (p in pkgs) if (!requireNamespace(p, quietly = TRUE))
  install.packages(p, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(tidyverse)   # ggplot2 ≥3.4, readr, dplyr …
  library(patchwork)   # (not used here but handy if you combine plots)
  library(ggpubr)      # theme_pubr()
  library(svglite)     # vector SVG with font metadata
  library(showtext)    # embed system fonts
})
showtext_auto()                       # Helvetica/Arial in SVG

## 1 ▸ user parameters ------------------------------------------------
CSV        <- "your_results.csv"
SPLIT_VAR  <- "outcome"          # switch to "exposure" for one‑file‑per‑metabolite
COL_WIDTH  <- "single"           # "single" (88 mm) or "double" (180 mm)
OUT_DIR    <- "figs_highimpact"
dir.create(OUT_DIR, showWarnings = FALSE)

## 2 ▸ helper functions ----------------------------------------------
mm2in  <- function(mm) mm / 25.4
opt_dims <- function(n_rows,
                     col = c("single","double"),
                     row_h_mm = 6, base_h_mm = 76) {
  col <- match.arg(col)
  width_mm  <- ifelse(col == "single", 88, 180)
  height_mm <- base_h_mm + n_rows * row_h_mm
  list(w = mm2in(width_mm),
       h = mm2in(height_mm * 1.04))      # 4 % headroom
}

## 3 ▸ read + pre‑process data ---------------------------------------
df <- read_csv(CSV, show_col_types = FALSE) %>%
  filter(!str_detect(method, regex("egger", TRUE))) %>%   # drop MR‑Egger
  mutate(across(c(exposure, outcome), ~ factor(., levels = sort(unique(.)))))

if (!all(c("ci_lower", "ci_upper") %in% names(df)) && "SE" %in% names(df)) {
  df <- df %>% mutate(ci_lower = beta - 1.96 * SE,
                      ci_upper = beta + 1.96 * SE)
}

## 4 ▸ plotting function ---------------------------------------------
make_forest <- function(d, title_txt) {
  meths   <- unique(d$method)
  cols    <- RColorBrewer::brewer.pal(pmin(8, length(meths)), "Dark2")
  names(cols) <- meths
  shapes  <- c(16,17,15,18,4,3,8,7)[seq_along(meths)]
  names(shapes) <- meths

  ggplot(d,
         aes(y = exposure, x = beta,
             colour = method, shape = method)) +
    geom_vline(xintercept = 0, linetype = "dashed", linewidth = .3) +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                   height = .15, linewidth = .45,
                   position = position_dodge(width = 0.5)) +
    geom_point(position = position_dodge(width = 0.5), size = 2.0) +
    facet_wrap(~ outcome, ncol = 5, labeller = label_wrap_gen(20)) +
    scale_colour_manual(values = cols, name = "MR Method") +
    scale_shape_manual(values = shapes, name  = "MR Method") +
    labs(x = "Causal Effect (β)", y = NULL, title = title_txt) +
    theme_pubr(base_size = 10) +
    theme(
      panel.spacing   = unit(0.22, "lines"),
      strip.text      = element_text(size = 11, face = "bold"),
      axis.text.x     = element_text(size = 9),
      axis.text.y     = element_text(size = 9),
      axis.title      = element_text(size = 10),
      legend.position = "bottom",
      legend.key.size = unit(0.45, "lines"),
      legend.text     = element_text(size = 8),
      legend.title    = element_text(size = 8, face = "bold"),
      plot.margin     = margin(3, 3, 3, 3, "pt")
    ) +
    guides(colour = guide_legend(nrow = 1),
           shape  = guide_legend(nrow = 1))
}

## 5 ▸ iterate & export ----------------------------------------------
for (grp in unique(df[[SPLIT_VAR]])) {
  dsub <- filter(df, !!sym(SPLIT_VAR) == grp)
  fig  <- make_forest(dsub, paste("Mendelian Randomization –", grp))
  dims <- opt_dims(n_rows = n_distinct(dsub$exposure), col = COL_WIDTH)

  out_file <- file.path(
    OUT_DIR,
    paste0("forest_", SPLIT_VAR, "_",
           gsub("[^A-Za-z0-9_]", "_", grp), ".svg")
  )

  ggsave(out_file, fig,
         device  = svglite,
         width   = dims$w,
         height  = dims$h,
         units   = "in",
         dpi     = 320)      # >300 dpi safety if rasterised
  message("✓ ", out_file)
}
message("All figures in ", normalizePath(OUT_DIR))
