% ===============================================
% ECE 6255 - Digital Processing of Speech Signals
%       Georgia Institute of Technology
%                Team 8, main.m
%
% Last Modified Date: 3/15/2025
% ===============================================

clc;
clear;
close all;

% ask user to choose a wav file
[file, path] = uigetfile('*.wav', 'select a speech wav file');

% stop if no file is selected
if isequal(file, 0)
    disp('no file selected')
    return
end

% read the wav file
[x, fs] = audioread(fullfile(path, file));

% convert stereo to mono if needed
if size(x, 2) > 1
    x = mean(x, 2);
end

% normalize the signal
x = x / max(abs(x));

% frame settings
frame_len = round(0.05 * fs);   % 50 ms
hop_len = round(0.01 * fs);     % 10 ms
num_frames = floor((length(x) - frame_len) / hop_len) + 1;

% analysis window
win = hamming(frame_len);

% feature arrays
energy = zeros(num_frames, 1);
power_level = zeros(num_frames, 1);
zcr = zeros(num_frames, 1);
f0 = zeros(num_frames, 1);
voicing = zeros(num_frames, 1);
spec_change = zeros(num_frames, 1);
time_axis = zeros(num_frames, 1);

% pitch search range
min_f0 = 60;
max_f0 = 400;
min_lag = floor(fs / max_f0);
max_lag = ceil(fs / min_f0);

% for spectral change
prev_mag = [];

% process each frame
for k = 1:num_frames
    
    % current frame sample range
    start_idx = (k - 1) * hop_len + 1;
    end_idx = start_idx + frame_len - 1;
    
    % extract frame
    frame = x(start_idx:end_idx);
    frame = frame .* win;
    
    % frame center time
    time_axis(k) = ((start_idx + end_idx) / 2) / fs;
    
    % short time energy
    energy(k) = sum(frame .^ 2);
    
    % average power
    power_level(k) = mean(frame .^ 2);
    
    % zero crossing rate
    zcr(k) = sum(abs(diff(sign(frame)))) / (2 * length(frame));
    
    % magnitude spectrum
    mag = abs(fft(frame));
    mag = mag(1:floor(length(mag)/2));
    
    % spectral change from previous frame
    if isempty(prev_mag)
        spec_change(k) = 0;
    else
        diff_mag = mag - prev_mag;
        spec_change(k) = sum(diff_mag .^ 2) / length(diff_mag);
    end
    prev_mag = mag;
    
    % estimate pitch using autocorrelation
    r = xcorr(frame);
    mid = ceil(length(r) / 2);
    r = r(mid:end);
    
    % search only valid pitch lags
    r_pitch = r(min_lag:max_lag);
    [peak_val, peak_idx] = max(r_pitch);
    best_lag = peak_idx + min_lag - 1;
    pitch_est = fs / best_lag;
    
    % decide voiced or unvoiced
    if peak_val > 0.3 * r(1) && zcr(k) < 0.2
        f0(k) = pitch_est;
        voicing(k) = 1;
    else
        f0(k) = 0;
        voicing(k) = 0;
    end
end

% normalize features
energy = energy / max(energy);
power_level = power_level / max(power_level);
zcr = zcr / max(zcr);

if max(spec_change) > 0
    spec_change = spec_change / max(spec_change);
end

% low level labels
% 0 = silence
% 1 = voiced
% 2 = unvoiced
labels = zeros(num_frames, 1);

% thresholds
silence_th = 0.03;
voiced_power_th = 0.08;
spec_change_th = 0.18;

% classify each frame
for k = 1:num_frames
    if power_level(k) < silence_th
        labels(k) = 0;
    elseif power_level(k) >= voiced_power_th && voicing(k) == 1
        labels(k) = 1;
    else
        labels(k) = 2;
    end
end

% smooth labels to reduce one frame jumps
smooth_labels = labels;
for k = 2:num_frames-1
    if labels(k-1) == labels(k+1) && labels(k) ~= labels(k-1)
        smooth_labels(k) = labels(k-1);
    end
end
labels = smooth_labels;

% low level candidate boundaries
label_boundary_idx = find(diff(labels) ~= 0) + 1;
spec_boundary_idx = find(spec_change > spec_change_th);
low_boundary_idx = unique([label_boundary_idx; spec_boundary_idx]);
low_boundary_times = time_axis(low_boundary_idx);

% find speech frames only
speech_mask = labels ~= 0;

% find speech region starts and ends
speech_diff = diff([0; speech_mask; 0]);
speech_start_idx = find(speech_diff == 1);
speech_end_idx = find(speech_diff == -1) - 1;

% remove very short speech regions
min_region_frames = 4;
keep_regions = (speech_end_idx - speech_start_idx + 1) >= min_region_frames;
speech_start_idx = speech_start_idx(keep_regions);
speech_end_idx = speech_end_idx(keep_regions);

% create envelope for syllable like grouping
smooth_power = movmean(power_level, 5);

% syllable like boundaries
syllable_boundary_idx = [];

