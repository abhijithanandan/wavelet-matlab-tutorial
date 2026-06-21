# Wavelet-CNN

A MATLAB/Octave implementation of the wavelet scattering network idea from Fujieda
et al. (2018). The network uses predefined Haar wavelet filters to compute a
multi-level scattering transform, then fits a pseudo-inverse classifier to the
resulting features. No toolboxes, no gradient-based training, and no external
dependencies are required. It runs in GNU Octave or MATLAB.

## Start here

Open the `tutorial/` folder. It walks through the full pipeline step by step on a
small six-class texture dataset: loading images, computing the scattering transform,
fitting the classifier, and comparing against raw pixels and a trained softmax
baseline.

```matlab
cd tutorial
run_tutorial
```

The tutorial reaches about 65% test accuracy on six KTH-TIPS texture classes,
compared to about 45% for a raw-pixel baseline with the same classifier. No training
loop is involved.

## Advanced reference

`matlab/run_full_wscat.m` is a full port with a deeper scattering cascade, tighter
pooling, and a more controlled train/test split. It uses the same shared core
functions and reaches about 85% test accuracy on the same six classes.

```matlab
cd matlab
run_full_wscat
```

## Layout

| Path | Contents |
|------|----------|
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
