function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_Rereference(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_Rereference Rereference to Average
%
%   Change to Average Reference
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

try
    
EEG = pop_reref(EEG, []);
[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');

% Update dataset comments
EEG.comments = pop_comments(EEG.comments,'',...
    'Average Rereference done',1);  

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

fprintf(ANGEL.logFileID,'\nCompleted Average referencing for : %s \n',inputFile);
end

