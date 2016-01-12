function [errorReturn] =  NPhy_SetDefaultPlottingProperties(ANGEL, actionType)
%NPhy_SetDefaultPlottingProperties Set default properties for Matlab plots
%   
% Date of Creation: 28 May 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

try

if strcmp(actionType, 'set')    
    set(groot,'defaultLineLineWidth',3);
    set(groot,'defaultAxesLineStyleOrder',{'-','*',':','o','+'});
    set(groot,'defaultAxesColorOrder',[0 0 0; 0 0 0; 0 0 0; 0 0 0; 0 0 0]);
    
else
    set(groot,'defaultLineLineWidth','remove');
    set(groot,'defaultAxesLineStyleOrder','remove');
    set(groot,'defaultAxesColorOrder','remove');
end

    
    
        
catch error
    errorReturn = 1;  
    warning('\n ******\nSkipped setting default plotting properties \n ******\n');
    fprintf(ANGEL.logFileID,'\n ******\nSkipped precompute  with error %s\n ******\n', error.message);
end
    
fprintf('\nSetting default plot properties completed\n');
fprintf(ANGEL.logFileID,'\nSetting default plot properties completed\n');
    
end
