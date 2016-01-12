%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NIMHANS_PerformANGELAnalysis_SubjectLevel
% Adapted from set of Matlab scripts 
% 
% Purpose: Batch ERP Analysis for the ANGEL Cognitive Task at a single
% subject level
%
% Date of Creation: 7 Mar 2015
% Authors: Arun and Ajay
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

ANGEL.eventDir = [ANGEL.outputDir,'\Events'];
if ~exist(ANGEL.eventDir, 'dir')
    mkdir(ANGEL.eventDir);
end

ANGEL.setDir = [ANGEL.outputDir,'\Set'];
if ~exist(ANGEL.setDir, 'dir')
    mkdir(ANGEL.setDir);
end

ANGEL.cleanDir = [ANGEL.outputDir,'\Clean'];
if ~exist(ANGEL.cleanDir, 'dir')
    mkdir(ANGEL.cleanDir);
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

ANGEL.icaDir = [ANGEL.outputDir,'\ICA'];
if ~exist(ANGEL.icaDir, 'dir')
    mkdir(ANGEL.icaDir);
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
               '1. Convert raw files to .set',...
               '2. Import Event Markers and Adjust sound marker latencies for P50 and MMN',...
               '3. Rename/Reduce Channels using 10-5 nomenclature',...
               '4. Remove artifacts',...
               '5. Perform general preprocessing',...
               '6. ERPLAB: Epoch around events',...
               '7. ERPLAB: Average',...
               '8. ERPLAB: Append Conditions for ERPs',...
               '9. Run ICA',...
               '10.EEGLAB: Epoch around events',...
               '11.EEGLAB: Copy ICA weights',...
               '12.EEGLAB: Run Dipole Fitting Analysis',...
                };

% Set the type of initial files to be prompted for based on selected options
rawFilesNeeded = 1;
setFilesNeeded = 2:4;
cleanSetFilesNeeded = [5:7, 9:12];
erpFilesNeeded = 8;
            
[selectedIndices, ok] = listdlg('PromptString','Select option(s) for ANGEL ERP Analysis:',...
                'SelectionMode','multiple',...
                'ListSize', [400,400],...
                'Name', 'ERP Analysis Options',...
                'ListString',optionsList);

% Select appropriate initial files based on selected options           
if max(ismember(selectedIndices, rawFilesNeeded))
    
    [ANGEL.fileList, ANGEL.rawDir, ~] = uigetfile({'*.raw'},...
        ['Select the raw files for option: ', optionsList{min(selectedIndices)}],...
        ANGEL.rawDir,...
        'MultiSelect', 'on');  
    cd(ANGEL.rawDir);
    
elseif max(ismember(selectedIndices, setFilesNeeded))
    
    [ANGEL.fileList, ANGEL.setDir, ~] = uigetfile({'*.set'},...
        ['Select the set files for option: ', optionsList{min(selectedIndices)}],...
        ANGEL.setDir,...
        'MultiSelect', 'on');    
    cd(ANGEL.setDir);
elseif max(ismember(selectedIndices, cleanSetFilesNeeded))
    % Decide the starting directory for selecting relevant files
    switch min(selectedIndices)
 
        case {5, 6, 9, 10}   % '5. Perform general preprocessing'
                             % '6. ERPLAB: Epoch around events'
                             % '9.Run ICA'
                             % '10.EEGLAB: Epoch around events'
               startDir = ANGEL.cleanDir;
            
        case 7               % '7. ERPLAB: Average'
               startDir = ANGEL.erpEpochedDir;        
               
        case {11, 12}        % '11.EEGLAB: Copy ICA weights'
                             % '12.EEGLAB: Run Dipole Fitting Analysis'

               startDir = ANGEL.eegEpochedDir;                  
    end
    
    [ANGEL.fileList, ~, ~] = uigetfile({'*.set'},...
        ['Select the set files for option: ', optionsList{min(selectedIndices)}],...
        startDir,...
        'MultiSelect', 'on');   
    cd(startDir);
elseif max(ismember(selectedIndices, erpFilesNeeded))    

    [erpFileList, ~, ~] = uigetfile({'*.erp'},...
        ['Select the erp files for option: ', optionsList{min(selectedIndices)}],...
        ANGEL.erpAveragedDir,...
        'MultiSelect', 'on');      
    
    cd(ANGEL.erpAveragedDir);  
    
    uniqueFileList = cellfun(@(x) x(1:ANGEL.prefixLength),erpFileList,'UniformOutput',false);
    uniqueFileList = unique(uniqueFileList);
  
    ANGEL.fileList  = cellfun(@(x) [x, '_Top.erp'],uniqueFileList,'UniformOutput',false);
           
