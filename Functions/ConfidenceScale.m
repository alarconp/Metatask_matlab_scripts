
function [position, RT, answer] = ConfidenceScale(screenPointer, question, rect, anchors, scalaLength, varargin)
%SLIDESCALE This funtion draws a slide scale on a PSYCHTOOLOX 3 screen and returns the
% position of the slider spaced between -100 and 100 as well as the rection time and if an answer was given.
%
%   Usage: [position, secs] = slideScale(ScreenPointer, question, center, rect, endPoints, varargin)
%   Mandatory input:
%    ScreenPointer  -> Pointer to the window.
%    question       -> Text string containing the question.
%    rect           -> Double contatining the screen size.
%                      Obtained with [myScreen, rect] = Screen('OpenWindow', 0);
%    anchors        -> Cell containg the two or three text strings of the left (, middle) and right
%                      end of the scale. Exampe: anchors = {'left', 'middle', 'right'}
%    
%   Varargin:
%    'linelength'     -> An integer specifying the lengths of the ticks in
%                        pixels. The default is 10.
%    'width'          -> An integer specifying the width of the scale line in
%                        pixels. The default is 3.
%    'range'          -> An integer specifying the type of range. If 1,
%                        then the range is from -100 to 100. If 2, then the
%                        range is from 0 to 100. Default is 1. 
%    'startposition'  -> Choose 'right', 'left' or 'center' start position.
%                        Default is center.
%    'scalalength'    -> Double value between 0 and 1 for the length of the
%                        scale. The default is 0.9.
%    'scalaposition'  -> Double value between 0 and 1 for the position of the
%                        scale. 0 is top and 1 is bottom. Default is 0.8.
%    'device'         -> A string specifying the response device. Either 'mouse' 
%                        or 'keyboard'. The default is 'mouse'.
%    'responsekeys'   -> Vector containing keyCodes of the keys from the keyboard to log the
%                        response and move the slider to the right and left. 
%                        The default is [KbName('return') KbName('LeftArrow') KbName('RightArrow')].
%    'stepSize'       -> An integer specifying the number of pixel the
%                        slider moves with each step. Default is 1.
%    'slidercolor'    -> Vector for the color value of the slider [r g b] 
%                        from 0 to 255. The default is red [255 0 0].
%    'scalacolor'     -> Vector for the color value of the scale [r g b] 
%                        from 0 to 255.The default is black [0 0 0].
%    'aborttime'      -> Double specifying the time in seconds after which
%                        the function should be aborted. In this case no
%                        answer is saved. The default is Inf.
%    'image'          -> An image saved in a uint8 matrix. Use
%                        imread('image.png') to load an image file.
%    'displayposition' -> If true, the position of the slider is displayed. 
%                        The default is false. 
%
%   Output:
%    'position'      -> Deviation from zero in percentage, 
%                       with -100 <= position <= 100 to indicate left-sided
%                       and right-sided deviation.
%    'RT'            -> Reaction time in milliseconds.
%    'answer'        -> If 0, no answer has been given. Otherwise this
%                       variable is 1.
%
%   Author: Joern Alexander Quent
%   e-mail: Alex.Quent@mrc-cbu.cam.ac.uk
%   Version history:
%                    1.0 - 4th January 2016 - First draft
%                    1.1 - 18. Feburary 2016 - Added abort time and option to
%                    choose between mouse and key board
%                    1.2 - 5th October 2016 - End points will be aligned to end
%                    ticks
%                    1.3 - 6th January 2017 - Added the possibility to display an
%                    image
%                    1.4 - 5th May 2017 - Added the possibility to choose a
%                    start position
%                    1.5 - 7th November 2017 - Added the possibility to display
%                    the position of the slider under the scale.
%                    1.6 - 27th November 2017 - The function now waits until
%                    all keys are released before exiting. 
%                    1.7 - 28th November 2017 - More than one screen
%                    supported now.
%                    1.8 - 29th November 2017 - Fixed issue that mouse is
%                    not properly in windowed mode.
%                    1.9 - 7th December 2017 - If an image is drawn, the
%                    corresponding texture is deleted at the end.
%                    1.10 - 28th December 2017 - Added the possibility to
%                    choose the type of range (0 to 100 or -100 to 100).
%                    1.11 - 7th May 2019 - Added the possibility to control
%                    the slider with keys only. Use keyboard as devices and
%                    select this keys for this function. In addition,
%                    default for aborttime was changed to Inf and one bug
%                    with slidercolor was fixed. 
%                    1.12 - 13rd January 2020 - Added the possiblity to
%                    have three anchors points (left, middle and right). To
%                    make that possible the displayed position is now moved
%                    above the line (under the question). The relative
%                    position of the question was  also changed to allow 
%                    multiple line questions. 
%% Parse input arguments
% Default values
center        = round([rect(3) rect(4)]/2);
lineLength    = 10;
width         = 5;
%scalaLength   = 0.85;
scalaPosition = 0.55;
center_line = [rect(1) + rect(3)/2, rect(2) + rect(4)*scalaPosition];
%numTicks = 4; % Calculate the number of ticks on each side of the line
%tickPositions = linspace(-scalaLength/2, scalaLength/2, numTicks*2+1); % Calculate the horizontal positions of the ticks relative to the center
tickPositions = linspace(rect(3)*(1-scalaLength), rect(3)*scalaLength, 11);
%tickPositions_left = linspace(center(1) * scalaLength/2, center(1) * scalaLength/10, numTicks);
%tickPositions_right = linspace(center(1) * scalaLength/10, center(1) * scalaLength/2, numTicks);
%tickStartX = center(1) + tickPositions; 
%tickEndX = tickStartX;
%tickStartY = center(2) - lineLength; 
%tickEndY = center(2) + lineLength; 
sliderColor   = [255 255 0];
scaleColor    = [0 0 0];
device        = 'mouse';
aborttime     = Inf;
responseKeys  = [KbName('return') KbName('LeftArrow') KbName('RightArrow')];
GetMouseIndices;
drawImage     = 0;
startPosition = 'center';
displayPos    = false;
rangeType     = 1;
stepSize      = 1;

