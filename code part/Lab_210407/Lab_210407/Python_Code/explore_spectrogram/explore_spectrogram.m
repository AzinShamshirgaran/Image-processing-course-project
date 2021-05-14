close all;
clear all

% Read .wav file.
%[x sample_rate] = audioread('one_sine.wav');
[x sample_rate] = audioread('Xeno_Canto_WilsonsWarbler.mp3');

SpectrogramExample( x, sample_rate);

