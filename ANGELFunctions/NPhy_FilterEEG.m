function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_FilterEEG(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile, filterValue)
%NPhy_FilterEEG Generic function for multiple filtering options
%
%   Filter using EEGLAB filter function
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = {};
errorReturn = 0;

try
    EEG = eeg_checkset(EEG);
    EEG = pop_eegfiltnew(EEG,[], filterValue, 330, 0, [], 0); 
    EEG = eeg_checkset(EEG);
    [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
   
    % Update dataset comments
    EEG.comments = pop_comments(EEG.comments,'',...
        sprintf('Low pass of %d Hz',filterValue),1);  


catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

returnFile = inputFile;

fprintf(ANGEL.logFileID,'\nCompleted filtering for : %s at %d \n',inputFile, filterValue);
end