end  % End of initial files selection

% Take care of single file selection
if ischar(ANGEL.fileList) == 1
    ANGEL.fileList = {ANGEL.fileList};
end            

%% Don't invoke EEGLAB, just reinitialize the variables
EEG = [];
ALLEEG = [];
CURRENTSET = 0;
ERP = [];

% Iterate through the list of files
for fileListNo = 1:length(ANGEL.fileList) 
    
    file = ANGEL.fileList{fileListNo};
    
    %% Start of raw file conversion
    if max(selectedIndices == 1)   

        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_ConvertRawToSet(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    else
        
    end  % End of raw file conversion
    
    %% Start of sound marker latency adjustment
    if max(selectedIndices == 2)   
        
        if(CURRENTSET == 0)
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', file, 'filepath',ANGEL.setDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
            
        end

        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_HandleEvents(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of sound marker latency adjustment    


    %% Start of channel renaming (and reduction if needed)
    if max(selectedIndices == 3)   

        if(CURRENTSET == 0)
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', file, 'filepath', ANGEL.setDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
            
        end
      
        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_RenameOrReduceChannels(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of channel renaming (and reduction if needed) 
    
    
    %% Start of artifact removal
    if max(selectedIndices == 4)   

        if(CURRENTSET == 0)
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', file, 'filepath', ANGEL.setDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
            
        end
        
        
        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_RemoveArtifacts(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of artifact removal 
    
    
    %% Start of general preprocessing - low pass filter, downsample and average rereference
    if max(selectedIndices == 5)   

        if(CURRENTSET == 0)
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', file, 'filepath', ANGEL.cleanDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
            
        end
        
        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_PreProcessingForEpoching(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of general preprocessing    
    
    %% Start of ERPLAB Epoching
    if max(selectedIndices == 6)   

        if(CURRENTSET == 0)
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', file, 'filepath', ANGEL.cleanDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
            
        end
        
        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_EpochByERPLAB(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of ERPLAB Epoching    
    
    %% Start of ERPLAB Averaging
    if max(selectedIndices == 7)   
        
        if(CURRENTSET == 0)
            epochedFileName = file;
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', epochedFileName, 'filepath', ANGEL.erpEpochedDir);  
            EEG = eeg_checkset(EEG);
            [ERP, epochedFileName, error] = NPhy_AverageEpochs(EEG, ANGEL, epochedFileName);   
            
        else
            % Get the filename (keep the length short)
            subjectPrefix = file(1:ANGEL.prefixLength);
            epochedFileNamePattern = [ANGEL.erpEpochedDir, '\', subjectPrefix, '*.set'];
            epochedFileListStruct = dir(epochedFileNamePattern);
            epochedFileList = {epochedFileListStruct.name};

            %% Loop for each epoch condition for the given file
            for epochedFileNo = 1:length(epochedFileList)

                epochedFileName = epochedFileList{epochedFileNo};     

                % Load .set file to EEG structure
                EEG = pop_loadset('filename', epochedFileName, 'filepath', ANGEL.erpEpochedDir);  
                EEG = eeg_checkset(EEG);

                [ERP, epochedFileName, error] = NPhy_AverageEpochs(EEG, ANGEL, epochedFileName); 

            end % End of loop for each epoch condition        
        end

    end  % End of ERPLAB Averaging    
    
    %% Start of Append Conditions for each ERP
    if max(selectedIndices == 8)   

        cd(ANGEL.erpAveragedDir);  
        % Get the filename (keep the length short)
        subjectPrefix = file(1:ANGEL.prefixLength);
        erpFileNamePattern = [subjectPrefix, '*.erp'];
        %erpFileNamePattern = [subjectPrefix, '*Tone*.erp'];
        erpFileListStruct = dir(erpFileNamePattern);
        erpFileList = {erpFileListStruct.name};

        for erpNo = 1:length(ANGEL.erpLabels)
        %for erpNo = 7:8
           [filesToBeAppended, error] = NPhy_GetFilesToBeAppended(ANGEL,subjectPrefix,erpFileList, erpNo);
           if(error)
                continue;
            end
            %% Append all ERP corresponding files for specific ERPs for each participant             

            [error] = NPhy_AppendERPConditions(ANGEL, subjectPrefix, erpNo, filesToBeAppended);
        end       

    end  % End of Append Conditions for each ERP      

    %% Start of ICA
    if max(selectedIndices == 9)   

        ALLEEG = [];  % Reinitialize ALLEEG before starting EEGLAB work
        % Load .set file to EEG structure
        EEG = pop_loadset('filename', file, 'filepath', ANGEL.cleanDir);  
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG

        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_DoICA(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of ICA    
    

    %% Start of EEGLAB based epoching
    if max(selectedIndices == 10)   

        if(CURRENTSET == 0)
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', file, 'filepath', ANGEL.cleanDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
         end        
        
        [ALLEEG, EEG, CURRENTSET, file, error ] = NPhy_EpochByEEGLAB(ALLEEG, EEG, CURRENTSET, ANGEL, file);
        
        if(error)
            continue;
        end
    end  % End of EEGLAB based epoching    
    

    %% Start of Copying ICA weight matrix to EEGLAB epoched files
    if max(selectedIndices == 11)   

        if(CURRENTSET == 0)
            epochedFileName = file;
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', epochedFileName, 'filepath', ANGEL.eegEpochedDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG

            [~, ~, CURRENTSET, file, error ] = NPhy_CopyICAWeights(ALLEEG, EEG, CURRENTSET, ANGEL, epochedFileName);            
            
        else
            % Get the filename (keep the length short)
            subjectPrefix = file(1:ANGEL.prefixLength);
            epochedFileNamePattern = [ANGEL.eegEpochedDir, '\', subjectPrefix, '*.set'];
            epochedFileListStruct = dir(epochedFileNamePattern);
            epochedFileList = {epochedFileListStruct.name};


            %% Loop for each epoch condition for the given file
            for epochedFileNo = 1:length(epochedFileList)

                epochedFileName = epochedFileList{epochedFileNo};     
      
                ALLEEG = [];
                % Load .set file to EEG structure
                EEG = pop_loadset('filename', epochedFileName, 'filepath', ANGEL.eegEpochedDir);  
                [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG

                [~, ~, CURRENTSET, file, error ] = NPhy_CopyICAWeights(ALLEEG, EEG, CURRENTSET, ANGEL, epochedFileName);

            end % End of loop for each epoch condition
        end % End of check if we are running this segment directly 
    end  % End of Copying ICA weight matrix to EEGLAB epoched files   
    

    %% Start of Dipole Fitting
    if max(selectedIndices == 12)   
        
        if(CURRENTSET == 0)
            epochedFileName = file;
            % Load .set file to EEG structure
            EEG = pop_loadset('filename', epochedFileName, 'filepath', ANGEL.eegEpochedDir);  
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG

            [~, ~, CURRENTSET, file, error] = NPhy_DIPFIT(ALLEEG, EEG, CURRENTSET, ANGEL, epochedFileName);            
            
        else
            % Get the filename (keep the length short)
            subjectPrefix = file(1:ANGEL.prefixLength);
            epochedFileNamePattern = [ANGEL.eegEpochedDir, '\', subjectPrefix, '*.set'];
            epochedFileListStruct = dir(epochedFileNamePattern);
            epochedFileList = {epochedFileListStruct.name};


            %% Loop for each epoch condition for the given file
            for epochedFileNo = 1:length(epochedFileList)

                epochedFileName = epochedFileList{epochedFileNo};     
      
                ALLEEG = [];
                % Load .set file to EEG structure
                EEG = pop_loadset('filename', epochedFileName, 'filepath', ANGEL.eegEpochedDir);  
                [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG

                [~, ~, CURRENTSET, file, error ] = NPhy_DIPFIT(ALLEEG, EEG, CURRENTSET, ANGEL, epochedFileName);

            end % End of loop for each epoch condition
        end % End of check if we are running this segment directly 

    end  % End of Dipole Fitting  
    
                     
    %% Reinitialize variables
    EEG = [];
    ALLEEG = [];
    CURRENTSET = 0;
    
end        %End of for loop - processing all files    

%Get current date and time to record ending time
endTime = clock;
processingTime = int16(etime(endTime, startTime));
processingTimeMinutes = int16(processingTime/60);
timeStampEnd = strrep(strrep(datestr(fix(endTime)), ':','.'), ' ', '_');

fprintf('\nEnding ANGEL ERP Analysis at: %s \n', timeStampEnd);
fprintf(ANGEL.logFileID, ['\n ******\nEnding ANGEL ERP Analysis at:  %s \n',... 
    ' ******\n'], timeStampEnd);

fclose(ANGEL.logFileID);

fprintf(['Job done in approximately ',sprintf('%d',processingTimeMinutes),' minutes\n']);
msgbox(['Job done in approximately ',sprintf('%d',processingTimeMinutes),' minutes'],...
    'Message', 'help');

%close(file_waitbar);
% close all;
% clear all;