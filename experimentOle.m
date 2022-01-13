% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% ---------------------- VDAC Experiment by Ole ---------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% The experiment consists of two phases: a training phase (a one-armed
% bandit task) and a test phase (task similar to test phase from Anderson
% et al. 2011). In the training phase participants should learn certain
% associations between color and reward. In the second phase we test
% whether this reward values are associated with a task-irrelevant 
% value-driven-attentional capture.

% Many thanks to Brian Anderson for providing the stimuli they used in
% their study!

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% set screen resolution to 1920, 1080, 60hz
% SetResolution(0,1920,1080,60);

% clear everything
clear all;
close all;
clear mem;
clear mex;
sca;
clc;

%set path 
pathName = 'C:\Users\Ole\Desktop\Master\SS2020\TEWA2\VDAC';
cd(pathName);


%% Get Subject Info  

prompt = {'Subject Number:','Subject Initials:','Age','Gender (female/male/divers)','Handedness'};
dlgname = 'Setup Info';
LineNo = 1;
default  =  {'0','XX','0','f_m_d','LR'};

answer = inputdlg(prompt,dlgname,LineNo,default); % display dialog

[num, sub, age, gen, han] = deal(answer{:}); % store answers in separate variables
 
subNum = str2double(num); % convert to number for later use
subAge = str2double(age); % convert to number for later use
subInfo = [{'Subject Number'},{'Name'},{'Age'},{'Gender'},{'Handedness'};...
           {num}, {sub}, {age}, {gen}, {han}]; % store together in a single variable
       
% Create file names, based on subject number
fileName =['S' num 'Demographics.xls'];
fileName1=['S' num 'Training.xls'];
fileName2=['S' num 'Test.xls'];
fileName3=['S' num 'LogTest.xls'];
       
%% Screen Setup
% disable syn tests for coding/debugging
Screen('Preference', 'SkipSyncTests', 1);

%Open window
[w, rect] = Screen('OpenWindow', max(Screen('Screens')),[0 0 0]);

% Enable alpha blending 
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(w);

% set priority level for accurate timing
Priority(topPriorityLevel);

%% Stimuli, Texts and Durations of first phase (training phase) and general stimuli

% Calculate vertical refresh rate of the monitor
vrr = Screen('GetFlipInterval', w);

% determine colors and positions of stimuli in the training phase
red = [ 255, 0, 0];
green = [0, 255, 0];

Cx = rect(3)/2;
Cy = rect(4)/2;

% xOn1 = Cx - 400
% xOff1 = Cx - 100
% yOn = Cy - 150
% yOff = Cy + 150

locL = [560 390 860 690];
locR = [1060 390 1360 690];

% feedback rectangle 
feedback = 720; % this is x2 of the feedback rectangle

% fixation cross
crossLength = 10;
crossColor = 255;
crossWidth = 3;
crossLines = [ -crossLength, 0; 
                crossLength, 0;
                0, -crossLength;
                0, crossLength ];           
crossLines = crossLines';
     
% Instructions text
instructionText = ['Herzlich Willkommen zum Experiment!\n\n\n\n',...
           'Das Experiment besteht aus zwei Teilen: ',...
           '\n\n\nIm ersten Teil musst Du zwischen zwei Farben auswählen und erhälst Geld, wenn Du die richtige Farbe wählst. ',...
           '\nIm zweiten Teil müssen Sie die Orientierung eines Balkens angeben.',...
           '\n\n\nDer erste Teil wird ca. 5 Minuten dauern, der zweite Teil ca. 10 Minuten.',...
           '\n\n\n\n\n Drücke Leertaste um zur nächsten Seite zu kommen'];

instructionText2 = ['Der erste Teil des Experiments:\n\n\n',...
           'Hier kannst du Geld gewinnen!\n\n',...
           'In jedem Durchgang musst du dich zwischen einer grünen und einer roten Option entscheiden.\n',...
           'Eine der beiden Optionen führt in jedem Durchgang zu einem Gewinn von 5 Cent.\n',...
           'Es führt immer nur EINE von beiden zu einem Gewinn.\n',...
           'Welche von beiden das ist, kann in jedem Durchgang unterschiedlich sein.\n',...
           'Die Wahrscheinlichkeit eines Gewinns ist jedoch nicht gleich für beide Farben!\n\n\n',...
           'Drücke die Taste a um die grüne Option zu wählen.\n',...
           'Drücke die Taste l um die rote Option zu wählen.\n\n\n',...
           'In jedem Durchgang siehst du in einem Balken die Zunahme deines Gewinns!\n',...
           'Der goldene Strich markiert den bisherigen Rekord anderer TeilnehmerInnen.\n\n\n',...
           'Falls du noch Fragen hast, melde dich bitte jetzt kurz beim Versuchsleiter.\n',...
           'Wenn du bereit bist, drücke bitte Leertaste um das Experiment zu starten.'];

