function [ERP, returnFile, errorReturn] = NPhy_AverageEpochs(EEG, ANGEL, inputFile)
%NPhy_AverageEpochs Averaging using ERPLAB
%
%   Average each epoched file using ERPLAB
%
% Date of Creation: 27 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

try
    fileName = inputFile;

    ERP = pop_averager(EEG, 'Criterion', 'good','DSindex', 1,...
    'ExcludeBoundary', 'on', 'SEM', 'on');

    ERP = pop_savemyerp(ERP,...
            'erpname', fileName(1:(end-4)),...
            'filename', [fileName(1:(end-4)),'.erp'],...
            'filepath', ANGEL.erpAveragedDir, 'Warning', 'off`');

catch error
    warning('\nSkipped averaging for the condition: %s \n ******\n', fileName);
    fprintf(ANGEL.logFileID,...
    '\n ******\nSkipped averaging for the condition: %s with error: %s\n ******\n',...
    fileName, error.message);
end

fprintf(ANGEL.logFileID,'\nCompleted averaging for : %s \n',inputFile);
end