for r = 1:length(speech_start_idx)
    
    % region limits
    s1 = speech_start_idx(r);
    s2 = speech_end_idx(r);
    
    % local envelope in this region
    local_env = smooth_power(s1:s2);
    
    % choose a peak distance that is valid for this region
    peak_dist = min(6, floor(length(local_env)/2));

    % make sure it is at least 1
    peak_dist = max(1, peak_dist);

    [pks, locs] = findpeaks(local_env, 'MinPeakDistance', peak_dist, 'MinPeakHeight', 0.12);
    
    % convert local peak positions to full frame positions
    peak_idx = s1 + locs - 1;
    
    % use valleys between peaks as syllable boundaries
    if length(peak_idx) >= 2
        for m = 1:length(peak_idx)-1
            left_idx = peak_idx(m);
            right_idx = peak_idx(m+1);
            
            % find minimum power point between two peaks
            [~, local_min_pos] = min(smooth_power(left_idx:right_idx));
            b_idx = left_idx + local_min_pos - 1;
            syllable_boundary_idx = [syllable_boundary_idx; b_idx];
        end
    end
end

syllable_boundary_idx = unique(syllable_boundary_idx);
syllable_boundary_times = time_axis(syllable_boundary_idx);

% phoneme like boundaries
% use sharper local changes inside speech regions
phoneme_boundary_idx = [];

for r = 1:length(speech_start_idx)
    
    s1 = speech_start_idx(r);
    s2 = speech_end_idx(r);
    
    % get low level boundaries inside this speech region
    region_bounds = low_boundary_idx(low_boundary_idx >= s1 & low_boundary_idx <= s2);
    
    % keep boundaries that are not too close together
    if ~isempty(region_bounds)
        kept = region_bounds(1);
        for m = 2:length(region_bounds)
            if region_bounds(m) - kept(end) >= 2
                kept = [kept; region_bounds(m)];
            end
        end
        phoneme_boundary_idx = [phoneme_boundary_idx; kept];
    end
end

phoneme_boundary_idx = unique(phoneme_boundary_idx);
phoneme_boundary_times = time_axis(phoneme_boundary_idx);

% word like boundaries
% treat longer silent gaps as word separators
word_boundary_idx = [];

for r = 1:length(speech_start_idx)-1
    
    % gap between speech regions
    gap_frames = speech_start_idx(r+1) - speech_end_idx(r) - 1;
    gap_time = gap_frames * hop_len / fs;
    
    % if the silence gap is long enough call it a word boundary
    if gap_time >= 0.15
        word_boundary_idx = [word_boundary_idx; speech_start_idx(r+1)];
    end
end

word_boundary_idx = unique(word_boundary_idx);
word_boundary_times = time_axis(word_boundary_idx);

% make sure word boundaries are a subset of phoneme like boundaries
for i = 1:length(word_boundary_idx)
    if ~ismember(word_boundary_idx(i), phoneme_boundary_idx)
        phoneme_boundary_idx = [phoneme_boundary_idx; word_boundary_idx(i)];
    end
end

phoneme_boundary_idx = unique(phoneme_boundary_idx);
phoneme_boundary_times = time_axis(phoneme_boundary_idx);

% create sample based track for plotting
seg_track = zeros(length(x), 1);

for k = 1:num_frames
    start_idx = (k - 1) * hop_len + 1;
    end_idx = min(start_idx + hop_len - 1, length(x));
    seg_track(start_idx:end_idx) = labels(k);
end

% time axis for full signal
t = (0:length(x)-1) / fs;

% print results
disp('low level boundary times in seconds:')
disp(low_boundary_times)

disp('phoneme like boundary times in seconds:')
disp(phoneme_boundary_times)

disp('syllable like boundary times in seconds:')
disp(syllable_boundary_times)

disp('word like boundary times in seconds:')
disp(word_boundary_times)

% plot results
figure

subplot(7,1,1)
plot(t, x)
xlabel('time (s)')
ylabel('amp')
title('speech signal')
grid on
hold on
for i = 1:length(phoneme_boundary_times)
    xline(phoneme_boundary_times(i), '--')
end
hold off

subplot(7,1,2)
plot(time_axis, power_level)
xlabel('time (s)')
ylabel('power')
title('power level')
grid on
hold on
for i = 1:length(syllable_boundary_times)
    xline(syllable_boundary_times(i), '--')
end
hold off

subplot(7,1,3)
plot(time_axis, zcr)
xlabel('time (s)')
ylabel('zcr')
title('zero crossing rate')
grid on

subplot(7,1,4)
plot(time_axis, f0)
xlabel('time (s)')
ylabel('hz')
title('fundamental frequency')
grid on

subplot(7,1,5)
plot(time_axis, spec_change)
xlabel('time (s)')
ylabel('change')
title('power spectrum change')
grid on
hold on
for i = 1:length(phoneme_boundary_times)
    xline(phoneme_boundary_times(i), '--')
end
hold off

subplot(7,1,6)
plot(t, seg_track)
xlabel('time (s)')
ylabel('class')
title('voiced unvoiced silence segmentation')
yticks([0 1 2])
yticklabels({'silence','voiced','unvoiced'})
grid on
hold on
for i = 1:length(word_boundary_times)
    xline(word_boundary_times(i), 'k-', 'LineWidth', 1.5)
end
hold off

subplot(7,1,7)
plot(time_axis, smooth_power)
xlabel('time (s)')
ylabel('env')
title('smoothed power for syllable like segmentation')
grid on
hold on
for i = 1:length(syllable_boundary_times)
    xline(syllable_boundary_times(i), '--')
end
for i = 1:length(word_boundary_times)
    xline(word_boundary_times(i), 'k-', 'LineWidth', 1.5)
end
hold off