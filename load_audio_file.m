% =================================================================
%       ECE 6255 Digital Signal Speech Processing Term Project
%                   Georgia Institute of Technology
%                        load_audio_file.m
% 
%           Team 8: Jaxon Topel, Adrian Cruz, Michael Ritz
% =================================================================

function [x, fs, fileName] = load_audio_file(filePath)
% load wav file, convert to mono, remove dc, and normalize

    % read audio file
    [x, fs] = audioread(filePath);

    % get file name with extension
    [~, name, ext] = fileparts(filePath);
    fileName = [name ext];

    % convert to mono if stereo
    if size(x, 2) > 1
        x = mean(x, 2);
    end

    % remove dc offset
    x = x - mean(x);

    % normalize signal to [-1, 1]
    peakVal = max(abs(x));
    if peakVal > 0
        x = x / peakVal;
    end
end
