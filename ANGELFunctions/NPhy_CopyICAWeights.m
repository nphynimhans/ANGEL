function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_CopyICAWeights(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_CopyICAWeights Copy ICA weights
%
%   Copy ICA weights from the saved matrix to EEGLAB epoched files
%
% Date of Creation: 19 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

% Load the corresponding ICA values
fileLabel = inputFile(1:ANGEL.prefixLength);
load([ANGEL.icaDir, '\', fileLabel, '.mat']);

try

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%% Copy the ICA matrix

    %% Copying ICA matrix to non-ICA run dataset
    EEG.icawinv = ICAEEG.icawinv;
    EEG.icasphere = ICAEEG.icasphere;
    EEG.icaweights = ICAEEG.icaweights;
    EEG.icachansind = ICAEEG.icachansind;
    EEG.etc = ICAEEG.etc;

    % Update dataset coments
    EEG.comments = pop_comments(EEG.comments,'','ICA weights copied.',1); 
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    
    %Save the EEG file (now updated with ICA weights)
    EEG = pop_saveset(EEG, 'filename',inputFile,'filepath', ANGEL.eegEpochedDir);    
    
    
catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end
fprintf(ANGEL.logFileID,'\nCompleted copying ICA weights for : %s \n',inputFile);
end

