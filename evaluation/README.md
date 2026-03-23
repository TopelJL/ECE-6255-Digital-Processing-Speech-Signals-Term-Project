# Frame-level ground truth (optional)

To score `example_wavs/example1.wav` (or any recording):

1. Run `main.m` on the file and note the number of frames (printed indirectly via time axis length, or add `disp(features.num_frames)` temporarily).
2. Label each frame `0` = silence, `1` = voiced, `2` = unvoiced (Audacity labels + spreadsheet, or a simple MATLAB script).
3. Save `ground_truth_example1.csv` with header `frame_index,label` and one row per frame.
4. In MATLAB:  
   `gt = load_ground_truth_csv('evaluation/ground_truth_example1.csv', features.num_frames);`  
   `m = evaluate_segmentation(pred, gt);`

Packaged synthetic reference: `ground_truth_example2.csv` matches `example2.wav` (see `tools/generate_example2_wav.py`).
