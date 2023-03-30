
% Script for running Arousal-detection task with affective pictures
% Written by: Paula Alarcón
% Date: 07-Feb-2023
 
close all;
clear;
commandwindow;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Add this line to avoid synchronization error
Screen('Preference', 'SkipSyncTests', 1)

% Add this line to disable visual warning
Screen('Preference', 'VisualDebugLevel', 0); 




%% Settings

participant_training = true;                           % Set to either: true, or false
numTrials = 150;                                       % Set number of trials
numConditions = 5;                                     % Set the number of conditions (1: negative high, 2: negative low, 3: neutral, 4: positive low, 5: positive high)
if rem(numTrials,numConditions) ~= 0                   % Check if number of trials is divisible by number of conditions
    error('Unequal number of trials for each condition')
end

% Find a random trial order for the participant, with some constraints:
rng('shuffle')                                      % Seed the random number generator.
participant_trial_sequence = [ones(1,(numTrials/numConditions)) ones(1,(numTrials/numConditions))*2 ones(1,(numTrials/numConditions))*3 ...
    ones(1,(numTrials/numConditions))*4 ones(1,(numTrials/numConditions))*5];  % Set an array of equal numbers of trial types
done = false;
cycles = 0;
maximum_consecutive_trials_per_condition = 3;         %No more than three consecutive same-valence pictures. %No more than three consecutive same-arousal pictures

%tic
while not(done)
    cycles = cycles + 1;
    done = true;
    participant_trial_sequence = participant_trial_sequence(randperm(numTrials));
    for i = (maximum_consecutive_trials_per_condition+1):2:numTrials
        % Detect any runs that have more than 3 consecutive same-trial type
      if participant_trial_sequence(i) == participant_trial_sequence(i-1)...
            & participant_trial_sequence(i) == participant_trial_sequence(i-2)...
            %& participant_trial_sequence(i) == participant_trial_sequence(i-3)...    
          %Uncomment if you want to change it to no more that 4 consecutive trials
        done = false;
      end
    end
end
%toc

%participant_trial_sequence;
cycles;


%%

%----------------------------------------------------------------------
%                       Screen setup
%----------------------------------------------------------------------

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');



%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;

% How long should the image stay up during flicker in time and frames
imageSecs = 1;
imageFrames = round(imageSecs / ifi);

% Duration (in seconds) of the blanks between the images during flicker
blankSecs = 0.25;
blankFrames = round(blankSecs / ifi);

% Make a vector which shows what we do on each frame
presVector = [ones(1, imageFrames) zeros(1, blankFrames)...
    ones(1, imageFrames) .* 2 zeros(1, blankFrames)];
numPresLoopFrames = length(presVector);



%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Keybpard setup
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck([spaceKey escapeKey]);



%----------------------------------------------------------------------
%                      Experimental Image List
%----------------------------------------------------------------------
%% Settings and load stimuli

if participant_training
    numTrials = 6;
end

    % Get the image files for the experiment
    imageFolderP = [cd filesep 'images' filesep 'positive'];
    imgListP = dir(fullfile(imageFolderP, '*.jpg'));
    imgListP = {imgListP(:).name};
    numImagesP = length(imgListP);

%     % Check to see if the number of stimuli is correct.
%     if numTrials ~= numImages
%         if numTrials > numImages
%           error('*** Not enough images ***');
%         elseif numTrials < numImages
%           error('*** Too many images ***');
%         end
%     end

%     imageNameA = 'EM0046.jpg';
%     imageNameB = 'EM0369.jpg';

    % Now load the images
    theImageP1 = imread([imageFolderP filesep 'EM0046.jpg']);
    theImageP2 = imread([imageFolderP filesep 'EM0369.jpg']);


    % Get the image files for the experiment
    imageFolderX = [cd filesep 'images' filesep 'neutral'];
    imgListX = dir(fullfile(imageFolderX, '*.jpg'));
    imgListX = {imgListX(:).name};
    numImagesX = length(imgListX);

%     % Check to see if the number of stimuli is correct.
%     if numTrials ~= numImages
%         if numTrials > numImages
%           error('*** Not enough images ***');
%         elseif numTrials < numImages
%           error('*** Too many images ***');
%         end
%     end

%     imageNameA = 'EM0083.jpg';
%     imageNameB = 'EM0132.jpg';

    % Now load the images
    theImageX1 = imread([imageFolderX filesep 'EM0083.jpg']);
    theImageX2 = imread([imageFolderX filesep 'EM0132.jpg']);



 % Get the image files for the experiment
    imageFolderN = [cd filesep 'images'];
    imgListN = dir(fullfile(imageFolderN, '*.jpg'));
    imgListN = {imgListN(:).name};
    numImagesN = length(imgListN);

