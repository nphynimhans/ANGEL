function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] =  NPhy_AdjustSoundLatencies(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_AdjustSoundLatencies Adjust the sound marker latencies for EGI
%   
% Import event markers from Net Station first then adjust the sound latencies
% In the ANGEL game, even though the soundfile is played with each
% stimulus, the paired clicks are presented in a jittered manner
% Std is a standard sound and Dev is the deviant one. These are presented
% as part of a paired click that is always 500ms apart
% Std1 and Dev1 are not jittered 
% Std2 and Dev2 are played 200ms after stimulus onset
% Std3 and Dev3 are played 400ms after stimulus onset
% The second of the paired stimuli are Std2, Dev2 etc.
%
% Date of Creation: 11 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Do this step only if its an EGI acquisition
if strcmp(ANGEL.acquisitionID, 'EGI')

    errorReturn = 0;

    try
        eventDir = [ANGEL.outputDir, '\Events'];
        eventFile = [eventDir, '\', inputFile(1:(end-4)), '_events.txt'];

        EEG = pop_importevent(EEG, 'append', 'no', 'event', eventFile, 'fields', {'type', 'latency'});
        
        
        [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
        
        % Update dataset comments
        EEG.comments = pop_comments(EEG.comments,'',...
                'Inserted Net Station Events.',1); 

        for itemIndex = 1:length(ANGEL.S1EventList)
            
            % Find the latencies for the given event
            [~,targetIndices] = pop_selectevent(EEG,'type',ANGEL.S1EventList{itemIndex});
            S1latencies = [EEG.event(targetIndices).latency];

            % Modify the latencies for existing S1 event markers
            switch ANGEL.S1EventList{itemIndex}

                case {221, 224}
                    S1latencies = S1latencies*1000/EEG.srate + 200; % For std2 and deviant2 S1 events
                    for eventCount = 1:length(targetIndices)
                        soundEventNumber = targetIndices(eventCount);
                        EEG = pop_editeventvals(EEG,'changefield',{soundEventNumber 'latency' S1latencies(eventCount)/1000});
                    end

                case {222, 225}
                    S1latencies = S1latencies*1000/EEG.srate + 400; % For std3 and deviant3 S1 events   
                    for eventCount = 1:length(targetIndices)
                        soundEventNumber = targetIndices(eventCount);
                        EEG = pop_editeventvals(EEG,'changefield',{soundEventNumber 'latency' S1latencies(eventCount)/1000});
                    end
            end  

            % Find out latencies for S2 event markers
            S2latencies = S1latencies + 500; % S2 latency is 500ms after S1 latency

            % Insert S2 events at their latencies
            eventUpdateNo = 0;
            for eventCount = 1:length(targetIndices)
                S2event_number = targetIndices(eventCount) + eventUpdateNo;
                EEG = pop_editeventvals(EEG,'append',{S2event_number ANGEL.S2EventList{itemIndex} S2latencies(eventCount)/1000 []});
                eventUpdateNo = eventUpdateNo + 1;
            end

        end
        
        
        [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
        
        % Update dataset comments
        EEG.comments = pop_comments(EEG.comments,'',...
                'Updated sound event latencies for std and deviant events.',1); 
        EEG.filename = inputFile; 
        EEG.filepath = ANGEL.setDir;
        EEG = pop_saveset(EEG, 'filename', inputFile, 'filepath', ANGEL.setDir );
        EEG = eeg_checkset(EEG); 

    catch error
        errorReturn = 1;
        warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
        fprintf(ANGEL.logFileID,...
            '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
            inputFile, error.message);
    end

else
    fprintf('\n%s is not an EGI acquisition and does not need sound marker latency adjustment\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n%s is not an EGI acquisition and does not need sound marker latency adjustment\n', inputFile);
end % End of Check for EGI

returnFile = inputFile;

end

