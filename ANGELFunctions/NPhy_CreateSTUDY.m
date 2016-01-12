function [errorReturn] =  NPhy_CreateSTUDY(ANGEL, erp)
%NPhy_CreateSTUDY Create STUDY for EEGLAB epoched files
%   
% Date of Creation: 13 Apr 2015
% Authors: Arun and Ajay
% Updated by Ajay and Arun on 17 May 2015: Specifying the game levels
% for each ERP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

try
    cd(ANGEL.eegEpochedDir);
    
    switch erp
        case 'P300'
            tempFileList = dir('*ANGEL2_Frequent*.set');
            tempFileList2 = dir('*ANGEL2_Rare*.set');     

        case 'ERN'
            tempFileList = dir('*ANGEL3_Correct*.set');
            tempFileList2 = dir('*ANGEL3_Incorrect*.set');     
            
        case 'N170'
            tempFileList = dir('*ANGEL3_*Present*.set');
            tempFileList2 = dir('*ANGEL3_*Absent*.set');     
            
        case 'CD'
            tempFileList = dir('*ANGEL2_CD*.set');
            tempFileList2 = dir('*ANGEL2_CD*.set');                 
            
        case 'N2pc'
            tempFileList = dir('*ANGEL2_RightImage*.set');
            tempFileList2 = dir('*ANGEL2_LeftImage*.set');     
            
        case 'LRP'
            tempFileList = dir('*ANGEL2_LeftPress*.set');
            tempFileList2 = dir('*ANGEL2_RightPress*.set');      

        case 'MMN'
            tempFileList = dir('*ANGEL2_DeviantToneS1*.set');
            tempFileList2 = dir('*ANGEL2_StandardToneS1*.set');     
            
        case 'P50'
            tempFileList = dir('*ANGEL2_StandardToneS1*.set');
            tempFileList2 = dir('*ANGEL2_StandardToneS2*.set');                  

        case 'C1'
            tempFileList = dir('*ANGEL2_Top*.set');
            tempFileList2 = dir('*ANGEL2_Bottom*.set');               
                  
    end
    
    erpStudyDir = [ANGEL.eegEpochedDir,'\', erp];
    if ~exist(erpStudyDir, 'dir')
        mkdir(erpStudyDir);
    end
    tempFileList3 = dir([erpStudyDir, '\*.set']);
    
    if isempty(tempFileList) && isempty(tempFileList2) 
        
        if isempty(tempFileList3)
            fprintf('\n*****No set files available in this directory: %s\n ******\n', pwd);
            fprintf(ANGEL.logFileID,'\n ******\nSkipped STUDY creation as no set files were found in directory: %s\n ******\n', pwd);
            errorReturn = 1;
            return;
        end
    else

        % Convert struct to cell 
        fullFileList = [{tempFileList.name} {tempFileList2.name}];
        for fileNo = 1:length(fullFileList)
            movefile(fullFileList{fileNo}, erpStudyDir);
            movefile([fullFileList{fileNo}(1:(end - 4)), '.fdt'], erpStudyDir);
        end
    end
    
    cd(erpStudyDir);
        
    tempFileList = dir('*.set');
    fullFileList = {tempFileList.name};
    
    %% Create dataset information for STUDY
    index = 1;
    subjectNo = 1;
    for groupNo = 1:length(ANGEL.groupList)
        groupFileList =...
            fullFileList(strncmp(cellfun(@(x) x(4:end),fullFileList,...
            'UniformOutput',false),ANGEL.groupList{groupNo},3));
        
        if isempty(groupFileList)
            fprintf('\n*****No set files available for the group %s****\n', ANGEL.groupList{groupNo});
            fprintf(ANGEL.logFileID,'\n ******\nNo set files available for the group %s\n ******\n', ANGEL.groupList{groupNo});
            errorReturn = 1;
            return;
        end

        groupFileList = sort(groupFileList);

        for fileNo = 1:length(groupFileList)
            subjectName = groupFileList{fileNo}(1:9);
            fileName = groupFileList(fileNo);
            filePath = fullfile(erpStudyDir,fileName);
            sessionNo = str2double(groupFileList{fileNo}(16));

            for conditionNo = 1:length(ANGEL.erpEventLabels)
                if ~isempty(regexpi(fileName{:},ANGEL.erpEventLabels{conditionNo},'once'))
                    condition = ANGEL.erpEventLabels{conditionNo};
                end
            end

            command{index}{1} = 'index'; %#ok<*SAGROW>
            command{index}{2} = index;
            command{index}{3} = 'load';
            command{index}{4} = filePath{:};
            command{index}{5} = 'subject';
            command{index}{6} = num2str(subjectNo);
            command{index}{7} = 'session';
            command{index}{8} = sessionNo;
            command{index}{9} = 'condition';
            command{index}{10} = condition;
            command{index}{11} = 'group';
            command{index}{12} = ANGEL.groupList{groupNo};

            % Increment the index number
            index = index + 1;

            % Increment subject number after checking the next filename 
            % Handle multiple conditions per subject
            if fileNo < length(groupFileList)
                if ~strncmp(subjectName,groupFileList{fileNo+1}(1:9),9)
                    subjectNo = subjectNo + 1;
                end
            % Increment the subject number for the fresh group
            elseif fileNo == length(groupFileList)   
                subjectNo = subjectNo + 1;
            end                    
        end
    end

    eeglab;

    % Set memory options: 
    pop_editoptions( 'option_storedisk', 1);

    STUDY = [];
    %% Create STUDY
    [STUDY, ALLEEG] = std_editset(STUDY, [], 'commands', command);
    eeglab redraw

    [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
    [STUDY, ALLEEG] = std_editset(STUDY, ALLEEG, 'name',['ANGEL_', erp, '_STUDY'],'task','ANGEL','updatedat','on','savedat','on' );
    [STUDY] = pop_savestudy(STUDY, ALLEEG, 'filename',['ANGEL_', erp, '.study'],'filepath',ANGEL.studyDir); %#ok<*NASGU>
%    CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = 1:length(EEG);
    eeglab redraw

catch error
    errorReturn = 1;  
    warning('\n ******\nSkipped STUDY creation\n ******\n');
    fprintf(ANGEL.logFileID,'\n ******\nSkipped STUDY creation with error %s\n ******\n', error.message);
end
    
fprintf('\nSTUDY Creation completed\n');
fprintf(ANGEL.logFileID,'\nSTUDY Creation completed\n');
    
end
