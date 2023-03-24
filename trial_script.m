
close all;
clear;
commandwindow;

addpath 'C:\Users\kli-lab\Documents\MATLAB\Functions'

% Setup PTB with some default values
PsychDefaultSetup(2);

%Add his line to avoid synchronization error
Screen('Preference', 'SkipSyncTests', 1)

% Add this line to disable visual warning
Screen('Preference', 'VisualDebugLevel', 0); 

% Seed the random number generator.
rng('shuffle')

%----------------------------------------------------------------------
%                       Screen setup
%----------------------------------------------------------------------

screenNumber = max(Screen('Screens')); % Set the screen number to the external secondary monitor if there is one connected

% Define black, white and grey
white = 255;
grey = white/2;
black = 0;
% Alternatively: 
% white = WhiteIndex(screenNumber);
% grey = white / 2;
% black = BlackIndex(screenNumber);

[window, windowRect] = Screen('OpenWindow', screenNumber, [grey,grey,grey]); % Open the screen

Screen('Flip', window); % Flip to clear

ifi = Screen('GetFlipInterval', window); % Query the frame duration
halfFlip = ifi/2;

Screen('TextSize', window, 25); % Set the text size

topPriorityLevel = MaxPriority(window); % Query the maximum priority level

[xCenter, yCenter] = RectCenter(windowRect); % Get the centre coordinate of the window

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set the blend function for the screen


%----------------------------------------------------------------------
%                       Keyboard and Mouse information
%----------------------------------------------------------------------
% 
% % Keyboard setup
% spaceKey = KbName('space');
% escapeKey = KbName('ESCAPE');
% RestrictKeysForKbCheck([spaceKey escapeKey]);
% KbName('UnifyKeyNames');

% Mouse setup
mouseButton = 1;
HideCursor; % Hiding the mourse cursor

%----------------------------------------------------------------------
%                      Experimental Image List
%----------------------------------------------------------------------

imageFolder = [cd filesep 'images']; % Get the image files for the experiment

%----------------------------------------------------------------------
%                        Fixation Cross
%----------------------------------------------------------------------

crossFrac = 0.0167; % Screen Y fraction for fixation cross

fixCrossDimPix = windowRect(4) * crossFrac; % Here we set the size of the arms of our fixation cross

% Now we set the coordinates (these are all relative to zero we will let the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

lineWidthPix = 4; % Set the line width for our fixation cross

%----------------------------------------------------------------------
%                      Trial Sequence
%----------------------------------------------------------------------

% Start First trial screen
DrawFormattedText(window, 'Click Mouse To Begin', 'center', 'center', black);
Screen('Flip', window);

% Wait for the user to click the mouse once, to continue
[clicks,~,~,whichButton,clickSecs] = GetClicks(screenNumber, 0, 1, inf);
if clicks == 1
    clear clicks

    %% FIXATION CROSS for the start of the trial

    Screen('FillRect', window, grey);
    
    % We will present the fixation cross for x seconds
    presSecs = 1;
    waitframes = round(presSecs / ifi);

    % Get an initial screen flip for timing
    onsetTime1Cross = Screen('Flip', window);

  
    % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
    Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter yCenter], 2);

    % Flip to the screen
    onsetTime2Cross  = Screen('Flip', window, onsetTime1Cross + (waitframes - halfFlip) * ifi);

   % Clear the screen after x seconds
    WaitSecs(presSecs);


%% STIMULUS PRESENTATION

    % Define the filename for the trial stimuli
    imageNameA = 'EM0046.jpg';
    theImageLocation = [imageFolder filesep imageNameA];

    % Load the image
    theImageA = imread(theImageLocation);

%     % Get the size of the image
%     [s1, s2, s3] = size(theImage);

    % We will present the image for x seconds
    presSecs = 2;
    waitframes = round(presSecs / ifi);

    % Make the image into a texture
    texA = Screen('MakeTexture', window, theImageA);
    clear theImageA;

    % Draw the image to the screen, unless otherwise specified PTB will draw the texture full size in the center of the screen.
    Screen('DrawTexture', window, texA, [], [], 0);

    % Flip to the screen
    onsetTimeStimuli  = Screen('Flip', window, onsetTime2Cross + (waitframes - halfFlip) * ifi);

    % Clear the screen after x seconds
    WaitSecs(presSecs);

    % Bin the texture we used
    Screen('Close', texA);

end

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


%% AFTER TRIAL 

%     % Switch to low priority for after trial tasks
%     Priority(0);


% % Make a  matrix which which will hold all of our results
% resultsMatrix = nan(numTrials, 3);
% resultsMatrix(:, 1:2) = condMatShuff';
% 
% 
% % Record this in our results matrix
% resultsMatrix(trial, 3) = timeTakenSecs;

%% FINISH EXPERIMENT SCREEN

DrawFormattedText(window, 'Click Mouse To End', 'center', 'center', black);
Screen('Flip', window);

% Wait for the user to click the mouse once, to end the trial
[clicks,~,~,whichButton,clickSecs] = GetClicks(screenNumber, 0, 1, inf);
if clicks == 1
    Screen('Close')
    sca % Close the onscreen window
end


