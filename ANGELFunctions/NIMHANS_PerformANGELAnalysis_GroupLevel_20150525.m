%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NIMHANS_PerformANGELAnalysis_GroupLevel
% Adapted from set of Matlab scripts 
% 
% Purpose: Batch ERP Analysis for the ANGEL Cognitive Task across subject
% groups
%
% Date of Creation: 9 Apr 2015
% Authors: Arun and Ajay
% Updated by Ajay on 16 May 2015: Added functionality for MeasureProjection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all 

% Load all the variables for ANGEL ERP analysis
if ~exist('ANGELVariables.mat', 'file')
    [varFileName, ~, ~] = uigetfile('*.mat', 'Select the ANGEL Variables file');
    load(varFileName);
else
    load('ANGELVariables.mat');
end

% Select the Output directory to store all the processed files
if ~exist(ANGEL.outputDir, 'dir')
    ANGEL.outputDir = uigetdir('.', 'Select the output directory for storing ERP Analysis');
end

ANGEL.logDir = [ANGEL.outputDir,'\Log'];
if ~exist(ANGEL.logDir, 'dir')
    mkdir(ANGEL.logDir);
end

ANGEL.eegDir = [ANGEL.outputDir,'\EEGLAB'];
if ~exist(ANGEL.eegDir, 'dir')
    mkdir(ANGEL.eegDir);
end

ANGEL.eegEpochedDir = [ANGEL.eegDir,'\Epoched'];
if ~exist(ANGEL.eegEpochedDir, 'dir')
    mkdir(ANGEL.eegEpochedDir);
end

ANGEL.erpDir = [ANGEL.outputDir,'\ERPLAB'];
if ~exist(ANGEL.erpDir, 'dir')
    mkdir(ANGEL.erpDir);
end

ANGEL.erpEpochedDir = [ANGEL.erpDir,'\Epoched'];
if ~exist(ANGEL.erpEpochedDir, 'dir')
    mkdir(ANGEL.erpEpochedDir);
end

ANGEL.erpAveragedDir = [ANGEL.erpDir,'\Averaged'];
if ~exist(ANGEL.erpAveragedDir, 'dir')
    mkdir(ANGEL.erpAveragedDir);
end

ANGEL.erpAppendedPerSubjectDir = [ANGEL.erpDir,'\AppendedPerSubject'];
if ~exist(ANGEL.erpAppendedPerSubjectDir, 'dir')
    mkdir(ANGEL.erpAppendedPerSubjectDir);
end

ANGEL.erpGrandAveragedDir = [ANGEL.erpDir,'\GrandAveraged'];
if ~exist(ANGEL.erpGrandAveragedDir, 'dir')
    mkdir(ANGEL.erpGrandAveragedDir);
end

ANGEL.erpAppendedPerGroupDir = [ANGEL.erpDir,'\AppendedPerGroup'];
if ~exist(ANGEL.erpAppendedPerGroupDir, 'dir')
    mkdir(ANGEL.erpAppendedPerGroupDir);
end

ANGEL.resultsDir = [ANGEL.outputDir,'\Results'];
if ~exist(ANGEL.resultsDir, 'dir')
    mkdir(ANGEL.resultsDir);
end

ANGEL.icaDir = [ANGEL.outputDir,'\ICA'];
if ~exist(ANGEL.icaDir, 'dir')
    mkdir(ANGEL.icaDir);
end

ANGEL.studyDir = [ANGEL.outputDir,'\STUDY'];
if ~exist(ANGEL.studyDir, 'dir')
    mkdir(ANGEL.studyDir);
end

%Get current date and time to store as part of log file name
timeLog = strrep(strrep(datestr(fix(clock)), ':','.'), ' ', '_');

ANGEL.logFileID = fopen([ANGEL.logDir, '\NIMHANS_ERPAnalysis_ANGEL_log_', timeLog, '.txt'], 'w');

%Get current date and time to record starting time
startTime = clock;
timeStampStart = strrep(strrep(datestr(fix(startTime)), ':','.'), ' ', '_');
fprintf( '\n ******\nStarting ANGEL ERP Analysis at:  %s \n ******\n', timeStampStart);
fprintf(ANGEL.logFileID,  '\n ******\nStarting ANGEL ERP Analysis at:   %s \n ******\n', timeStampStart);

% Prompt for various processing options
optionsList = {...
               '1. ERPLAB: Perform Grand Average for ERPs',...
               '2. ERPLAB: Append ERPs',...
               '3. ERPLAB: Plot ERPs',...               
               '4. EEGLAB: Plot ERPImages',...
               '5. EEGLAB: Create STUDY',...
               '6. EEGLAB: Precompute STUDY variables',...
               '7. EEGLAB: Measure Projection',...
                };

