# Wavelet-CNN

A MATLAB/Octave implementation of the Wavelet CNN idea from Fujieda et al. (2018).
That paper uses an ordinary multi-level wavelet transform to feed the network. Here
the learned convolutions are replaced by predefined Haar wavelet filters, and the
final classifier is a single pseudo-inverse solve instead of training. An optional
wavelet scattering transform variant (Mallat-style, with a second-order term) is
also included. No toolboxes, no gradient-based training, and no external
dependencies are required. It runs in GNU Octave or MATLAB.

## Start here

Open the `tutorial/` folder. It walks through the full pipeline step by step on a
small six-class texture dataset: loading images, computing the multi-level wavelet
transform (the 2018 paper's representation), fitting the classifier, and comparing
against raw pixels and a trained softmax baseline.

```matlab
cd tutorial
run_tutorial
```

The tutorial reaches about 65% test accuracy on six KTH-TIPS texture classes,
compared to about 45% for a raw-pixel baseline with the same classifier. No training
loop is involved. It ends by displaying a set of test textures with the predicted
and true class for each, so you can see the actual predictions and where the
network slips, not just the score.

## Advanced reference

`matlab/run_full_wscat.m` is the optional wavelet scattering transform variant
(Mallat-style): a deeper cascade with a second-order term that re-decomposes the
detail bands. This is the "wavelet scattering transform can be used" path, distinct
from the paper's ordinary wavelet transform in the tutorial. It uses the same shared
core functions and reaches about 85% test accuracy on the same six classes.

```matlab
cd matlab
run_full_wscat
```

## Compare the representations

`compare_approaches.m` runs all three representations on the same textures with the
same pseudo-inverse readout and prints the accuracy side by side, so the progression
is visible in one place. Run it from the repo root:

```matlab
compare_approaches
```

```
  raw pixels             45.4%
  wavelet transform      65.4%
  wavelet scattering     85.0%
```

## Layout

| Path | Contents |
|------|----------|
| `compare_approaches.m` | One-glance accuracy ladder: raw pixels vs first-order vs second-order wavelet |
| `common/` | Shared core: `haar_dwt.m` (one-level 2D Haar DWT), `pinv_classify.m` (pseudo-inverse classifier) |
| `tutorial/` | Student tutorial: `run_tutorial.m`, `scatter_features.m`, figure helpers, bundled data, `README.md` |
| `matlab/` | Advanced full port: `+wscat/features.m`, `run_full_wscat.m`, `README.md` |
| `tools/` | Dev utilities: `make_texture_subset.m` (builds the bundled `.mat` from raw images) |
| `tests/` | Unit tests (7 files) and `run_tests.m` (aggregate runner) |
| `scripts/` | `remote-run.sh` (rsync + SSH helper for running on a remote Octave host) |

## Running the tests

From the repo root:

```bash
octave --no-gui -q tests/run_tests.m
```

Or via the remote runner:

```bash
scripts/remote-run.sh "octave --no-gui -q tests/run_tests.m"
```

Expected output: seven `ok` lines and `All 7 tests passed.`

## Sources

**Method:** S. Fujieda, K. Takayama, T. Hachisuka, "Wavelet Convolutional Neural
Networks", arXiv:1805.08620, 2018.

**Keras reference implementation:** H. N. Nkanta,
github.com/happymondaynkanta/Wavelet-Convolutional-Neural-Network-Using-Keras

**Dataset:** M. Fritz, E. Hayman, B. Caputo, J.-O. Eklundh, "The KTH-TIPS
database", KTH CVAP, 2004. The bundled subset uses six classes (aluminium_foil,
brown_bread, corduroy, cotton, cracker, linen) at 64x64 pixels.
