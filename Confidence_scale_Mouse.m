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
Screen('Preference', 'SkipSyncTests', 1);    % skips the sync tests
Screen('Preference', 'VisualDebugLevel', 0); % disables all visual warning

% Creating screen etc.
[myScreen, rect] = Screen('OpenWindow', screenNumber, bgColor);

% Input for slide scale
question  = 'Confidence';
%endPoints = {'no at all', 'very much'};
anchors = {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'};
scalaLength = 0.8;

% The code below creates as slide scale from 0 to 100 for mouse use with center starting position. Length of scale is 99%. 
[position, RT, answer] = ConfidenceScale(myScreen, question, rect, anchors, scalaLength, 'device', 'mouse', 'startposition', 'center', 'range', 2);

% Close window
Screen('CloseAll') 

