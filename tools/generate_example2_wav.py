"""Create example2.wav (16 kHz mono) and matching frame-level ground-truth CSV."""
import csv
import math
import struct
import wave

FS = 16000
OUT_WAV = "../example_wavs/example2.wav"
OUT_CSV = "../evaluation/ground_truth_example2.csv"

# Durations (s): silence, voiced (sine), unvoiced (noise)
SIL = 0.45
VOI = 0.85
UNV = 0.75

# Must match params.m defaults used in evaluation
FRAME_SEC = 0.025
HOP_SEC = 0.010


def main():
    n_sil = int(SIL * FS)
    n_voi = int(VOI * FS)
    n_unv = int(UNV * FS)
    n = n_sil + n_voi + n_unv
    x = [0] * n
    f0 = 120.0
    for i in range(n_sil, n_sil + n_voi):
        t = (i - n_sil) / FS
        v = 0.45 * math.sin(2 * math.pi * f0 * t)
        x[i] = int(max(-32767, min(32767, round(v * 32767))))
    rng = 0xACE1
    for i in range(n_sil + n_voi, n):
        rng = (1103515245 * rng + 12345) & 0x7FFFFFFF
        x[i] = int((rng / 0x7FFFFFFF - 0.5) * 8000)

    import os

    os.makedirs(os.path.dirname(OUT_WAV), exist_ok=True)
    os.makedirs(os.path.dirname(OUT_CSV), exist_ok=True)
    with wave.open(OUT_WAV, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FS)
        w.writeframes(b"".join(struct.pack("<h", s) for s in x))

    frame_len = max(1, round(FRAME_SEC * FS))
    hop_len = max(1, round(HOP_SEC * FS))
    num_frames = (n - frame_len) // hop_len + 1
    rows = []
    for k in range(num_frames):
        start = k * hop_len
        mid = start + frame_len // 2
        if mid < n_sil:
            lab = 0
        elif mid < n_sil + n_voi:
            lab = 1
        else:
            lab = 2
        rows.append((k + 1, lab))

    with open(OUT_CSV, "w", newline="", encoding="utf-8") as f:
        wcsv = csv.writer(f)
        wcsv.writerow(["frame_index", "label"])
        wcsv.writerows(rows)


if __name__ == "__main__":
    main()
