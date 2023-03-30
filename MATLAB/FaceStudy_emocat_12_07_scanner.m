  %Face Study 
% Part 1: emotion categorisation task
% 2 Identity x 3 emotion design
% button press for emotion categorisation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear workspace and command window
clear all;
clc;

%% Controlling parallel port and sending triggers to biopac
% %create an instance of the io64 object
% ioObj = io64;
% %
% % initialize the interface to the inpoutx64 system driver
% io64_status = io64(ioObj);
% port_address = hex2dec('0378');
% % init value to 0
% io64(ioObj,port_address,0);   

%% Psychtoolbox settings

Screen('Preference', 'SkipSyncTests', 1);    % skips the sync tests
Screen('Preference', 'VisualDebugLevel', 0); % disables all visual warning


%% Window and Font

%Screen('TextFont',w,'Arial');
white = [255,255,255];
gray  = [223,223,223];
black = [0,0,0];
background = [30,30,30];

%whichscreen = 0;    
whichscreen = 2;    %setting for scanner
bgcol = background; %setting default background color to black



%% Save Subject Number and Time in Text File
% Insert the subject ID and press OK. By pressing CANCEL the experiment is aborted.
txtfile = [];
fileIsSaved = 0;

while fileIsSaved == 0
    
    subjectID = char(inputdlg('Enter the subject ID!','Subject ID'));
    
    % If the button CANCEL was pressed:
    if isempty(subjectID)
        disp('You pressed CANCEL. Experiment aborted.');
        return;
    end
    
    txtfile = strcat(subjectID,'.txt');
    
    if exist(txtfile,'file')
        % If subject ID already exists, wait for entering a valid one
        h = errordlg('File already exists! Enter another subject ID!','Warning');
        waitfor(h);
    else
        % If subject ID is valid, store it together with date and time
        starttime = datestr(now);
        
        % Open or create new file for reading and writing.
        % Append data to the end of the file.
        fid = fopen(txtfile,'a+');
        fprintf(fid,'SID:\t%s\r\nDate:\t%s\r\nTime:\t%s\r\nVers:\t%s\r\n\r\n',...
            subjectID,starttime(1:11),starttime(13:20),version);
        
        fileIsSaved = 1;
    end
end

fprintf(fid,'Trial\tResponse\tKey pressed\tCondition\tReaction time\tstim_time\r\n') % writing headers to file

% Get the image files for the experiment
    imageFolder = [cd filesep 'images'];
    imgList = dir(fullfile(imageFolder, '*.jpg'));
    imgList = {imgList(:).name};
    numImages = length(imgList);
    imageNameA = 'EM0046.jpg'
    imageNameB = 'EM0369.jpg'

    % Now load the images
    theImageA = imread([imageFolder filesep imageNameA]);
    theImageB = imread([imageFolder filesep imageNameB]);

% images(1).img = imread('EM0046.jpg');
% images(2).img = imread('EM0358.jpg');
% images(3).img = imread('EM0369.jpg');
% images(4).img = imread('EM0384.jpg');
% images(5).img = imread('EM0046.jpg');
% images(6).img = imread('EM0046.jpg');

