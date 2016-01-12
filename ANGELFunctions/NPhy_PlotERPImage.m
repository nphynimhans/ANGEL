function [errorReturn] =  NPhy_PlotERPImage(ANGEL)
%NPhy_PlotERPImage Plot ERPImages for the given paradigm
%   
% Date of Creation: 13 Apr 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;
     
for gameLevelNo = 1:length(ANGEL.gameList)

    for erpNo = 1:length(ANGEL.erpLabels)

        try

            % For now do it only for P300 ANGEL2 and ERN ANGEL3
            if ~((gameLevelNo == 2 && erpNo == 1) || (gameLevelNo == 3 && erpNo == 2))
                continue;            
            end
            
            %% Select Master Directory having .erp files of different subjects 
            % Automated file selection
            
            filePattern = [ANGEL.paradigmID, '_', cell2mat(ANGEL.gameList(gameLevelNo)), '_', cell2mat(ANGEL.erpLabels(erpNo)), '.erp'];

            tempFileList = dir(filePattern);

            if isempty(tempFileList)
                fprintf('\n*****No files available for condition: %s  ****\n', filePattern);
                continue;
            end
            % Convert struct to cell 
            fileList = {tempFileList.name};

                       
            eeglab redraw      

            ERP = [];
        catch error
            errorReturn = 1;  
            warning('\n ******\nSkipped plotting for condition :  %s \n ******\n', cell2mat(ANGEL.erpLabels(erpNo)));
            fprintf(ANGEL.logFileID,...
                '\n ******\nSkipped plotting for condition: %s with error: %s\n ******\n',...
                cell2mat(ANGEL.erpLabels(erpNo)), error.message);

        end

    end  %End of conditions

end % End of game level
    
fprintf('\nERPImage creation not yet done\n');
fprintf(ANGEL.logFileID,'\nERPImage creation not yet done\n');
    
end
