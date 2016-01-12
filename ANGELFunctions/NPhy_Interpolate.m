function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_Interpolate(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_Interpolate Interpolate channels after artifact removal
%       Will not be saving the file at this step
%
% Date of Creation: 17 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

try

% Interpolate using default channel location .mat file
% NOTE: the variable name should be 'default_chan_loc'
% Save channel lists for creating list of interpolated channels later 
load([ANGEL.chanLocDir,'\', ANGEL.chanLocMat],'-mat');
allChannelList = {defaultChanLocs.labels};
currentChannelList = {EEG.chanlocs.labels};
    
EEG = pop_interp(EEG, defaultChanLocs,'spherical');
        
[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');

% Update dataset comments with list of interpolated channels
 deletedChannels = allChannelList(cell2mat...
    (cellfun(@(x) isempty(find(strcmp(x,currentChannelList), 1)),...
    allChannelList,'UniformOutput',false)));

for deletedChanNo = 1:length(deletedChannels)
    EEG.comments = pop_comments(EEG.comments,'',...
        sprintf('Interpolation of %s channel done.',...
        deletedChannels{deletedChanNo}),1);
end

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end

fprintf(ANGEL.logFileID,'\nCompleted interpolation for : %s \n',inputFile);
end