load ITI;
load trial_seq;
index = 0           % keeps track of completed trials until pause
trials = 240         % number of total trial count = 240, now 6 for trying...
instructions_text = 'Pause! Starten Sie den nächsten Block mit Tastendruck.'; % to display during break
break_point = 40    % number of trials to break
KbQueueCreate;      % Open a keyboard event queue

    
    win = Screen('OpenWindow', whichscreen);
    HideCursor;
    
    Screen('FillRect', win, bgcol);
    Screen('Flip', win)
   
 %% Instructions   
    instr1_text = 'Es folgt nun der erste Teil des Experiments. \n\n Zur Erinnerung:  \n  Zeigefinger = fröhlich \n Mittelfinger = neutral \n Ringfinger = ängstlich  \n\n Weiter mit Tastendruck!' 
              
        Screen('FillRect', win, bgcol);
                DrawFormattedText(win, instr1_text, 'center', 'center', white);
                Screen('Flip', win)
                
                remainingtime = 10000;
                while remainingtime > 0
                    break_time = GetSecs;

                    KbQueueStart;
                    [event, ~] = KbEventGet([],remainingtime);
                    if  event.Pressed
          
                        key = KbName(event.Keycode);
                        if (strcmp(key(1),'5') == 1) %not by scanner
                           remainingtime > 0; 
                        else 
                            remainingtime = 0;
                        end
                    end
                end
   

                Screen('FillRect', win, bgcol);
                Screen('Flip', win); % resets screen before next stimulus
                index = 0;

                WaitSecs(2);
           
    
   
   %% waits for a trigger from the scanner; to bypass this, type '5'
    KbQueueStart;	% Start collecting keyboard events
    trigger = '';
    while strcmp(trigger,'5') == 0
        [event, ~] = KbEventGet([],0.01);
        if ~isempty(event)
            trigger = KbName(event.Keycode);
            trigger = trigger(1);
            t_trigger = event.Time;
        end
    end
    
    t_start = GetSecs();
    KbQueueStop;	% Stop collecting keyboard events
    KbQueueFlush;	% Delete all events stored in queue
    

    WaitSecs(1);
    io64(ioObj,port_address,255);   %sends start trigger 255
    fprintf(fid,'%.10d\r\n', t_start);
    WaitSecs(10);
  
 try   
    for trial_count = 1:trials       
 
        index = index + 1;              % increments index
        cond = trial_seq(trial_count);
        img = images(cond).img;     % selects image from vector
        %img = imread(imgfile);

 

        tex = Screen('MakeTexture', win, img); % creating a texture from the image
        Screen('DrawTexture', win, tex);    % drawing the texture onto the screen
        t_img = Screen('Flip', win);        % displaying screen with image
        t_end = t_img + 1;                  % presentation duration picture = 1sec
        t_stim = GetSecs();
        

       % send the image number as trigger to port
         io64(ioObj,port_address,cond);
         t_log = (t_stim - t_start);
%         
       
        response = '';
        key = '';
        KbQueueStart;	% Start collecting keyboard events

        % this loop retrieves reponses during the stimulus display
        while GetSecs < t_end
            [event, ~] = KbEventGet([],0.01);
            if ~isempty(event);
                key = KbName(event.Keycode);
                response = key(1);
                io64(ioObj,port_address,response);
                t_key = event.Time;
                rt = (t_key - t_img);
            end
        end

        Screen('FillRect', win, bgcol);
        DrawFormattedText(win, '+', 'center', 370, black);
        stim_end = Screen('Flip', win); % black out the stimulus
        
        % this loop retrieves responses during the ITI
        while GetSecs < t_end + ITI(trial_count);
            [event, ~] = KbEventGet([],0.01);
            if ~isempty(event) && isempty(response)
                key = KbName(event.Keycode);
                response = key(1);
                io64(ioObj,port_address,response);
                t_key = GetSecs;
                rt = (t_key - t_img);
            end
        end
        
        KbQueueStop;	% Stop collecting keyboard events
        KbQueueFlush;	% Delete all events stored in queue
 
        % checking if there was no response
        if isempty(response)
                response = 'No response'; % if no key was pressed
                rt = 0;

        end
        

        fprintf(fid,'%d\t%s\t%s\t%d\t%.10d\t%.10d\r\n', trial_count, response, key, cond, rt, t_log); % writing results to file
            %changed emotion to cond

        Screen('FillRect', win, bgcol); %blanking out screen
        t = Screen('Flip', win);
        
        io64(ioObj,port_address,0); %resets port output to 0 so that next trigger can be sent
        
        % administers a break after x trials until key press
        if index == break_point;
            
            keypressed = false;
            Screen('FillRect', win, bgcol);
            DrawFormattedText(win, instructions_text, 'center', 'center', white);
            Screen('Flip', win)
            
            remainingtime = 10000;
                while remainingtime > 0
                    break_time = GetSecs;

                    KbQueueStart;
                    [event, ~] = KbEventGet([],remainingtime);
                    if  event.Pressed
          
                        key = KbName(event.Keycode);
                        if (strcmp(key(1),'5') == 1) % Scanner trigger does not terminate break
                           remainingtime > 0; 
                        else 
                            remainingtime = 0;
                        end
                    end
                    KbQueueStop;
                    KbQueueFlush;
                 end

            
            Screen('FillRect', win, bgcol);
            Screen('Flip', win); % resets screen before next stimulus
            index = 0;
            
            KbQueueStart;	% Start collecting keyboard events
            trigger = '';
            while strcmp(trigger,'5') == 0
                [event, ~] = KbEventGet([],0.01);
                if ~isempty(event)
                    trigger = KbName(event.Keycode);
                    trigger = trigger(1);
                    t_trigger = event.Time;
                end
            end
            KbQueueStop;	% Stop collecting keyboard events
            KbQueueFlush;	% Delete all events stored in queue
            WaitSecs(10);
        end
        
     end

catch error_name
    sca;
    rethrow(error_name)
 end

sca;
KbQueueRelease;
fclose(fid);