
clear all

% Preliminary stuff
% check for Opengl compatibility, abort otherwise:
%AssertOpenGL;

% Hiding the mourse cursor
HideCursor;

KbName('UnifyKeyNames');

% Back ground colour
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

% % The code below creates as slide scale form 0 to 100 for keyboard use with
% % left starting position. The left and right control keys are used to
% % control the slider and enter is used to log the response. 
% [position, RT, answer] = slideScale(myScreen, ...
%     question, ...
%     rect, ...
%     endPoints, ...
%     'device', 'keyboard', ...
%     'stepsize', 10, ...
%     'responseKeys', [KbName('return') KbName('LeftControl') KbName('RightControl')], ...
%     'startposition', 'left', ...
%     'range', 2);

% The code below creates as slide scale form -100 to 100 for mouse use with
% right starting position. Length of scale is 99%. 
[position, RT, answer] = slideScale(myScreen, ...
    question, ...
    rect, ...
    anchors, ...
    'scalalength', 0.99, ... 
    'device', 'mouse', ...
    'startposition', 'right', ...
    'range', 1);

% Close window
Screen('CloseAll') 