%     % Check to see if the number of stimuli is correct.
%     if numTrials ~= numImages
%         if numTrials > numImages
%           error('*** Not enough images ***');
%         elseif numTrials < numImages
%           error('*** Too many images ***');
%         end
%     end

%     imageNameA = 'EM0348.jpg';
%     imageNameB = 'EM0390.jpg';

    % Now load the images
    theImageN1 = imread([imageFolderN filesep 'EM0046.jpg']);
    theImageN2 = imread([imageFolderN filesep 'EM0369.jpg']);



%----------------------------------------------------------------------
%                        Condition Matrix
%----------------------------------------------------------------------

% For this task we have a (1) "positive" condition, and (2) "neutral"
% condition, and (3) "negative" condition.
% We will call this our "trialType"
numConditions = 3;
trialType = [1 2 3];

% % Each condition has two examples (for demo purposes)
numExamples = 2;

% Make a condition matrix
trialLine = repmat(trialType, 1, numExamples);
% exampleLine = sort(repmat(1:numExamples, 1, numConditions));
condMat = [trialLine]; %; exampleLine];

% Shuffle the conditions
shuffler = Shuffle(1:numTrials);
condMatShuff = condMat(:, shuffler);

% Make a  matrix which which will hold all of our results
resultsMatrix = nan(numTrials, 3);
resultsMatrix(:, 1) = condMatShuff';

% Make a directory for the results
resultsDir = [cd '/Results/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end



%----------------------------------------------------------------------
%                        Fixation Cross
%----------------------------------------------------------------------

% Screen Y fraction for fixation cross
crossFrac = 0.0167;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = windowRect(4) * crossFrac;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;


%----------------------------------------------------------------------
%                      Experimental Loop
%----------------------------------------------------------------------

% Start screen
DrawFormattedText(window, 'Press Space To Begin', 'center', 'center', black);
Screen('Flip', window);
KbWait;

for trial = 1:numTrials

    % Get this trials information
    thisTrialType = condMatShuff(1, trial);
    %thisExample = condMatShuff(2, trial);

    % Define the trial type label
    switch thisTrialType
        case 1
            trialTypeLabel = 'positive';
        case 2
            trialTypeLabel = 'neutral';
        case 3
            trialTypeLabel = 'negative';
    end

    % Define the file names for the two pictures of that condition 

%     imageNameA = ['image' num2str(thisExample) '_' trialTypeLabel 'A.jpg'];
%     imageNameB = ['image' num2str(thisExample) '_' trialTypeLabel 'B.jpg'];

    imageNameA = 'EM0046.jpg';
    imageNameB = 'EM0369.jpg';

    % Now load the images
    theImageA = imread([imageFolder filesep imageNameA]);
    theImageB = imread([imageFolder filesep imageNameB]);

    % Make the images into textures
    texA = Screen('MakeTexture', window, theImageA);
    texB = Screen('MakeTexture', window, theImageB);

    % Draw a fixation cross for the start of the trial
    Screen('FillRect', window, grey);

    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);

    Screen('Flip', window);
    WaitSecs(2);

    % This is our drawing loop
    respMade = 0;
    numFrames = 0;
    frame = 0;
    Priority(topPriorityLevel);
    while respMade == 0

        % Increment the number of frames
        numFrames = numFrames + 1;
        frame = frame + 1;
        if frame > numPresLoopFrames
            frame = 1;
        end

        % Decide what we are showing on this frame
        showWhat = presVector(frame);

        % Draw the textures or a blank frame
        if showWhat == 1
            Screen('DrawTexture', window, texA, [], [], 0);
        elseif showWhat == 2
            Screen('DrawTexture', window, texB, [], [], 0);
        elseif showWhat == 0
            Screen('FillRect', window, grey);
        end

        % Flip to the screen
        if numFrames == 1
            vbl = Screen('Flip', window);
        else
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end

        % Poll the keyboard for the space key
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyCode(KbName('space')) == 1
            respMade = 1;
        elseif keyCode(KbName('ESCAPE')) == 1
            sca;
            disp('*** Experiment terminated ***');
            return
        end

    end

    % Calculate the time it took the person to see the change
    timeTakenSecs = numFrames * ifi;

    % Switch to low priority for after trial tasks
    Priority(0);

    % Bin the textures we used
    Screen('Close', texA);
    Screen('Close', texB);

    % Record this in our results matrix
    resultsMatrix(trial, 3) = timeTakenSecs;

end

% Close the onscreen window
sca
return