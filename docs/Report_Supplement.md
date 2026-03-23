# Report supplement (equations & paste-in text)

Use this alongside [`ECE_6255_-_Term_Project.docx`](ECE_6255_-_Term_Project.docx). Copy equations into Word with the equation editor if you prefer typeset math.

## Short-time energy (STE)

For windowed frame \(x_w[n]\), \(n = 0,\ldots,N-1\):

\[
E = \frac{1}{N} \sum_{n=0}^{N-1} x_w^2[n]
\]

## Zero-crossing rate (ZCR)

\[
\mathrm{ZCR} = \frac{1}{2N} \sum_{n=1}^{N-1} \bigl|\operatorname{sgn}(x_w[n]) - \operatorname{sgn}(x_w[n-1])\bigr|
\]

Use a consistent rule for \(\operatorname{sgn}(0)\) (implementation uses \(+1\)).

## Autocorrelation and pitch strength

\[
R(k) = \sum_{n} x_w[n]\,x_w[n+k]
\]

Normalized (correlation coefficient) scaling is used in code (`xcorr(...,'coeff')`). Voicing strength is the maximum in lag indices corresponding to roughly 60–400 Hz at the file’s sampling rate.

## Classification summary

1. If STE (normalized) ≤ adaptive silence threshold → **silence**.  
2. Else if pitch strength high and ZCR ≤ adaptive voiced ZCR cutoff → **voiced**.  
3. Else → **unvoiced**.

## Proofreading checklist

- §1.1.1 heading: **silence**, not “slicence”.  
- Professor: **B.H. Juang** (not “Juan”).  
- Teammate: **Michael Ritz** (same spelling as README).

## Video link (§3.2)

After recording: replace the bracket placeholder in the Word doc with your unlisted YouTube (or Drive) URL.