% Text at the end of experiment      
endoftrainingText = 'Super gemacht! Der erste Teil des Experiments ist nun beendet. Klicke Leertaste um fortzufahren.';

% Feedback texts
rewardText = 'Super! Du erhälst 0.05 Euro!';
norewardText = 'Schade! Diese Runde bekommst du kein Geld!';

% Text properties
Screen('TextSize', w, 24);
Screen('TextFont', w, 'Helvetiva');

%% Defining response keys 

% consistent mapping keyCodes
KbName('UnifyKeyNames');

% define response keys
responseKeys = {'a', 'l', 'q'};

% hide mouse cursor
HideCursor; 

%% Define Trial Matrix

% trial Vector for training phase 
nTrials = 120; 
numberOfOnes = nTrials*.8;
indexes = randperm(nTrials);
trialT = zeros(1, nTrials);
trialT(indexes(1:numberOfOnes)) = 1;
trialT = trialT+1;

% transpose vector to store in result file
trialTresults = trialT';

%% Trial Loop Training Phase

% Instructions 
DrawFormattedText(w, instructionText, 'center', 'center', [255]);
        Screen('Flip', w);
        WaitSecs(1.5);
        KbWait;
DrawFormattedText(w, instructionText2, 'center', 'center', [255]);
        Screen('Flip', w);
        WaitSecs(2);
        KbWait;

for t=1:nTrials
    
    % define reward   (1 = green is rewarded, 2 = red is rewarded) 
    reward = trialT(t);
    
    
    % draw the fixation cross; set dontclear buffer to 1
    Screen('DrawLines',w,crossLines,crossWidth,crossColor,[Cx,Cy]);
    Screen('Flip',w,[],1);
    WaitSecs(0.500);
    
    % draw stimuli to the screen 
    Screen('FillRect', w, red, locR);
    Screen('FillRect', w, green, locL);
    Screen('FrameRect', w, [200 200 200], [720 880 1200 980], 2);
    Screen('FillRect', w, [200 200 200], [720 880 feedback 980]);
    Screen('DrawLine', w, [255 215 0], 1080, 880, 1080, 980, [3]);
    target = Screen('Flip', w);
    KbWait;
    
    % register responses and calculate variables
     keyisdown = 0;  % reseting to 0 in every new trial
     response  = 0;  % create variable 
        while ~keyisdown 
            
           [keyisdown, secs, keycode] = KbCheck(); 
           
           if keyisdown
               response = KbName(find(keycode));
               RT(t,1) = secs - target; 
               if response == responseKeys{1}
                   pressedcolor(t,1) = 1; % pressed color was green
               elseif response == responseKeys{2}
                   pressedcolor(t,1) = 2; % pressed color was red
               end
               if response == responseKeys{3} % if Q is pressed, exit experiment
                   sca;
                   clear Screen;
                   disp('You pressed q to quit experiment'); % display this
                   return;   
               end
           end  
        end
       
       % check if response matches response for reward; for example if
       % target is lion: target = 1 -> responseKeys{1} = a
       if response == responseKeys{reward} 
            Correct(t,1) = 1;
            DrawFormattedText(w, rewardText, 'center', 'center', [255 255 255]);
            Screen('Flip', w);
            feedback = feedback + 4;
            WaitSecs(1.0);
       else
            Correct(t,1) = 0;
            DrawFormattedText(w, norewardText, 'center', 'center', [255 255 255]);
            Screen('Flip', w);
            WaitSecs(1.0);
       end 
end
% end of training phase text
DrawFormattedText(w, endoftrainingText, 'center', 'center', [255 255 255]);
Screen('Flip', w);
WaitSecs(2.0);
KbWait;
% save data to xls file 
LogTraining = [trialTresults pressedcolor Correct RT];




%% Test Phase - Basic Settings

% Define trial duration, number of trials, intertrial-interval and setup
% event log

