function [errorReturn] =  NPhy_PrecomputeSTUDYVariables(ANGEL, erp, precomputeType)
%NPhy_PrecomputeSTUDYVariables Precompute variables for STUDY 
%   
% Date of Creation: 13 Apr 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

tempFileList = dir(['ANGEL_', erp, '.study']);

if isempty(tempFileList)
    fprintf('\n*****Study file missing for erp %s*0***\n', erp);
    fprintf(ANGEL.logFileID,'\n ******\nStudy file missing for erp %s*0***\n', erp);
    errorReturn = 1;
    return;
end
% Convert struct to cell 
fileList = {tempFileList.name};

try
    [STUDY ALLEEG] = pop_loadstudy(...
        'filename', fileList{:},...
        'filepath', ANGEL.studyDir);    


    switch precomputeType

        case 'components'

            %% Precompute ERP, Scalp topography & PSD for all channels - for use in clustering
            [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG,...
                'components', 'interp', 'on',...
                'erp', 'on', 'spec', 'on', 'ersp', 'on', 'itc','on','scalp','on', 'erpim', 'off', ...
                'erspparams', {'cycles', [3 0.5], 'padratio', 1, 'freqs',[3 30]},...
                'erpimparams', {'nlines', 10,'smoothing', 10, 'erpimageopt' ,{'NoShow','on'}});

        case 'channels'

            %% Precompute ERSP & ITC for specific channels - To save time
            [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG,...
                'channels', 'interp', 'on',...
                'erp', 'on', 'spec', 'on', 'ersp', 'on', 'itc','on','scalp','on','erpim', 'off', ...
                'erspparams', {'cycles', [3 0.5], 'padratio', 1, 'freqs',[3 30]},...
                'erpimparams', {'nlines', 10,'smoothing', 10, 'erpimageopt' ,{'NoShow','on'}});

        case 'all'

            %% Precompute ERP, Scalp topography & PSD for all channels - for use in clustering
            [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG,...
                'components', 'interp', 'on',...
                'erp', 'on', 'spec', 'on', 'ersp', 'on', 'itc','on','scalp','on', 'erpim', 'off', ...
                'erspparams', {'cycles', [3 0.5], 'padratio', 1, 'freqs',[3 30]},...
                'erpimparams', {'nlines', 10,'smoothing', 10, 'erpimageopt' ,{'NoShow','on'}});        

            %% Precompute ERSP & ITC for specific channels - To save time
            [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG,...
                'channels', 'interp', 'on',...
                'erp', 'on', 'spec', 'on', 'ersp', 'on', 'itc','on','scalp','on','erpim', 'off', ...
                'erspparams', {'cycles', [3 0.5], 'padratio', 1, 'freqs',[3 30]},...
                'erpimparams', {'nlines', 10,'smoothing', 10, 'erpimageopt' ,{'NoShow','on'}});

    end
        
        
catch error
    errorReturn = 1;  
    warning('\n ******\nSkipped precompute \n ******\n');
    fprintf(ANGEL.logFileID,'\n ******\nSkipped precompute  with error %s\n ******\n', error.message);
end
    
fprintf('\nSTUDY Precompute completed\n');
fprintf(ANGEL.logFileID,'\nSTUDY Precompute completed\n');
    
end
