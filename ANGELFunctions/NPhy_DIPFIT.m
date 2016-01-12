function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_DIPFIT(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_DIPFIT Dipole Fitting
%
%   Run Dipole fitting on EEGLAB epoched files
%
% Date of Creation: 27 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

% Get the EEGLAB path
eeglabPath = fileparts(which('eeglab'));

try

    EEG = pop_loadset('filename',inputFile,...
            'filepath',ANGEL.eegEpochedDir,'loadmode','info'); 
    EEG = eeg_checkset(EEG);
    EEG = pop_dipfit_settings(EEG,...
        'hdmfile',[eeglabPath,'\plugins\dipfit2.3\standard_BEM\standard_vol.mat'],...
        'coordformat','MNI',...
        'mrifile',[eeglabPath,'\plugins\dipfit2.3\standard_BEM\standard_mri.mat'],...
        'chanfile',[eeglabPath,'\plugins\dipfit2.3\standard_BEM\elec\standard_1005.elc']);
    EEG = pop_multifit(EEG, [],'threshold',40);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    
    EEG = pop_saveset(EEG, 'filename',inputFile,'filepath', ANGEL.eegEpochedDir); 
    
    
catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end
fprintf(ANGEL.logFileID,'\nCompleted Dipole Fitting for : %s \n',inputFile);
end

