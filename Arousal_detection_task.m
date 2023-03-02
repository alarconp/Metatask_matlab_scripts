
% Script for running Arousal-detection task with affective pictures
% Written by: Paula Alarcón
% Date: 07-Feb-2023

%% Clear workspace and command window
clear all;
clc;

%% Settings

participant_training = false;                       % Set to either: true, or false
trials = 150;                                       % number of trials
participant_random_trial_order = randperm(trials);  % randomize trials for the participant


%% Get participant ID and personal data with input dialog

% Name the fields and specify default answers
prompts = {'ID' 'age' 'gender'};
defaults = {'0' '25' ''};

% Display dialog box and store the answers in an object
infoparticipant = inputdlg(prompts, 'Participant information', 1, defaults);

DATA.ID = infoparticipant{1};
DATA.age = infoparticipant{2};
DATA.gender = infoparticipant{3};

% set subject data path
% path_tosave = [data_path filesep DATA.ID];

%% Settings

if participant_training
    trials = 10;
%     images(1).img = imread('fear_SS_2.jpg');
%     images(2).img = imread('happy_SS_2.jpg');
%     images(3).img = imread('neutral_SS_2.jpg');
%     images(4).img = imread('fear_C_3.jpg');
%     images(5).img = imread('happy_C_3.jpg');
%     images(6).img = imread('neutral_C_3.jpg');
end

  
%index = 0;           % keeps track of completed trials until pause


load ITI;
load trial_seq;
%instructions_text = 'Pause! Starten Sie den nächsten Block mit Tastendruck.'; % to display during break
%break_point = 40    % number of trials to break
%KbQueueCreate;      % Open a keyboard event queue


%% Load the stimuli

images(1).img = imread('fear_SS_2.jpg');
images(2).img = imread('happy_SS_2.jpg');
images(3).img = imread('neutral_SS_2.jpg');
images(4).img = imread('fear_C_3.jpg');
images(5).img = imread('happy_C_3.jpg');
images(6).img = imread('neutral_C_3.jpg');