TrialDuration = 1.2;
NumTrials = 240;
EventLog = zeros(NumTrials,5); 
WaitTime = [0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6 0.4 0.5 0.6];
WaitTime = [WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime WaitTime];
WaitTime = Shuffle(WaitTime);

% go to folder where stimuli are stored
cd stimuli

%Read in the stimuli
ReadStimuli

%Generate Trial Sequence
trial

% go back to main folder
cd ..

% determine positions of the stimuli
loc1 = [Cx-50 Cy-250 Cx+50 Cy-150];
loc2 = [Cx+150 Cy-143 Cx+250 Cy-43];
loc3 = [Cx+150 Cy+43 Cx+250 Cy+143];
loc4 = [Cx-50 Cy+150 Cx+50 Cy+250];
loc5 = [Cx-250 Cy+43 Cx-150 Cy+143];
loc6 = [Cx-250 Cy-143 Cx-150 Cy-43];

% Texts 
instTest = ['Nun beginnt der zweite Teil des Experiments.\n\n',...
           'Du wirst gleich sechs Formen (Kreise und Rauten) in unterschiedlichen Farben auf dem Bildschirm sehen.\n',...
           'Es werden immer fünf gleiche Formen zu sehen sein, gemeinsam mit einer unterschiedlichen.\n',...
           'Du siehst z.B. fünf Kreise und eine Raute.\n',...
           'In allen sechs Formen ist in der Mitte eine Linie abgebildet.\n',...
           'Die Linie in der abweichenden Form ist entweder senkrecht oder waagerecht.\n\n\n',...
           'Ist die Linie waagerecht drücke die Taste m.\n',...
           'Ist die Linie senkrecht drücke die Taste z.\n\n\n',...
           'Zunächst wirst du ein paar Übungsdurchgänge absolvieren.',...
           'Um diese zu starten drücke bitte Leertaste.'];
       
instTestPrac = ['Mach dich bereit für ein paar Trainingsdurchgänge!'];

FeedbackRichtig = ['Richtig!']
FeedbackFalsch  = ['Falsch']

afterprac = ['Die Trainingsdurchgänge sind abgeschlossen\n',...
             'Das Experiment startet nun!'];
         
halfofexp = ['Die Hälfte des zweiten Teils des Experiments ist nun abgeschlossen.\n\n',...
             'Mache bitte eine kurze Pause.\n\n',...
             'Das Experiment geht in 30 Sekunden weiter.'];
         
press = ['Drücke die Leertaste um fortzufahren.'];

endofexp = ['Das Experiment ist nun beendet!\n\n',...
            'Vielen Dank für deine Teilnahme!\n\n',...
            'Bitte melde dich beim Versuchsleiter!'];


%% Test phase - Practice

% show instructions
DrawFormattedText(w, instTest, 'center', 'center', [255 255 255]);
Screen('Flip',w);
WaitSecs(2.0);
KbWait;


feedback = 3;
DrawFormattedText(w, instTestPrac, 'center', 'center', [255 255 255]);
Screen('Flip',w);
WaitSecs(2);
StartOfExp = GetSecs;
for v2 = 1:size(pracTest,1);
    responded =0;
    Screen('Flip',w);
    WaitSecs(0.5);
   if v2 > 1
        if feedback == 1;
            DrawFormattedText(w, FeedbackRichtig, 'center', 'center', [255 255 255]);
            Screen('Flip',w);
            WaitSecs(1);
        elseif feedback == 2;
            DrawFormattedText(w, FeedbackFalsch, 'center', 'center', [255 255 255]);
            Screen('Flip',w);
            WaitSecs(1);
        elseif feedback == 3;
            Screen('Flip',w);
            beep2(1000,.25);
            WaitSecs(0.75);
        end
        Screen('Flip',w);
        WaitSecs(0.5);
        feedback = 3;
   end
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('Flip',w);
    WaitSecs(WaitTime(v2));
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('DrawTexture',w,Item(pracTest(v2,1)),[],loc1);
    Screen('DrawTexture',w,Item(pracTest(v2,2)),[],loc2);
    Screen('DrawTexture',w,Item(pracTest(v2,3)),[],loc3);
    Screen('DrawTexture',w,Item(pracTest(v2,4)),[],loc4);
    Screen('DrawTexture',w,Item(pracTest(v2,5)),[],loc5);
    Screen('DrawTexture',w,Item(pracTest(v2,6)),[],loc6);
    Screen('Flip',w);
    TimeOfStim = GetSecs; %%%Returns the time the flip occurred relative to when the experiment started
    while GetSecs-TimeOfStim < TrialDuration & responded == 0;
        [keyIsDown,respTime,respKey]=KbCheck;
        if keyIsDown == 1
            resp = find(respKey);
            feedback = 2;
            responded =1;
            if pracTest(v2,8)==2
                if resp(1) == KbName('z') || resp(1) == KbName('Z')
                    feedback = 1;
                end
            elseif pracTest(v2,8)==1
                if resp(1) == KbName('m') || resp(1) == KbName('M')
                    feedback = 1;
                end
            end
        end
    end
