function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_UpdateChanLocsBeforeCleaning(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_UpdateChanLocsBeforeCleaning Lookup Channel locations details for EGI
% Purpose: If the number of channels are reduced artificially for 
%          comparing data from other acquisitions, the channel locations 
%          are lost and need to be updated. 
%
% Date of Creation: 30 Mar 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
errorReturn = 0;
returnFile = inputFile;

if strcmp(ANGEL.acquisitionID, 'EGI') && ~strcmp(ANGEL.channelReduction, 'no')
 
    try
        channelLocationFile = [ANGEL.chanLocDir, '\', ANGEL.chanLocLookupFile];
        
        % Load .set file to EEG structure
        EEG = pop_loadset('filename', inputFile, 'filepath',ANGEL.setDir, 'loadmode', 'all');  
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG

        % Add channel location details from the default file
        EEG = pop_chanedit(EEG, 'lookup', channelLocationFile);            
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);

        channelLocationMatrix = [ANGEL.chanLocDir, '\', ANGEL.chanLocMat];
        % Save the channel locations as a matrix (for interpolation) if it
        % doesn't exist as yet
        if(~exist(channelLocationMatrix, 'file'))
           defaultChanLocs = EEG.chanlocs; 
           save(channelLocationMatrix, 'defaultChanLocs');
        end

        % Update dataset comments
        EEG.comments = pop_comments(EEG.comments,'','Updated Channel Locations',1);  
        EEG = pop_saveset(EEG, 'filename', inputFile, 'filepath', ANGEL.setDir);        
        
    catch error
        errorReturn = 1;
        warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
        fprintf(ANGEL.logFileID,...
            '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
            inputFile, error.message);
    end

else
    fprintf('\n%s is not an EGI acquisition with channel reduction and does not need channel location lookup\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n%s is not an EGI acquisition with channel reduction and does not need channel location lookup\n', inputFile);
end % End of Check for EGI

fprintf(ANGEL.logFileID,'\nCompleted channel location lookup for : %s \n',inputFile);
end

