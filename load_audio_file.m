function [x, fs, fileName] = load_audio_file(filePath)
%LOAD_AUDIO_FILE Read WAV, mono, remove DC, peak-normalize to [-1, 1].

    [x, fs] = audioread(filePath);
    [~, name, ext] = fileparts(filePath);
    fileName = [name ext];

    if size(x, 2) > 1
        x = mean(x, 2);
    end

    x = x - mean(x);
    peakVal = max(abs(x));
    if peakVal > 0
        x = x / peakVal;
    end
end