end
responded =0;
Screen('Flip',w);
WaitSecs(0.5);
if feedback == 1;
    DrawFormattedText(w, FeedbackRichtig, 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
elseif feedback == 2;
    DrawFormattedText(w, FeedbackFalsch, 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
elseif feedback == 3;
    Screen('Flip',w);
    beep2(1000,.25);
    WaitSecs(0.75);
end
Screen('Flip',w);
WaitSecs(0.5);
feedback = 3;

% end of practice trials, experimental trials will start now 
 DrawFormattedText(w, afterprac, 'center', 'center', [255 255 255]);
 Screen('Flip',w);
 WaitSecs(4);
 
 %% Test phase - Experimental trials
 
 StartOfExp = GetSecs;
for v2 = 1:size(trialTest,1);
    if v2 > 1
        if responded == 0
            Screen('Flip',w);
            beep2(1000,.25);
        end
        if feedback ==2 && responded ==1
            DrawFormattedText(w, FeedbackFalsch, 'center', 'center', [255 255 255]);
            Screen('Flip',w);
            WaitSecs(1);
        end
    end
    if v2 == 121
      DrawFormattedText(w, halfofexp, 'center', 'center', [255 255 255]);
      Screen('Flip',w);
      WaitSecs(30);
      DrawFormattedText(w, press, 'center', 'center', [255 255 255]);
      Screen('Flip',w);
      KbWait;
      WaitSecs(1);
    end
    responded =0;
    Screen('Flip',w);
    WaitSecs(0.5);
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('Flip',w);
    WaitSecs(WaitTime(v2));
    Screen('DrawTexture',w,fix,[],[Cx-20 Cy-20 Cx+20 Cy+20]);
    Screen('DrawTexture',w,Item(trialTest(v2,1)),[],loc1);
    Screen('DrawTexture',w,Item(trialTest(v2,2)),[],loc2);
    Screen('DrawTexture',w,Item(trialTest(v2,3)),[],loc3);
    Screen('DrawTexture',w,Item(trialTest(v2,4)),[],loc4);
    Screen('DrawTexture',w,Item(trialTest(v2,5)),[],loc5);
    Screen('DrawTexture',w,Item(trialTest(v2,6)),[],loc6);
    Screen('Flip',w);
    TimeOfStim = GetSecs; %%%Returns the time the flip occurred relative to when the experiment started
    EventLog(v2,3)= TimeOfStim - StartOfExp; %when stimulus was presented
    EventLog(v2,4)= trialTest(v2,7); %type of target
    EventLog(v2,5)= trialTest(v2,9); %type of distractor
    while GetSecs-TimeOfStim < TrialDuration & responded == 0;
        [keyIsDown,respTime,respKey]=KbCheck;
        if keyIsDown == 1
            resp = find(respKey);
            EventLog(v2,2)=(respTime-TimeOfStim); %%%RT relative to when the target was flipped on the screen
            responded =1;
            feedback = 2;
            if trialTest(v2,8)==2
                if resp(1) == KbName('z') || resp(1) == KbName('Z')
                    EventLog(v2,1)=1; %ACC (correct), otherwise is 0 (incorrect)
                    feedback = 1;
                end
            elseif trialTest(v2,8)==1
                if resp(1) == KbName('m') || resp(1) == KbName('M')
                    EventLog(v2,1)=1; %ACC (correct), otherwise is 0 (incorrect)
                    feedback = 1;
                end
            end
        end
    end
end
% Show text for end of experiment 
DrawFormattedText(w, endofexp, 'center', 'center', [255 255 255]);
Screen('Flip',w);
WaitSecs(4);
 
% save data
xlswrite(fileName, subInfo);
xlswrite(fileName1, LogTraining);
xlswrite(fileName2, EventLog);
xlswrite(fileName3, trialTest);
Screen('CloseAll');
sca;