% Set the type of initial files to be prompted for based on selected options
cleanSetFilesNeeded = [4,5];
erpFilesNeeded = 1:3;
studyFileNeeded = [6,7];
            
[selectedIndices, ok] = listdlg('PromptString','Select option(s) for ANGEL ERP Analysis:',...
                'SelectionMode','multiple',...
                'ListSize', [300,300],...
                'Name', 'ERP Analysis Options',...
                'ListString',optionsList);

% Select appropriate initial files based on selected options           
if max(ismember(selectedIndices, cleanSetFilesNeeded))
    % Decide the starting directory for selecting relevant files
    switch min(selectedIndices)
 
        case 4         % '4. EEGLAB: Plot ERPImages'
               startDir = ANGEL.erpEpochedDir;        
               
        case 5         % '5.EEGLAB: Create STUDY'
               startDir = ANGEL.eegEpochedDir;                  
    end
    cd(startDir);
    
elseif max(ismember(selectedIndices, erpFilesNeeded))      

    % Decide the starting directory for selecting relevant files
    switch min(selectedIndices)
 
        case 1        % 1. ERPLAB: Perform Grand Average for ERPs'
               startDir = ANGEL.erpAppendedPerSubjectDir;        
               
        case 2        % '2. ERPLAB: Append ERPs'
               startDir = ANGEL.erpGrandAveragedDir;  
               
        case 3        % '3. ERPLAB: Plot ERPs'
               startDir = ANGEL.erpAppendedPerGroupDir;                 
    end
    cd(startDir);    
    
elseif max(ismember(selectedIndices, studyFileNeeded))      
  
    cd(ANGEL.studyDir); 
    
end  % End of initial files selection
  

%% Don't invoke EEGLAB, just reinitialize the variables
EEG = [];
ALLEEG = [];
CURRENTSET = 0;
ERP = [];

    
%% Start of grand averaging
if max(selectedIndices == 1)   

    [error] = NPhy_DoGrandAverage(ANGEL);

end  % End of grand averaging

%% Start of ERP appending per investigator type
if max(selectedIndices == 2)   

    [error] = NPhy_AppendERPs(ANGEL);

end  % End of ERP appending per investigator type  


%% Start of automated ERP plotting
if max(selectedIndices == 3)   

    [error] = NPhy_PlotERPs(ANGEL);

end  % End of  automated ERP plotting 

%% Start of ERPImage creation
if max(selectedIndices == 4)   

    [error] = NPhy_PlotERPImage(ANGEL);

end  % End of ERPImage creation 

%% Start of STUDY creation
if max(selectedIndices == 5)   
     
    for erpNo = 1:length(ANGEL.erpLabels)
         [error] = NPhy_CreateSTUDY(ANGEL, ANGEL.erpLabels{erpNo});
    end

end  % End of STUDY creation 


%% Start of precompute STUDY variables
if max(selectedIndices == 6)   
    
    for erpNo = 1:length(ANGEL.erpLabels)
         % Can compute channels, components or both
         [error] = NPhy_PrecomputeSTUDYVariables(ANGEL, ANGEL.erpLabels{erpNo}, 'components');
    end    

end  % End of precompute STUDY variables    

%% Start of Measure Projection Analysis
if max(selectedIndices == 7)   

    % Load all the option variables for Measure Projection
    if ~exist('MPOption.mat', 'file')
        [varFileName, ~, ~] = uigetfile('*.mat', 'Select the Measure Projection Options file');
        load(varFileName);
    else
        load('MPOption.mat', 'mpOption');
    end

    ANGEL.option = mpOption;
    
    for erpNo = 1:length(ANGEL.erpLabels)
        [error] = NPhy_MeasureProjection(ANGEL, ANGEL.erpLabels{erpNo});
    end 
end  % End of Measure Projection Analysis   

if(error)
    warning('\n ******\nSome of the steps were unsuccessful, please check the log file ******\n');
                fprintf(ANGEL.logFileID,...
                    '\n ******\nSome of the steps were unsuccessful, please check the whole log file ******\n');
end  
       

%Get current date and time to record ending time
endTime = clock;
processingTime = int16(etime(endTime, startTime));
processingTimeMinutes = int16(processingTime/60);
timeStampEnd = strrep(strrep(datestr(fix(endTime)), ':','.'), ' ', '_');

fprintf('\nEnding ANGEL ERP Analysis at: %s \n', timeStampEnd);
fprintf(ANGEL.logFileID, '\n******\nEnding ANGEL ERP Analysis at: %s\n******\n', timeStampEnd);

fclose(ANGEL.logFileID);

fprintf(['Job done in approximately ',sprintf('%d',processingTimeMinutes),' minutes\n']);
msgbox(['Job done in approximately ',sprintf('%d',processingTimeMinutes),' minutes'],...
    'Message', 'help');

%close(file_waitbar);
% close all;
% clear all;