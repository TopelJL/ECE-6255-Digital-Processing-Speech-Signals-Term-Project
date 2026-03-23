# ECE 6255 — Digital Processing of Speech Signals (Term Project)

**Course:** ECE 6255A, Georgia Institute of Technology, Spring 2026  
**Instructor:** B.H. Juang  
**Topic:** Speech segmentation — **voiced / unvoiced / silence** (classical DSP, no machine learning)

**Team:** Jaxon Topel, Adrian Cruz, Michael Ritz  

**Repository:** [github.com/TopelJL/ECE-6255-Digital-Processing-Speech-Signals-Term-Project](https://github.com/TopelJL/ECE-6255-Digital-Processing-Speech-Signals-Term-Project)

---

## Requirements

- **MATLAB** R2019b or later recommended (tested with modern releases).
- **No add-ons required** for core segmentation. Optional: *Signal Processing Toolbox* (`findpeaks`); if missing, a small `local_findpeaks.m` fallback is used for syllable-like boundary picking.

---

## Quick start (what classmates should do)

1. Clone the repo:
   ```bash
   git clone https://github.com/TopelJL/ECE-6255-Digital-Processing-Speech-Signals-Term-Project.git
   cd ECE-6255-Digital-Processing-Speech-Signals-Term-Project
   ```
2. Open **MATLAB**.
3. In the Command Window:  
   `cd` to the cloned folder (the directory that contains `main.m`).
4. Run:
   ```matlab
   main
   ```
5. When prompted, pick a `.wav` file (e.g. under `example_wavs/`).

**Outputs**

- A figure with waveform, short-time energy (STE), ZCR, pitch strength, F0 track, and class labels.
- PNG + FIG under `results/` named from your file (e.g. `example1.wav` → `example1.wav_segmentation.png`).

---

## Repository layout

| File / folder | Role |
|---------------|------|
| `main.m` | Entry point: file dialog, full pipeline, prints boundary times. |
| `params.m` | All tunables: frame/hop (ms), Hamming window, adaptive quantiles, smoothing. |
| `load_audio_file.m` | `audioread`, mono, DC removal, peak normalization. |
| `compute_features.m` | Per-frame STE, ZCR, normalized autocorrelation pitch strength, spectral change. |
| `classify_frames.m` | Silence / voiced / unvoiced using **adaptive** STE and ZCR statistics. |
| `smooth_labels.m` | `medfilt1` + minimum run merging on integer labels. |
| `detect_boundaries.m` | Optional coarse boundaries (low-level, syllable-like, word-like gaps). |
| `build_segmentation_track.m` | Expand frame labels to sample-length track for plotting. |
| `plot_segmentation.m` | Multi-panel figure; saves to `results/`. |
| `evaluate_segmentation.m` | Accuracy + 3×3 confusion matrix. |
| `evaluate_example2.m` | Script: scores `example2.wav` vs `evaluation/ground_truth_example2.csv`. |
| `example_wavs/` | `example1.wav` (speech), `example2.wav` (synthetic: silence / tone / noise). |
| `evaluation/` | Ground-truth CSV for example2 + notes for hand-labeling. |
| `tools/` | `generate_example2_wav.py` — regenerates synthetic wav + CSV (Python 3). |

Legacy audio: `Audio FIles/male.wav` (original path with typo) — use `example_wavs/example1.wav` for demos.

---

## Parameters (`params.m`)

- **`frame_dur_sec` / `hop_dur_sec`:** STFT framing (default **25 ms** / **10 ms**).
- **`silence_energy_quantile` / `speech_energy_quantile`:** drive adaptive silence cutoff and “speech” mask for ZCR statistics.
- **`voicing_peak_min`:** minimum normalized autocorrelation peak in the F0 lag band for voiced hypothesis.
- **`zcr_voiced_quantile`:** ZCR threshold relative to speech frames (higher → stricter voiced).
- **`median_filter_frames`:** label smoothing window (odd length recommended; code bumps even up by 1).
- **`min_segment_frames`:** drop very short label runs after the median filter.

If recordings are noisy or quiet, first adjust **`silence_energy_quantile`** and **`voicing_peak_min`**.

---

## Quantitative evaluation

Synthetic clip with known regions:

```matlab
evaluate_example2
```

Writes `results/metrics_example2.txt`, `results/confusion_matrix_example2.png`, and `results/metrics_example2.mat`.

For your own recordings, see `evaluation/README.md` (CSV format + `load_ground_truth_csv`).

---

## Report, slides, and demo video

- **Written report:** [`docs/ECE_6255_-_Term_Project.docx`](docs/ECE_6255_-_Term_Project.docx) (regenerate or extend via [`tools/build_deliverables.py`](tools/build_deliverables.py)); equations also in [`docs/Report_Supplement.md`](docs/Report_Supplement.md).
- **Slides:** [`docs/ECE_6255_-_Term_Project_Video_Slides.pptx`](docs/ECE_6255_-_Term_Project_Video_Slides.pptx).
- **12-minute team video:** script and checklist in [`docs/VIDEO_SCRIPT_12MIN.md`](docs/VIDEO_SCRIPT_12MIN.md). After uploading (e.g. unlisted YouTube), paste the link into report **§3.2** and the demo slide.

---

## References (starting point)

- L. R. Rabiner & R. W. Schafer, *Theory and Applications of Digital Speech Processing*, Pearson, 2011.
- Course notes / Juang materials as cited in the report.

---

## License / use

Educational use for ECE 6255. External code snippets are documented in the report; cite any third-party MATLAB code you add.
