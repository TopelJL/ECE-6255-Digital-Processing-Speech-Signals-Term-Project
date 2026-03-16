function [x, fs, fileName] = load_audio_file(filePath)
%LOAD_AUDIO_FILE Read WAV file, convert to mono, normalize safely.

    [x, fs] = audioread(filePath);
    [~, name, ext] = fileparts(filePath);
    fileName = [name ext];

    % Convert stereo to mono if needed
    if size(x, 2) > 1
        x = mean(x, 2);
    end

    % Remove DC bias
    x = x - mean(x);

    % Safe normalization
    peakVal = max(abs(x));
    if peakVal > 0
        x = x / peakVal;
    end
end