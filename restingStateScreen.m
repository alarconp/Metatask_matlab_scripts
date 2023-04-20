% --- Psychtoolbox script to present a fixation cross task ---

% Clear the workspace and the screen
sca;
close all;
clearvars;

% Prompt user to input subject ID
subjectID = input('Enter subject ID: ', 's');

% Set up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% Set up the screen
screenNumber = max(Screen('Screens'));
screenRect = Screen('Rect', screenNumber);
halfScreenRect = screenRect / 1;

backgroundColor = [0.5 0.5 0.5];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, backgroundColor, halfScreenRect);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set up the text
numBlock = 2
textColor = [1 1 1];
textSize = 24;
font = 'Helvetica';
Screen('TextFont', window, font);
Screen('TextSize', window, textSize);

% Show the instruction screen
instructionText = 'In this session, you will be presented with a fixation cross.\n\n All you need to do is empty your mind and look at the fixation cross until the session ends.\n\n Please sit quietly during the sessions.\n\n Press the space bar to start.';
DrawFormattedText(window, instructionText, 'center', 'center', textColor);
Screen('Flip', window);


% Wait for space bar to be pressed
while 1
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('space'))
        break;
    end
end

% Set up the timing and blocks

fixationDuration = 10; % in seconds CHANGE TO 300 FOR EXP
breakDuration = 30; % in seconds
totalDuration = 2 * fixationDuration + breakDuration;
time = GetSecs;


% Present the fixation cross task
for i = 1:numBlock
    % Present the fixation cross
    Screen('DrawLines', window, [-10 10 0 0; 0 0 -10 10], 4, textColor, [xCenter yCenter]);
    timeFlip = Screen('Flip', window);
    startTime = GetSecs;
   %% onset of fixation cross is event code 1

% send trigger pulse "1" = "S1" (LPT = parallel port)
parPulse(hex2dec('d050'));
parPulse(0,0,255,0);
parPulse(0,1,255,0);
parPulse(2,1,3,1e-3);

   % Collect EEG data 

    % Collect any keys pressed during the fixation cross presentation
    keyIsDown = 0;
    while GetSecs - startTime < fixationDuration
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            % Save and store any keys pressed
            response(i).key = KbName(find(keyCode));
            response(i).time = secs - startTime;
        end
    end

   %% second event code for EEG 
% send trigger pulse "2" = "S2" (LPT = parallel port)
parPulse(hex2dec('d050'));
parPulse(0,0,255,0);
parPulse(0,1,255,0);
parPulse(2,2,3,1e-3);

        if i == 1 
        % Show a break screen 
        breakText = 'Break time!\n\n Take a minute to adjust your eyes before the start of the second session \n\n When you are ready, press the space bar to start.';
        DrawFormattedText(window, breakText, 'center', 'center', textColor);
        Screen('Flip', window);
        else
        % Show a goodbye screen
        breakText = 'Thats it for this part!\n\n The experimenter will now come in to start the next experiment.\n\n Press the space bar to start to end this session.';
        DrawFormattedText(window, breakText, 'center', 'center', textColor);
        Screen('Flip', window);
        end 

    % Wait for space bar to be pressed
    while 1
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('space'))
            break;
        end
    end
end 
% Save the data (keypress) 
fileName = ['fixation_cross_data_' subjectID '_' datestr(now, 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(fileName, 'response');

% Save the EEG log file 
fileName = ['restingState_data_' subjectID '_' datestr(now, 'yyyy-mm-dd_HH-MM-SS') '.mat'];
% save(fileName, 'EEG_log_file_name');

% Close the screen
sca;
