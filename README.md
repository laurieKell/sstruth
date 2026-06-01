# sstruth

Tools for **Stock Synthesis** workflows: retrospectives, forecast projections, M×steepness grids, M×β likelihood profiles, ensemble extraction, process-error (`curveSS`), and back-test tables. Use **`?ss3Workflow`** for the full **sequential** map and the link to **[ss3diags](https://github.com/jabbamodel/ss3diags)** (diagnostic plots and tests on `SS_output`).

Offline copy of the workflow: `system.file("SS3_WORKFLOW.md", package = "sstruth")` after install.

## Installation

```r
remotes::install_github("laurieKell/sstruth", ref = "development")
# or from a local clone:
devtools::install("path/to/sstruth")
devtools::load_all("path/to/sstruth")
```

Optional companion (not on CRAN):

```r
remotes::install_github("jabbamodel/ss3diags")
```

## Setup on another machine

Use the **`development`** branch for the latest SS3 I/O used by the **3diags** appendix pipeline (profile grids, `curveSsLoadCombined`, `runSs3Dir`, etc.).

### 1. Clone repositories

```bash
git clone https://github.com/laurieKell/sstruth.git
git clone https://github.com/flr/diags.git
git clone https://github.com/laurieKell/SCRS-papers.git   # contains 3diags/
```

```bash
cd sstruth && git checkout development
cd ../diags && git checkout development
```

(`3diags` lives under `scrs-papers/3diags/` in the papers repo.)

### 2. R package dependencies

Install from GitHub / local paths:

```r
install.packages(c("devtools", "remotes", "future", "future.apply", "jsonlite"))

remotes::install_github("r4ss/r4ss")
remotes::install_github("flr/ss3om")          # if needed
remotes::install_github("jabbamodel/ss3diags") # optional plots/tests

devtools::install("path/to/diags")    # development branch
devtools::install("path/to/sstruth")  # development branch
```

`sstruth` **Imports** include **r4ss**, **ss3om**, **diags**, **dplyr**, **ggplot2**, **plyr**, etc.; see `DESCRIPTION`.

### 3. Stock Synthesis executable

Set the SS3 executable (name or full path) before running grids or retros:

```bash
# Windows PowerShell
$env:SS3_EXE = "ss3"

# Linux / macOS
export SS3_EXE=ss3
```

### 4. Example data paths

Bundled SS3 inputs (when present in the clone) live under:

```
sstruth/data/ss3/<stock>/
```

For the **sma-natl** case study, point the appendix at your clone, e.g. in `3diags/appendices/studies/sma-natl.R`:

```r
assessment_base = "/path/to/sstruth/data/ss3/sma-natl"
```

Or override at run time:

```bash
export DIAG_SS_BASE=/path/to/sstruth/data/ss3/sma-natl
```

### 5. Run the 3diags diagnostic pipeline

From the `3diags` directory:

```bash
# Import pre-run M×β profile grid and produce figures
Rscript appendices/R/run-diagnostics.R \
  --appendix-dir appendices \
  --study sma-natl \
  --import-profiles /path/to/profile/grid/root \
  --tasks first_pass_import \
  --workers 4

# Plot only (scenarios already on disk)
Rscript appendices/R/run-diagnostics.R \
  --appendix-dir appendices \
  --study sma-natl \
  --tasks figures \
  --plot-only
```

Figures are written to `3diags/appendices/figs/internal/`.

### Package roles

| Package | Role |
|---------|------|
| **sstruth** | SS3 runs, reads, profile grids, `curveSS`, retros, PE |
| **diags** | Framework-agnostic parallel I/O, longrun status, task runner |
| **3diags** | Study config, LaTeX appendices, thin CLIs |

SS3-specific code belongs in **sstruth**; generic workflow I/O belongs in **diags** (`development` branch). Application wiring stays in **3diags**.

## Sequential workflow (summary)

1. **Preflight** — `ssPreflight()`
2. **Retros** — `runRetros()` → `collectRetro()` / `retroBacktestData()`
3. **F-level projections** — `runFlevelProjectionsPeels()` (four scenarios per peel)
4. **Lookups** — `retroForecastScenarioSummary()`, `referenceManagementTable()`
5. **M×h grid** (optional) — `runSs3MhGrid()` → `collectMhGridSsB()`
6. **M×β profile grid** (optional) — `runSs3ProfileGrid()` → `collectProfileLikelihoods()`
7. **Ensemble combine** (optional) — `ensembleWeightedSpawnBio()` with weights you choose
8. **Diagnostics** — **[ss3diags](https://github.com/jabbamodel/ss3diags)** (`SSplotRunstest`, `SSplotJABBAres`, `SSmase`, `SSplotEnsemble`, …) on each converged run

Details: **`?ss3Workflow`**, **`inst/SS3_WORKFLOW.md`**, vignette **`vignette("ss3-retro-projections", package = "sstruth")`**.

## New SS3 I/O (development branch)

| Module | Key functions |
|--------|----------------|
| `ss-run.R` | `ssInputFiles`, `copySsInputs`, `readSs3Run`, `runSs3Dir` |
| `ss-likelihood.R` | `extractLikelihoodComponents`, `profileLikelihoodExclude` |
| `ss-profile-beta-grid.R` | `runSs3ProfileGrid`, `importProfileGrid`, `collectProfileLikelihoods` |
| `curve-ss-utils.R` | `curveSsLoadCombined`, `curveSsNeedsEnrichment` |

## SS3 retrospective peel projections

After `r4ss::retro()`, **`runFlevelProjectionsPeels()`** runs four **forecast.ss** scenarios per peel and writes them under each **`retro*`** directory. See **`?runFlevelProjectionsPeels`** and the **ss3-retro-projections** vignette.
