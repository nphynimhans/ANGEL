function [filesToBeAppended, errorReturn] = NPhy_GetFilesToBeAppended(ANGEL,subjectPrefix, fileList, erpNo)
%NPhy_GetFilesToBeAppended Helper Function get files to be appended
%
%   Useful before AppendERPConditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
errorReturn = 0;

% Get the .erp files specific to each ERP    
filesToBeAppended = cell(1,length(ANGEL.erpEventLabelClusters{erpNo}));

for conditionNo = 1:length(ANGEL.erpEventLabelClusters{erpNo})
    fileIndicesToBeAppended = find(cell2mat(cellfun(@(x) ~isempty(regexp(x,...
        [subjectPrefix,'\w*', ANGEL.erpEventLabelClusters{erpNo}{conditionNo},'\w*.erp'], 'once')),...
        fileList,'UniformOutput', false)));

    if isempty(fileIndicesToBeAppended)
        fprintf('\n*****No files available for Subject: %s; Condition: %s****\n',...
            subjectPrefix,...
            ANGEL.erpEventLabelClusters{erpNo}{conditionNo}); 
        fprintf(ANGEL.logFileID,...
            '\n*****No files available for Subject: %s; Condition: %s****\n',...
            subjectPrefix,...
            ANGEL.erpEventLabelClusters{erpNo}{conditionNo}); 
        continue;
    end
    filesToBeAppended{1,conditionNo} = fileList{fileIndicesToBeAppended};                    
end

% Make sure all ERP specific event files are present before appending
if min(cellfun(@(x) ~isempty(x),filesToBeAppended))

    % Handle special case for CD
    if ~isempty(regexpi(ANGEL.erpLabels{erpNo},'CD')) 

        % Skip ANGEL1 as there are no CD events
        if ~isempty(regexpi(subjectPrefix,'ANGEL1'))
            errorReturn = 1;

        % Use buttonpress files of ANGEL1 for CD
        else
            filesToBeAppended =...
                cellfun(@(x) strrep(x,'ANGEL2_Button','ANGEL1_Button'),...
                filesToBeAppended,'UniformOutput',false);
            filesToBeAppended =...
                cellfun(@(x) strrep(x,'ANGEL3_Button','ANGEL1_Button'),...
                filesToBeAppended,'UniformOutput',false);
        end
    end

else
    fprintf(ANGEL.logFileID,...
        '\n*****No files available for Subject: %s; for ERP: %s****\n',...
        subjectPrefix, ANGEL.erpLabels{erpNo});    
    
    fprintf(ANGEL.logFileID,...
    '\n*****No files available for Subject: %s; for ERP: %s****\n',...
    subjectPrefix, ANGEL.erpLabels{erpNo});
    
    
    errorReturn = 1;
end

fprintf(ANGEL.logFileID,...
    '\nCompleted getting files to be appended for: %s at %s \n',...
    subjectPrefix, ANGEL.erpLabels{erpNo});
end

