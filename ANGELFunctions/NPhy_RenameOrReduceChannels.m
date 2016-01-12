function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_RenameOrReduceChannels(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_RenameOrReduceChannels Rename EGI channels (and maybe reduce to 64) 
%
%   Channel Renaming Operations for EGI to match with 10-10 and
%   Neuroscan cap nomenclature
%
% Date of Creation: 13 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Do this step only if its an EGI acquisition
if strcmp(ANGEL.acquisitionID, 'EGI')

    % Initialize variables
    returnFile = inputFile;
    errorReturn = 0;

    try
        
        % Relabel EGI channels as per 10-10 nomenclature or 
        % Create a new set file for EGI that matches Neuroscan channels
        
        if(strcmp(ANGEL.channelReduction, 'no'))
            channelOperation = ANGEL.egi129ChannelMap;
        else
            channelOperation = ANGEL.egi64ChannelMap;
        end
        
        EEG = pop_eegchanoperator(EEG, channelOperation);

        [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
        
        % Update dataset comments
        EEG.comments = pop_comments(EEG.comments,'',...
                'Updated EEG channel location names',1); 
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
    fprintf('\n%s is not an EGI acquisition and does not need channel renaming\n', inputFile);
    fprintf(ANGEL.logFileID,  '\n%s is not an EGI acquisition and does not need channel renaming\n', inputFile);
end % End of Check for EGI

fprintf(ANGEL.logFileID,'\nCompleted channel renaming/reduction for : %s \n',inputFile);
end

