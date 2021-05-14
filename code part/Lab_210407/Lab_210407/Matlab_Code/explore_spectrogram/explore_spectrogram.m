close all;
clear all

% Read .wav file.
[x sample_rate] = audioread('one_sine.wav');

SpectrogramExample( x, sample_rate);