i = 1;
while(i<=length(varargin))
    switch lower(varargin{i})
        case 'linelength'
            i             = i + 1;
            lineLength    = varargin{i};
            i             = i + 1;
        case 'width'
            i             = i + 1;
            width         = varargin{i};
            i             = i + 1;
        case 'range'
            i             = i + 1;
            rangeType     = varargin{i};
            i             = i + 1;
        case 'startposition'
            i             = i + 1;
            startPosition = varargin{i};
            i             = i + 1;
        case 'scalalength'
            i             = i + 1;
            scalaLength   = varargin{i};
            i             = i + 1;
        case 'scalaposition'
            i             = i + 1;
            scalaPosition = varargin{i};
            i             = i + 1;
        case 'device' 
            i             = i + 1;
            device        = varargin{i};
            i             = i + 1;
        case 'responsekeys'
            i             = i + 1;
            responseKeys  = varargin{i};
            i             = i + 1;
        case 'stepsize'
            i             = i + 1;
            stepSize      = varargin{i};
            i             = i + 1;
        case 'slidercolor'
            i             = i + 1;
            sliderColor   = varargin{i};
            i             = i + 1;
        case 'scalacolor'
            i             = i + 1;
            scaleColor    = varargin{i};
            i             = i + 1;
        case 'aborttime'
            i             = i + 1;
            aborttime     = varargin{i};
            i             = i + 1;
        case 'image'
            i             = i + 1;
            image         = varargin{i};
            i             = i + 1;
            imageSize     = size(image);
            stimuli       = Screen('MakeTexture', screenPointer, image);
            drawImage     = 1; 
        case 'displayposition'
            i             = i + 1;
            displayPos    = varargin{i};
            i             = i + 1;
    end
end

% Sets the default key depending on choosen device
if strcmp(device, 'mouse')
    mouseButton   = 1; % X mouse button
end

%% Checking number of screens and parsing size of the global screen
screens       = Screen('Screens');
if length(screens) > 1 % Checks for the number of screens
    screenNum        = 1;
