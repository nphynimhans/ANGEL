function [errorReturn] =  NPhy_AppendERPs(ANGEL)
%NPhy_AppendERPs Append the grand averaged ERPs for the given paradigm
%   
% Date of Creation: 11 Apr 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

        
for gameLevelNo = 1:length(ANGEL.gameList)

    for erpNo = 1:length(ANGEL.erpLabels)

        try
            cd(ANGEL.erpGrandAveragedDir);
            %% Select Master Directory having .erp files of different subjects 
            % Automated file selection
            
            filePattern = [ANGEL.paradigmID, '*', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo)), '*.erp'];

            tempFileList = dir(filePattern);

            if isempty(tempFileList)
                fprintf('\n*****No files available for condition: %s  ****\n', filePattern);
                continue;
            end
            % Convert struct to cell 
            fileList = {tempFileList.name};

            % Take care of single file selection
            if ischar(fileList) == 1
                fileList = {fileList};
            end

            %% Load .erp file to EEG structure
            [~, ALLERP] = pop_loaderp(...
                    'filename', fileList,...
                    'filepath', ANGEL.erpGrandAveragedDir);
           
            %% Append the averaged files
            ERP = pop_appenderp( ALLERP , 'Erpsets',  1:length(fileList), 'Prefixes', 'erpname' );            
            

            %% Save the appended file
            ERP = pop_savemyerp(ERP, 'erpname',...
             [ANGEL.paradigmID, '_', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo))],...
             'filename',...
             [ANGEL.paradigmID, '_', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo)), '.erp'],...
             'filepath', ANGEL.erpAppendedPerGroupDir, 'Warning', 'on');

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
    
fprintf('\nCompleted Appending ERPs per group for %s\n', ANGEL.paradigmID);
fprintf(ANGEL.logFileID,'\nCompleted Appending ERPs per group for %s\n', ANGEL.paradigmID);
    
end
