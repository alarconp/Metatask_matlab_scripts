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
[window, windowRect] = Screen('OpenWindow', screenNumber, bgColor);

%% IMAGE and other stuff


%% AROUSAL SCALE

% Input for slide scale
question  = 'How aroused were you?';
%endPoints = {'no at all', 'very much'};
anchors = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
SAM_manequin = imread('9_SAMs.jpg');
scalaLength = 0.855;

% The code below creates as slide scale from 0 to 100 for mouse use with center starting position. Length of scale is 99%. 
[arousal_rating, type_I_RT, answer] = slideScale(window, question, windowRect, anchors, scalaLength, 'device', 'mouse', 'startposition', 'center', 'range', 2 ...
    , 'image', SAM_manequin);

%% CONFIDENCE SCALE

% Input for slide scale
question  = 'Confidence';
%endPoints = {'no at all', 'very much'};
anchors = {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'};
scalaLength = 0.8;

% The code below creates as slide scale from 0 to 100 for mouse use with center starting position. Length of scale is 99%. 
[confidence_rating, type_II_RT, answer] = ConfidenceScale(window, question, windowRect, anchors, scalaLength, 'device', 'mouse', 'startposition', 'center', 'range', 2);


%% LAST SCREEN

% Finish experiment screen
DrawFormattedText(window, 'Click Mouse To End', 'center', 'center', [0,0,0]);
Screen('Flip', window);

% Wait for the user to click the mouse once, to end the trial
[clicks,~,~,whichButton,clickSecs] = GetClicks(screenNumber, 0, 1, inf);
if clicks == 1
    Screen('Close')
    sca % Close the onscreen window
end


% Close window
Screen('CloseAll') 

%%
