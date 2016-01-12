function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_EpochByERPLAB(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_EpochByERPLAB Epoching using ERPLAB
%
%   Interpolate channels after artifact removal,  Average reference,
%   Save events in ERPLAB format and finally epoch the files using ERPLAB
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

% Get the filename (keep the length short)
fileLabel = inputFile(1:ANGEL.prefixLength);

try

%% Interpolate missing channels after artifact removal
[ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_Interpolate(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile);

if(error)
    errorReturn = 1;
    return;
end

%% Downsample to further reduce the file size 
[ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_Downsample(ALLEEG, EEG, CURRENTSET, ANGEL, file, ANGEL.finalDownSample);

if(error)
    errorReturn = 1;
    return;
end
   
%% Change to average reference once more
[ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_Rereference(ALLEEG, EEG, CURRENTSET, ANGEL, file);

if(error)
    errorReturn = 1;
    return;
end

% Save the continuous file 
EEGLABSpecificContinuousEEG = EEG;

%% Store event list in ERPLAB format
EEG  = pop_creabasiceventlist(EEG, 'AlphanumericCleaning', 'on',...
    'BoundaryNumeric', {-99}, 'BoundaryString', {'boundary'});
EEG = eeg_checkset(EEG);

% update dataset comments
EEG.comments = pop_comments(EEG.comments,'',...
    'Event list changed to ERPLAB format.',1);

[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');


% Save the continuous file 
ERPLABSpecificContinuousEEG = EEG;

%% Loop for each ERP condition for the given file
for erpConditionNo = 1:length(ANGEL.erpEventLabels)
   try
       
        %% Get the event markers
        events = ANGEL.erpEventMarkers{erpConditionNo};
        % Reorder the event list
        % Remove zeros from events 
        eventsList = cell(length(events),length(events{1}),1);
        for eventsCellNo = 1:length(events)                        
            for eventsListNo = 1:size(events{eventsCellNo},1)
                eventsList{eventsCellNo,eventsListNo,:} = num2str(...
                    events{eventsCellNo}(eventsListNo,:));
            end
        end
        responseList = {'1';'2'};
                       

       %% Event check before trying to epoch
       eventIndices = [];
       switch ANGEL.erpEventLabels{erpConditionNo}
           
            case {'Correct','Incorrect'}
                [respIndices,~,~,respLatency] =...
                    eeg_context(EEGLABSpecificContinuousEEG,responseList(1),eventsList(1,:),-1);
                
                eventIndices = [eventIndices;...
                    respIndices(respLatency<-200 & respLatency>-700)]; %#ok<*AGROW>
                
                [respIndices,~,~,respLatency] =...
                    eeg_context(EEGLABSpecificContinuousEEG,responseList(2),eventsList(2,:),-1);
                
                eventIndices = [eventIndices;...
                    respIndices(respLatency<-200 & respLatency>-700)];
                
                eventIndices = sort(eventIndices);

                % Changing the events list as its response locked
                epochList = responseList;
                
            case {'CDOn','CDOff'}  % Skip CD events for ANGEL1
                if ~isempty(regexp(file,'\w*ANGEL1', 'once'))
                    continue;
                else
                    eventIndices = (1:length(EEGLABSpecificContinuousEEG.event))';
                    epochList = eventsList;                    
                end
            otherwise
                eventIndices = (1:length(EEGLABSpecificContinuousEEG.event))';
                epochList = eventsList;
       end 

       % If there are too few epoching events, skip the epoching step for this ERP Condition 
       if length(eventIndices) <=5
           fprintf('Skipped epoching for the condition: %s for file: %s. Only %d events found',...
               ANGEL.erpEventLabels{erpConditionNo}, file, length(eventIndices));
           fprintf(ANGEL.logFileID,...
               'Skipped epoching for the condition: %s for file: %s. Only %d events found',...
               ANGEL.erpEventLabels{erpConditionNo}, file, length(eventIndices));
           continue;
       end

        %% Create a temporary bin descriptor file with list of bins
        binlistFileID = fopen('TemporaryBinList.txt','w'); 
        
        switch ANGEL.erpEventLabels{erpConditionNo}
            case {'Correct','Incorrect'}
                % Button #1 
                fprintf(binlistFileID,'bin 1\n');
                fprintf(binlistFileID,'%s\n', ANGEL.erpEventLabels{erpConditionNo});
                fprintf(binlistFileID,'{t<200-700>');   
                for eventNo = 1:length(eventsList(1,:))
                   fprintf(binlistFileID,'%s',eventsList{1,eventNo});
                   if eventNo<length(eventsList(1,:))
                       fprintf(binlistFileID,';');
                   end
                end
                fprintf(binlistFileID,'}');                        
                fprintf(binlistFileID,'.{');
                fprintf(binlistFileID,responseList{1});
                fprintf(binlistFileID,'}\n');

                % Button #2    
                fprintf(binlistFileID,'bin 2\n');
                fprintf(binlistFileID,'%s\n', ANGEL.erpEventLabels{erpConditionNo});                        
                fprintf(binlistFileID,'{t<200-700>');
                for eventNo = 1:length(eventsList(2,:))
                    fprintf(binlistFileID,'%s',eventsList{2,eventNo});
                    if eventNo<length(eventsList(2,:))
                        fprintf(binlistFileID,';');
                    end
                end
                fprintf(binlistFileID,'}');
                fprintf(binlistFileID,'.{');
                fprintf(binlistFileID,responseList{2});
                fprintf(binlistFileID,'}');

            otherwise
                fprintf(binlistFileID,'bin 1\n');
                fprintf(binlistFileID,'%s\n',ANGEL.erpEventLabels{erpConditionNo});
                fprintf(binlistFileID,'.{');
                for eventNo = 1:length(eventsList(1,:))
                    fprintf(binlistFileID,'%s',eventsList{1,eventNo});
                    if eventNo<length(eventsList(1,:))
                        fprintf(binlistFileID,';');
                    end
                end
                fprintf(binlistFileID,'}');
        end

        %% Create ERP bins
        EEG  = pop_binlister(ERPLABSpecificContinuousEEG,...
            'BDF','TemporaryBinList.txt','IndexEL', 1,...
            'SendEL2','EEG','UpdateEEG','on','Voutput','EEG');
        EEG = eeg_checkset(EEG);
        

        % Update dataset coments
        EEG.comments = pop_comments(EEG.comments,'',...
            'Created ERP bins using ERPLAB.',1);        

        %% Epoch the data using ERPLAB
        EEG = pop_epochbin(EEG, ANGEL.erpEpochs, ANGEL.erpBaselineCorrection);
        [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
        
        
        % Update dataset comments
        EEG.comments = pop_comments(EEG.comments,'',...
            'Epoched ERP bins using ERPLAB',1);
        
        % Save the setname using the prefix length used for the study
        EEG.setname = [fileLabel, ANGEL.sep, ANGEL.erpEventLabels{erpConditionNo}];
        
        EEG = pop_saveset(EEG, 'filename',...
            [fileLabel,ANGEL.sep,ANGEL.erpEventLabels{erpConditionNo}],...
            'filepath', ANGEL.erpEpochedDir);
        
       
   catch error
        warning('\nSkipped epoching for the condition: %s for file: %s \n ******\n', ANGEL.erpEventLabels{erpConditionNo}, file);
        fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped epoching for the condition: %s for file: %s with error: %s\n ******\n',...
        ANGEL.erpEventLabels{erpConditionNo},...
        file, error.message);
        continue;
   end
   fclose(binlistFileID);

end  % End of for loop - iterating over erp conditions

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

returnFile = file;
fprintf(ANGEL.logFileID,'\nCompleted ERPLAB epoching for : %s \n',inputFile);
end

