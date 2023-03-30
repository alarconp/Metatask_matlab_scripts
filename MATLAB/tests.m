

close all;
clear;
commandwindow;

% Setup PTB with some default values
PsychDefaultSetup(2);

%Add his line to avoid synchronization error
Screen('Preference', 'SkipSyncTests', 1)

% Add this line to disable visual warning
Screen('Preference', 'VisualDebugLevel', 0); 

mywindow = Screen('OpenWindow',2, [255/2,255/2,255/2]);
Screen('DrawText', mywindow, 'Hello World', 200, 100, [0,0,0]);
Screen('Flip', mywindow);
WaitSecs(1);
sca
