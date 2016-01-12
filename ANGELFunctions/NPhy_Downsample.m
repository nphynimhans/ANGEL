function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_Downsample(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile, newSamplingRate)
%NPhy_Downsample Generic downsampling function
%
%   EEG Downsampling
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = {};
errorReturn = 0;

try
    
EEG = pop_resample(EEG, newSamplingRate);
[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');


% Update dataset comments
EEG.comments = pop_comments(EEG.comments,'',...
    sprintf('Downsampled to %d',newSamplingRate),1);  

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

returnFile = inputFile;

fprintf(ANGEL.logFileID,'\nCompleted downsampling for : %s  at %d\n',inputFile, newSamplingRate);
end