else
    screenNum        = 0;
end
globalRect          = Screen('Rect', screenNum);

%% Coordinates of scale lines and text bounds
if strcmp(startPosition, 'right')
    x = globalRect(3)*scalaLength;
elseif strcmp(startPosition, 'center')
    x = globalRect(3)/2;
elseif strcmp(startPosition, 'left')
    x = globalRect(3)*(1-scalaLength);
else
    error('Only right, center and left are possible start positions');
end
SetMouse(round(x), round(rect(4)*scalaPosition), screenPointer, 1);

tick_0 = [tickPositions(1) center_line(2) - lineLength tickPositions(1) center_line(2) + lineLength];
tick_1 = [tickPositions(2) center_line(2) - lineLength tickPositions(2) center_line(2) + lineLength];
tick_2 = [tickPositions(3) center_line(2) - lineLength tickPositions(3) center_line(2) + lineLength];
tick_3 = [tickPositions(4) center_line(2) - lineLength tickPositions(4) center_line(2) + lineLength];
tick_4 = [tickPositions(5) center_line(2) - lineLength tickPositions(5) center_line(2) + lineLength];
tick_5 = [tickPositions(6) center_line(2) - lineLength tickPositions(6) center_line(2) + lineLength];
tick_6 = [tickPositions(7) center_line(2) - lineLength tickPositions(7) center_line(2) + lineLength];
tick_7 = [tickPositions(8) center_line(2) - lineLength tickPositions(8) center_line(2) + lineLength];
tick_8 = [tickPositions(9) center_line(2) - lineLength tickPositions(9) center_line(2) + lineLength];
tick_9 = [tickPositions(10) center_line(2) - lineLength tickPositions(10) center_line(2) + lineLength];
tick_10 = [tickPositions(11) center_line(2) - lineLength tickPositions(11) center_line(2) + lineLength];

horzLine   = [rect(3)*scalaLength rect(4)*scalaPosition rect(3)*(1-scalaLength) rect(4)*scalaPosition];

if length(anchors) == 2
    textBounds = [Screen('TextBounds', screenPointer, sprintf(anchors{1})); Screen('TextBounds', screenPointer, sprintf(anchors{2}))];
else
    textBounds = [Screen('TextBounds', screenPointer, sprintf(anchors{1})); Screen('TextBounds', screenPointer, sprintf(anchors{3}))];
end

if drawImage == 1
    rectImage  = [center(1) - imageSize(2)/2 rect(4)*(scalaPosition - 0.05) - imageSize(1) center(1) + imageSize(2)/2 rect(4)*(scalaPosition - 0.05)];
    if rect(4)*(scalaPosition - 0.2) - imageSize(1) < 0
        error('The height of the image is too large. Either lower your scale or use the smaller image.');
    end
end

% Calculate the range of the scale, which will be need to calculate the
% position
scaleRange        = round(rect(3)*(1-scalaLength)):round(rect(3)*scalaLength); % Calculates the range of the scale
scaleRangeShifted = round((scaleRange)-mean(scaleRange));                      % Shift the range of scale so it is symmetrical around zero

