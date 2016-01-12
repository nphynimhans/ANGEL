function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_PreProcessingForEpoching(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_PreProcessingForEpoching Generic EEG preprocesing steps
%
%   Low Pass Filter, Initial Downsample, Change to Average reference
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

try

% Initially downsample to reduce file size and stay useful for ICA
[ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_Downsample(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile, ANGEL.preICADownSample);

if(error)
    errorReturn = 1;
    return;
end
   
% Change to average reference
[ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_Rereference(ALLEEG, EEG, CURRENTSET, ANGEL, file);

if(error)
    errorReturn = 1;
    return;
end

% Save the setname using the prefix length used for the study
EEG.setname = [file(1:ANGEL.prefixLength), '_Preprocessed'];
% Save the preprocessed dataset
EEG = pop_saveset(EEG, 'filename', file, 'filepath', ANGEL.cleanDir );
EEG = eeg_checkset(EEG); 

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', file);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

fprintf(ANGEL.logFileID,'\nCompleted preprocessing before epoching for : %s \n',inputFile);

end

