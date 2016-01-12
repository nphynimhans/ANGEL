%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NPhy_ERPLAB_EpochDetailExtraction_script 
%          
%      Gets number of epochs in the files and saves in a csv file
%
% Created by Dr Arun Sasidharan, Ajay on 20 Feb 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%% Select the ERPLAB bined .set files of different subjects 

[fullFileList, rootDir, filterIndex] = uigetfile({'*.set'}, ...
        'Select .set file(s) to extract epoch details', ...
        'MultiSelect', 'on');

% Take care of single file selection
if ischar(fullFileList) == 1
    fullFileList = {fullFileList};
end
    
cd(rootDir);

%% Select Output Directory
outputDir = uigetdir(...
    rootDir,'Select the Output directory for Results');

fID = fopen([outputDir, '/epochDetails.csv'], 'w');
fprintf(fID,'Filename, Trial Count, Differential Channel Count\n');

% Start timer
ticID = tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop for each file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileWaitbar = waitbar(0,'Please wait...','Name',...
    'Trial count extraction');
set(fileWaitbar,'Position', [465, 400, 270, 80]) 

for fileNo = 1:length(fullFileList)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load ERPLAB bined .set files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    filename = fullFileList{fileNo};

    %% Load .set file to EEG structure
    EEG = pop_loadset('filename',filename,...
        'filepath',rootDir,'loadmode','info');        

    fprintf(fID,'%s,%d, %d\n',filename(1:end-4), EEG.trials, (length(EEG.nbchan)- length(EEG.icasphere)));
    
     % Initialize EEG dataset
    EEG = [];
    
    % Update file_waitbar after analysis of every subject file
    waitbar(fileNo/length(fullFileList),fileWaitbar,...
        sprintf('Completed event extraction for file %d of %d\n',...
        fileNo,length(fullFileList)));
    
    
end
fclose(fID);

close (fileWaitbar);
elapsedTime = int16(toc(ticID));
fprintf(['\n COMPLETED Analysis ',...
    '\n Overall time taken was %d secs (~ %d mins)\n'],...
    elapsedTime,int16(elapsedTime/60));
