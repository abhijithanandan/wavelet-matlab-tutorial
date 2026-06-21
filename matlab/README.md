# Advanced Wavelet Scattering Reference

This folder contains the advanced full-port wavelet scattering network. It goes
deeper than the tutorial: a 4-level cascade on the approximation sub-band
(first-order scattering) plus one extra decomposition of each first-level detail
band (second-order scattering). Each kept sub-band is reduced to a single global
average, giving a fixed-length feature vector per image. The readout is a
pseudo-inverse linear classifier with Tikhonov regularisation: no iterative
training, no toolboxes.

The dataset used is KTH-TIPS texture patches, stored in
`tutorial/data/textures_small.mat`. That is simply where the data file ships;
the code in `matlab/` depends only on `common/`, not on `tutorial/`.

## What the second-order terms add

At the first decomposition level, each of the three detail bands (horizontal,
vertical, diagonal) is non-linearly rectified (absolute value) and then passed
through a second Haar decomposition. The three high-frequency sub-bands of that
second decomposition are pooled and appended to the feature vector. This gives
the network some sensitivity to the spatial arrangement of fine-detail energy,
which a single-order scattering transform cannot capture.

## Shared code

`matlab/` reuses `common/haar_dwt.m` and `common/pinv_classify.m` directly.
There is no copy of the Haar transform or the classifier in this folder. Both
the tutorial and the advanced port run the same underlying code.

## Running

From this folder:

```
cd matlab
octave --no-gui -q run_full_wscat.m
```

`run_full_wscat.m` adds `../common` to the Octave path, loads the texture data,
extracts features with `wscat.features`, fits the pseudo-inverse model, and
prints the feature dimension and test accuracy.

## Difference from the tutorial

| | Tutorial | Advanced (this folder) |
|---|---|---|
| DWT levels | 3 | 4 |
| Scattering order | 1 | 2 (extra decomposition at level 1) |
| Feature dimension | 10 | 25 |
| Readout | pinv (shared) | pinv (shared) |
| Toolboxes | none | none |

## Tests

`tests/test_haar_reference.m` checks the shared `haar_dwt` against reference
values derived by hand for a fixed 4x4 input. It verifies all four sub-bands
(LL, LH, HL, HH) to numerical precision and is independent of the per-block
unit test already in `common/`.

`tests/test_wscat_features.m` checks that `wscat.features` returns the correct
number of rows, a positive integer feature dimension, and that a constant image
produces near-zero detail features.

Run both from the repo root:

```
octave --no-gui -q --eval "addpath('common','matlab','tests'); test_haar_reference; test_wscat_features; disp('PASS')"
```
