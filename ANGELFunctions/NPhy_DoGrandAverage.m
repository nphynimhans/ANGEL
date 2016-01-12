function [errorReturn] =  NPhy_DoGrandAverage(ANGEL)
%NPhy_DoGrandAverage Run Grand Average for the given paradigm
%   
% Date of Creation: 9 Apr 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

for groupNo = 1:length(ANGEL.groupList)
        
    for gameLevelNo = 1:length(ANGEL.gameList)
        
        for erpNo = 1:length(ANGEL.erpLabels)

            try
                cd(ANGEL.erpAppendedPerSubjectDir);
                %% Select Master Directory having .erp files of different subjects 
                % Automated file selection
                filePattern = ['*', cell2mat(ANGEL.groupList(groupNo)),...
                    '*', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo)), '*.erp'];

                tempFileList = dir(filePattern);

                if isempty(tempFileList)
                    fprintf('\n*****No files available for condition: %s  ****\n', filePattern);
                    continue;
                end
                % Convert struct to cell 
                fileList = {tempFileList.name};

                availableFiles = length(fileList);

                if availableFiles < ANGEL.sampleSize
                    % Select available files
                    fileList = fileList(1, 1:availableFiles);
                else
                    % Select the sample size
%                    fileList = datasample(fileList(1), ANGEL.sampleSize, 'Replace', false);
                    fileList = fileList(1, 1:ANGEL.sampleSize);
                end

                % Take care of single file selection
                if ischar(fileList) == 1
                    fileList = {fileList};
                end
                
                sampleSize = length(fileList);

                %% Load .erp file to EEG structure
                [~, ALLERP] = pop_loaderp(...
                        'filename', fileList,...
                        'filepath', ANGEL.erpAppendedPerSubjectDir);

                %% Grand Average the .erp files
                ERP = pop_gaverager( ALLERP , 'Criterion',  25, 'Erpsets',  1:length(fileList), 'ExcludeNullBin', 'on', 'SEM', 'on' );

                % Save the grand average file
                ERP = pop_savemyerp(ERP, 'erpname',...
                 [ANGEL.paradigmID, '_', cell2mat(ANGEL.groupList(groupNo)), '_', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo))],...
                 'filename',...
                 [ANGEL.paradigmID, '_', cell2mat(ANGEL.groupList(groupNo)), '_', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo)), '.erp'],...
                 'filepath', ANGEL.erpGrandAveragedDir, 'Warning', 'on');

                ERP = [];
                ALLERP = [];
                
            catch error
                errorReturn = 1;  
                warning('\n ******\nSkipped processing condition :  %s \n ******\n', cell2mat(ANGEL.erpLabels(erpNo)));
                fprintf(ANGEL.logFileID,...
                    '\n ******\nSkipped processing condition: %s with error: %s\n ******\n',...
                    cell2mat(ANGEL.erpLabels(erpNo)), error.message);
                
            end
            
        end  %End of conditions
        
    end % End of game level
    
end   % End of grouplist
    
fprintf('\nCompleted Grand averaging\n');
fprintf(ANGEL.logFileID,'\nCompleted Grand averaging\n');
end

