clear all

% Preliminary stuff
% check for Opengl compatibility, abort otherwise:
%AssertOpenGL;

% Hiding the mourse cursor
HideCursor;

KbName('UnifyKeyNames');

% Background colour
bgColor   = [128 128 128];

% Get information about the screen and set general things

screenNumber = max(Screen('Screens'));
Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'SkipSyncTests', 1);

% Creating screen etc.
[myScreen, rect] = Screen('OpenWindow', screenNumber, bgColor);

% Input for slide scale
question  = 'How aroused were you?';
%endPoints = {'no at all', 'very much'};
anchors = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9','10'};
SAM_manequin = imread('9_SAMs.jpg');


% The code below creates as slide scale from 0 to 100 for mouse use with center starting position. Length of scale is 99%. 
[position, RT, answer] = slideScale(myScreen, question, rect, anchors, 'scalalength', 0.99, 'device', 'mouse', 'startposition', 'center', 'range', 2 ...
    , 'image', SAM_manequin);

% Close window
Screen('CloseAll') 