%% Loop for scale loop
t0                         = GetSecs;
answer                     = 0;
while answer == 0
    % Parse user input for x location
    if strcmp(device, 'mouse')
        [x,~,buttons,~,~,~] = GetMouse(screenPointer, 1);
    elseif strcmp(device, 'keyboard')
        [~, ~, keyCode] = KbCheck;
        if keyCode(responseKeys(2)) == 1
            x = x - stepSize; % Goes stepSize pixel to the left
        elseif keyCode(responseKeys(3)) == 1
            x = x + stepSize; % Goes stepSize pixel to the right
        end
    else
        error('Unknown device');
    end
    
    % Stop at upper and lower bound
    if x > rect(3)*scalaLength
        x = rect(3)*scalaLength;
    elseif x < rect(3)*(1-scalaLength)
        x = rect(3)*(1-scalaLength);
    end
    
    % Draw image if provided
    if drawImage == 1
         Screen('DrawTexture', screenPointer, stimuli,[] , rectImage, 0);
    end
    
    % Drawing the question as text
    DrawFormattedText(screenPointer, question, 'center', rect(4)*(scalaPosition - 0.1)); 
    
    % Drawing the anchors of the scale as text
    if length(anchors) == 2
        % Only left and right anchors
        DrawFormattedText(screenPointer, anchors{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchors{2}, rightTick(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
    else 
        % Left, middle and right anchors
        DrawFormattedText(screenPointer, anchors{1}, tick_0(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchors{2}, tick_1(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchors{3}, tick_2(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchors{4}, tick_3(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchors{5}, tick_4(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(screenPointer, anchors{6}, tick_5(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Middle point
        DrawFormattedText(screenPointer, anchors{7}, tick_6(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
        DrawFormattedText(screenPointer, anchors{8}, tick_7(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
        DrawFormattedText(screenPointer, anchors{9}, tick_8(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
        DrawFormattedText(screenPointer, anchors{10}, tick_9(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point
        DrawFormattedText(screenPointer, anchors{11}, tick_10(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+40, [],[],[],[],[],[],[]); % Right point

    end
    
    % Drawing the scale
    Screen('DrawLine', screenPointer, scaleColor, tick_0(1), tick_0(2), tick_0(3), tick_0(4), width); % 0 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_1(1), tick_1(2), tick_1(3), tick_1(4), width); % 1 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_2(1), tick_2(2), tick_2(3), tick_2(4), width); % 2 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_3(1), tick_3(2), tick_3(3), tick_3(4), width); % 3 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_4(1), tick_4(2), tick_4(3), tick_4(4), width); % 4 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_5(1), tick_5(2), tick_5(3), tick_5(4), width); % 5 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_6(1), tick_6(2), tick_6(3), tick_6(4), width); % 6 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_7(1), tick_7(2), tick_7(3), tick_7(4), width); % 7 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_8(1), tick_8(2), tick_8(3), tick_8(4), width); % 8 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_9(1), tick_9(2), tick_9(3), tick_9(4), width); % 9 tick
    Screen('DrawLine', screenPointer, scaleColor, tick_10(1), tick_10(2), tick_10(3), tick_10(4), width); % 10 tick
  
    Screen('DrawLine', screenPointer, scaleColor, horzLine(1), horzLine(2), horzLine(3), horzLine(4), width);     % Horizontal line
    
    % The slider
    Screen('DrawLine', screenPointer, sliderColor, x, rect(4)*scalaPosition - lineLength, x, rect(4)*scalaPosition  + lineLength, width);
    
    % Calculates position
    if rangeType == 1
        position = round((x)-mean(scaleRange));           % Calculates the deviation from the center
        position = (position/max(scaleRangeShifted))*100; % Converts the value to percentage
    elseif rangeType == 2
        position = round((x)-min(scaleRange));                       % Calculates the deviation from 0. 
        position = (position/(max(scaleRange)-min(scaleRange)))*100; % Converts the value to percentage
    end

    
    % Display position
    if displayPos
        DrawFormattedText(screenPointer, num2str(round(position)), 'center', rect(4)*(scalaPosition - 0.05)); 
    end
    
    % Flip screen
    Screen('Flip', screenPointer);
    
    % Check if answer has been given
    if strcmp(device, 'mouse')
        secs = GetSecs;
        if buttons(mouseButton) == 1
            answer = 1;
        end
    elseif strcmp(device, 'keyboard')
        [~, secs, keyCode] = KbCheck;
        if keyCode(responseKeys(1)) == 1
            answer = 1;
        end
    end
    
    % Abort if answer takes too long
    if secs - t0 > aborttime 
        break
    end
end
%% Wating that all keys are released and delete texture
KbReleaseWait; %Keyboard
KbReleaseWait(1); %Mouse
if drawImage == 1
    Screen('Close', stimuli);
end
%% Calculating the rection time and the position
RT                = (secs - t0)*1000;                                          % converting RT to millisecond
end
