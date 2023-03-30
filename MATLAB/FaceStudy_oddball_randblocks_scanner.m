  %Face Study 
% Part 2: oddball task
% cond1: rel neutral standard = code 201
% cond2: rel fear standard = code 202
% cond3: str neutral standard = code 203
% cond4: str fear standard = code 204


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear workspace and command window
clear all;
clc;

%Screen('Preference','TextEncodingLocale','UTF-8');
%% Controlling parallel port and sending triggers to biopac
%create an instance of the io64 object
ioObj = io64;
%
% initialize the interface to the inpoutx64 system driver
io64_status = io64(ioObj);
port_address = hex2dec('0378');
% init value to 0
io64(ioObj,port_address,0);   
%%
%***************************

% Screen('Preference', 'SkipSyncTests', 1);    % skips the sync tests
% Screen('Preference', 'VisualDebugLevel', 0); % disables all visual warning


%% Window and Font

%Screen('TextFont',w,'Arial');
white = [255,255,255];
gray = [223,223,223];
%gray  = [180,180,180];
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

fprintf(fid,'Trial\tblock_no\tcondition\tResponse\tKey pressed\tCondition\tReaction time\tstim_time\r\n') % writing headers to file

%% load pics, vectors, shuffle conditions
load blockorder1;
blockorder = blockorder1;  %order of blocks

%load impl_oddb_seq;
load oddball_seq_50;

instructions_text = 'Pause! Starten Sie den nächsten Block mit Tastendruck.'; % to display during break

% load images
images(1,1).img = imread('neutral_SS_2.jpg');      % rel neutral standard; 1=standard, 2=deviant, 3=target
images(1,2).img = imread('fear_SS_2.jpg');
images(1,3).img = imread('neutral_SS_2_glasses.jpg');

images(2,1).img = imread('fear_SS_2.jpg');
images(2,2).img = imread('neutral_SS_2.jpg');
images(2,3).img = imread('fear_SS_2_glasses.jpg');

images(3,1).img = imread('neutral_C_3.jpg');
images(3,2).img = imread('fear_C_3.jpg');
images(3,3).img = imread('neutral_C_3_glasses.jpg');

images(4,1).img = imread('fear_C_3.jpg');
images(4,2).img = imread('neutral_C_3.jpg');
images(4,3).img = imread('fear_C_3_glasses.jpg');



%% Start



index = 0           % keeps track of completed trials until pause
trials = 50         % number of total trial count per block
block_count = 1;    %blocks
total_block_count = 32;

KbQueueCreate;      % Open a keyboard event queue
    
    win = Screen('OpenWindow', whichscreen);
    HideCursor;
    
    Screen('FillRect', win, bgcol);
    Screen('Flip', win)
    

        instr1_text = 'Es folgt nun der zweite Teil des Experiments. \n Drücken Sie die Taste wenn Sie eine Sonnenbrille sehen.' 
              
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
                        if (strcmp(key(1),'5') == 1) % added to allow escaping during testing
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
           
    
   
   % waits for a trigger from the scanner; to bypass this, type '5'
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
    io64(ioObj,port_address,201);   %sends start trigger 255
    fprintf(fid,'%.10d\r\n', t_start);
    
  
 try
     for block_count = 1 : total_block_count
         block = blockorder(block_count);   %condition
         WaitSecs(10);
         
            for trial_count = 1:trials
                
            blocktrigger = 0;               % resets blocktrigger
            index = index + 1;              % increments index
            cond = oddball_seq(block_count,trial_count);
            img = images(block,cond).img;     % selects image from vector

            tex = Screen('MakeTexture', win, img); % creating a texture from the image
            Screen('DrawTexture', win, tex);    % drawing the texture onto the screen
            t_img = Screen('Flip', win);        % displaying screen with image
            t_end = t_img + 0.2;                  % presentation duration picture 
            t_stim = GetSecs();


           % send the image number as trigger to port
             io64(ioObj,port_address,cond);
             t_log = (t_stim - t_start);

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
            
            io64(ioObj,port_address,0); %resets port
            Screen('FillRect', win, bgcol);
            DrawFormattedText(win, '+', 'center', 370, black);
            stim_end = Screen('Flip', win); % black out the stimulus
            
            blocktrigger = block+40;
            io64(ioObj,port_address,blocktrigger); %send block trigger

            % this loop retrieves responses during the ITI        
            while GetSecs < t_end + 0.5;
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

            fprintf(fid,'%d\t%d\t%d\t%s\t%s\t%d\t%.10d\t%.10d\r\n', trial_count, block_count, block, response, key, cond, rt, t_log); % writing results to file
                %changed emotion to cond

            Screen('FillRect', win, bgcol); %blanking out screen
            t = Screen('Flip', win);

            io64(ioObj,port_address,0); %resets port output to 0 so that next trigger can be sent
           
            trial_count = trial_count + 1;
            end
   


%  %% break   
            if mod (block_count,4) == 0 

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
                        if (strcmp(key(1),'5') == 1) % added to allow escaping during testing
                           remainingtime > 0; 
                        else 
                            remainingtime = 0;
                        end
                    end
                end
   

                Screen('FillRect', win, bgcol);
                Screen('Flip', win); % resets screen before next stimulus
                
                KbQueueStart;	% Start collecting keyboard events
                    trigger = '';
                    while strcmp(trigger,'5') == 0
                        [event, ~] = KbEventGet([],0.01);
                        if ~isempty(event)
                            trigger = KbName(event.Keycode);
                            trigger = trigger(1);
                       %     t_trigger = event.Time;
                        end
                    end
             %  WaitSecs(2);
 
            end

        
     end
    block_count = block_count +1;
 end 
WaitSecs(15); 
sca;
KbQueueRelease;
fclose(fid);