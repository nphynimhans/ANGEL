function [errorReturn] =  NPhy_PlotERPs(ANGEL)
%NPhy_PlotERPs Plot ERPs for the given paradigm
%   
% Date of Creation: 12 Apr 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

if strcmp(ANGEL.acquisitionID, 'EGI') && strcmp(ANGEL.channelReduction, 'no')

    channels = {[129 62],...%[Cz Pz] for 'P300' 
                [11 6],...  %[Fz  FCz] for 'ERN'
                [65 90],... %[PO7 PO8] for 'N170'
                [6 129],... % [FCz Cz]} for 'CD'
                1,...       % [PO7/PO8 Contra minus Ipsi] for 'N2pc'
                1,...       % [C3'/C4' Contra minus Ipsi] for 'LRP'
                [129 62],...% [Cz  Pz] for 'MMN'
                [129 62],...% [Cz  Pz] for 'P50'
                [75 72]};   % [Oz  POz]for 'C1'
            
else
    
        channels = {[28 48],... %[Cz Pz] for 'P300'
                    [10 19],... %[Fz  FCz] for 'ERN'
                    [53 59],... %[PO7 PO8] for 'N170'
                    [19 28],... % [FCz Cz]} for 'CD'
                    1,...       % [PO7/PO8 Contra minus Ipsi] for 'N2pc'
                    1,...       % [C3'/C4' Contra minus Ipsi] for 'LRP'
                    [28 48],... % [Cz  Pz] for 'MMN'
                    [28 48],... % [Cz  Pz] for 'P50'
                    [62 56]};   % [Oz  POz]for 'C1'
end    
    
% Cell for plot variables - ERP,    Bins,    ChannelsEGI,      Box,   XScale,                           Yscale
erpPlotVars(1,:) = {'P300',   [1 2 5 6 3 4], channels{1},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 5.0   -4:5 ]}; %[Cz Pz]};
erpPlotVars(2,:) = {'ERN',    [1 2 5 6 3 4], channels{2},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 4.0   -4:4 ]};%[Fz  FCz]};
erpPlotVars(3,:) = {'N170',   [1 19 10],     channels{3},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -3.0 2.0   -3:4 ]};%[PO7 PO8]};
erpPlotVars(4,:) = {'CD',     [1 2 4],       channels{4},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 4.0   -4:4 ]};% [FCz Cz]};
erpPlotVars(5,:) = {'N2pc',   [1 2 3],       channels{5},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 4.0   -4:4 ]};    % [PO7/PO8 Contra minus Ipsi]};
erpPlotVars(6,:) = {'LRP',    [1 2 3],       channels{6},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 4.0   -4:4 ]};    % [C3'/C4' Contra minus Ipsi]};
erpPlotVars(7,:) = {'MMN',    [1 2],         channels{7},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 4.0   -4:4 ]};% [Cz  Pz]};
erpPlotVars(8,:) = {'P50',    [1 2],         channels{8},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -4.0 4.0   -4:4 ]};% [Cz  Pz]};
erpPlotVars(9,:) = {'C1',     [1 2 3],       channels{9},     [ 1 2], [ -200.0 800.0   -200:100:800 ],  [ -2.0 4.0   -2:4 ]};% [Oz  POz]};


cd(ANGEL.erpAppendedPerGroupDir);

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

            % Take care of single file selection
            if ischar(fileList) == 1
                fileList = {fileList};
            end

            %% Load .erp file to EEG structure
            ERP = pop_loaderp(...
                    'filename', fileList,...
                    'filepath', ANGEL.erpAppendedPerGroupDir);
           
            %% Plot the ERP  
            error = NPhy_PlotERPHelper(ANGEL, ERP, erpPlotVars, erpNo);
            
            if error
                errorReturn = 1;  
                warning('\n ******\nSkipped plotting for condition :  %s \n ******\n', cell2mat(ANGEL.erpLabels(erpNo)));
                fprintf(ANGEL.logFileID,...
                    '\n ******\nSkipped plotting for condition: %s with error: %s\n ******\n',...
                    cell2mat(ANGEL.erpLabels(erpNo)), error.message);               
            end

            %% Cleanup before further processing
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
    
fprintf('\nERP Plotting completed\n');
fprintf(ANGEL.logFileID,'\nERP Plotting completed\n');
    
end
