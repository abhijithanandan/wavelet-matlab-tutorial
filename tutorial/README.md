# Wavelet Transform Tutorial

This tutorial walks through a small wavelet-transform network applied to texture
classification, the representation used in the 2018 Wavelet CNN paper. The goal is
to make the idea concrete: fixed wavelet filters build a feature representation, and
a closed-form pseudo-inverse solve replaces iterative training. No toolboxes are
required; it runs in MATLAB or GNU Octave. An optional wavelet scattering transform
variant (a deeper, second-order extension) is in the `matlab/` folder.

## What it demonstrates

- How one level of the Haar wavelet transform splits an image into an approximation
  sub-band and three detail sub-bands (horizontal, vertical, diagonal edges).
- How cascading that transform across multiple levels and pooling the detail
  responses builds a compact, multi-resolution feature vector.
- That a pseudo-inverse classifier fitted to those features reaches about 65% test
  accuracy on six texture classes without a single gradient step.
- How that compares to raw pixels (about 20 percentage points lower) and to a
  trained softmax classifier on the same features.

## How to run

Open MATLAB (or Octave) from inside the `tutorial/` folder and type:

```matlab
run_tutorial
```

The script adds the shared `common/` folder to the path automatically. Output is
printed to the console; figures are written to `figures/` and shown on screen when
a display is available.

### Live Script (MATLAB only)

In MATLAB, open `run_tutorial.m`, go to Save As, and choose Live Script (.mlx).
Each `%%` line becomes a separate section you can run interactively. This is the
recommended way to step through the tutorial one block at a time.

## Steps

**Step 1: Load the textures.**
Loads `data/textures_small.mat` (240 training images, 240 test images, 64x64
grayscale, six texture classes). Prints the counts and saves a contact sheet of
twelve examples to `figures/example_textures.png`.

**Step 2: One level of the wavelet transform.**
Applies `haar_dwt` to a single training image and displays the four sub-bands: the
low-pass approximation (LL) and the three detail bands (LH, HL, HH), showing what
edges each one responds to.

**Step 3: The multi-level wavelet transform.**
Calls `scatter_features` with three levels and a 4x4 pooling grid. Each level
feeds the LL approximation from the previous level back into `haar_dwt`, collects
the pooled magnitude of the detail bands, and at the end appends the final
approximation. The result is a 160-element feature vector per image. This is the
ordinary multi-level wavelet transform from the 2018 paper.

**Step 4: Classify and evaluate.**
Fits a pseudo-inverse classifier (`pinv_classify`) on the training features and
evaluates it on the test set. Prints test accuracy and a confusion matrix.

**Step 5: Wavelet features vs. raw pixels.**
Repeats the same classifier on the raw pixel values (flattened to a vector) and
compares. The wavelet features win by a clear margin.

**Step 6: Pseudo-inverse vs. random weights.**
Swaps in random output weights (no solve at all) on the same fixed features to show
that the solve is what gives the classifier its accuracy, not the feature
representation alone.

**Step 7: Pseudo-inverse vs. trained classifier.**
Fits a softmax classifier (`softmax_classify`) by gradient descent on the same
features and compares. Training recovers extra accuracy at the cost of iteration.

## Files

| File | Location | Role |
|------|----------|------|
| `run_tutorial.m` | `tutorial/` | The main tutorial script |
| `scatter_features.m` | `tutorial/` | Multi-level wavelet transform: loops `haar_dwt`, pools detail bands |
| `montage_image.m` | `tutorial/` | Lays out a stack of images into a contact sheet |
| `upscale.m` | `tutorial/` | Nearest-neighbour upscale for display |
| `show_save.m` | `tutorial/` | Saves a figure to PNG (and shows it when display is available) |
| `softmax_classify.m` | `tutorial/` | Softmax classifier trained by gradient descent |
| `haar_dwt.m` | `common/` | One-level 2D Haar wavelet transform |
| `pinv_classify.m` | `common/` | Pseudo-inverse least-squares classifier |
| `data/textures_small.mat` | `tutorial/data/` | Bundled texture dataset (see below) |

`haar_dwt` and `pinv_classify` live in the sibling `common/` folder. The tutorial
script adds that folder to the path with `addpath('../common')` at the top.

## Dataset

The images are a subset of the KTH-TIPS texture database (KTH CVAP lab). KTH-TIPS
is a freely available grayscale texture collection intended for research use. The
six classes used here are the first six alphabetically: aluminium_foil, brown_bread,
corduroy, cotton, cracker, linen. Each class has 40 training images and 40 test
images at 64x64 pixels.

Reference: M. Fritz, E. Hayman, B. Caputo, J.-O. Eklundh, "The KTH-TIPS database",
2004 (KTH CVAP).

## Things to try

- **Change the number of wavelet levels.** In the `scatter_features` calls in
  Steps 3 and 5, the second argument is `n_levels` (currently 3). Try 1, 2, or 4
  and watch how feature size and accuracy change.

- **Change the pooling grid.** The third argument is `g`, the side length of the
  pooling grid per sub-band (currently 4, giving a 4x4 grid). Try 2 or 8.

- **Change the regularisation.** In the `pinv_classify('fit', ...)` calls, the
  fourth argument is `lambda` (currently 1e-2). Try 1e-4 or 1e-1 to see how
  regularisation affects the result.

- **Add more classes.** The dataset contains additional texture classes. Edit
  `tools/make_texture_subset.m` (or the equivalent data-preparation script) to
  include more classes and rerun.
