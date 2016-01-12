function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_ConvertRawToSet(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_ConvertRawToSet Convert Proprietory Continuous EEG files to EEGLAB .Set files
%
%   Purpose: Import into EEGLAB from one of the following:
%            - Net Station Simple Binary (Epoched) files - .raw files
%            - Neuroscan .cnt files
%
% Date of Creation: 7 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = {};
errorReturn = 0;

file = [ANGEL.rawDir, inputFile];
        
try
    
    channelLocationFile = [ANGEL.chanLocDir, '\', ANGEL.chanLocFile];
    
    if(~exist(channelLocationFile, 'file'))
        if strcmp(ANGEL.acquisitionID, 'EGI')     
            [chanLocFilename, chanLocDir] = uigetfile({'*.sfp'}, ...
            'Select the Default Channel Location file');
        elseif strcmp(ANGEL.acquisitionID, 'Neuroscan')
            [chanLocFilename, chanLocDir] = uigetfile({'*.elp'}, ...
            'Select the Default Channel Location file');       
        end
        channelLocationFile = [chanLocDir, '\', chanLocFilename];
    end
    
    channelLocationMatrix = [ANGEL.chanLocDir, '\', ANGEL.chanLocMat];
    
    if(strcmp(ANGEL.acquisitionID, 'EGI'))
        % Import Net Station .raw files into EEGLAB 
        EEG = pop_fileio(file);

        % Save the setname using the prefix length used for the study
        EEG.setname = inputFile(1:ANGEL.prefixLength);
        EEG = eeg_checkset(EEG);
         
        % Add channel location details from the default file
        EEG = pop_chanedit(EEG, 'load', channelLocationFile);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
        

    elseif(strcmp(ANGEL.acquisitionID, 'Neuroscan'))
        % CNT to SET conversion
        EEG = pop_loadcnt(file , 'dataformat', 'int32', 'keystroke', 'on');
        
        EEG.setname = inputFile(1:ANGEL.prefixLength);
        EEG = eeg_checkset(EEG);

        % Add channel location details from the default file
        EEG = pop_chanedit(EEG, 'lookup', channelLocationFile);          
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    
    end
    
    % Save the channel locations as a matrix (for interpolation) if it
    % doesn't exist as yet
    if(~exist(channelLocationMatrix, 'file'))
       defaultChanLocs = EEG.chanlocs; 
       save(channelLocationMatrix, 'defaultChanLocs');
    end

    % Save the file using the prefix length used for the study
    eegfile = [inputFile(1:ANGEL.prefixLength),'.set'];
    returnFile = eegfile;

    EEG = pop_saveset(EEG, 'filename', eegfile, 'filepath', ANGEL.setDir);
    EEG = eeg_checkset(EEG); 

catch error
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

fprintf(ANGEL.logFileID,'\nCompleted Raw to Set conversion for file: %s \n',inputFile);

end  % end of function

