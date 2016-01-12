function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_RemoveArtifacts(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_RemoveArtifacts Remove artifacts - movement, eye blinks etc
%
%   Currently this uses EEGLAB's clean_artifacts function using 
%   artifact subspace reconstruction
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

try


    %% Update channel locations if needed
    [ALLEEG, EEG, CURRENTSET, inputFile, error ] = NPhy_UpdateChanLocsBeforeCleaning(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile);

    if(error)
        errorReturn = 1;
        return;
    end            
        


    
    %% Initially applying Low pass filter
    [ALLEEG, EEG, CURRENTSET, inputFile, error ] = NPhy_FilterEEG(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile, ANGEL.preICALowPass);

    if(error)
        errorReturn = 1;
        return;
    end
    
    % Remove non-EEG channels (if any) - especially for Neuroscan
    EEG = pop_select( EEG,'nochannel', ANGEL.channelsForExclusion);
    [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
    

    EEG = clean_artifacts(EEG,'BurstCriterion',ANGEL.asrBurstCriterion); 
    [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
    
        
    % Update dataset comments
    EEG.comments = pop_comments(EEG.comments,'',...
        sprintf('Dataset was cleaned with ASR: %d', ANGEL.asrBurstCriterion),1); 

    EEG = pop_saveset(EEG, 'filename', inputFile, 'filepath', ANGEL.cleanDir );
    EEG = eeg_checkset(EEG); 

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

returnFile = inputFile;
fprintf(ANGEL.logFileID,'\nCompleted artifact removal for : %s \n',inputFile);
end

