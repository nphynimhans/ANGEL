function [ALLEEG, EEG, CURRENTSET, returnFile, errorReturn] = NPhy_DoICA(ALLEEG, EEG, CURRENTSET, ANGEL, inputFile)
%NPhy_DoICA Perform Independent Component Analysis
%
%   Run ICA on the cleaned set files
%
% Date of Creation: 19 Mar 2015
% Authors: Arun and Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
returnFile = inputFile;
errorReturn = 0;

% Get the filename (keep the length short)
fileLabel = inputFile(1:ANGEL.prefixLength);

try

%% Delete 1 channel to avoid rank loss due to average referencing during ICA
EEG = pop_select(EEG,'nochannel',EEG.nbchan);
[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');


%% Epoching on all Stimprobes (non-overlapping epochs without baseline correction) 
% Only one stimprobe in our case   
for erpConditionNo = 1:length(ANGEL.continuousFileEventLabels)            

    try
             
        % Get the event markers 
        events = ANGEL.continuousEventMarkers{erpConditionNo}; 

        % Save the continuous file before the first epoching attempt
        if erpConditionNo == 1
            continuousEEG = EEG;
        end

        % Do epoching
        EEG = pop_epoch(continuousEEG, events, ANGEL.icaEpochs,...
            'newname', [continuousEEG.setname,'_',ANGEL.continuousFileEventLabels{erpConditionNo},'Epochs'],...
            'epochinfo', 'yes');    
        

        [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
            

        % Update dataset comments
        EEG.comments = pop_comments(EEG.comments,'',...
            'Non Overlapping Epoching done for ICA.',1);    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run ICA

        EEG = pop_runica(EEG,'icatype','runica');
        
        % Update dataset coments
        EEG.comments = pop_comments(EEG.comments,'','ICA done.',1); 
        [ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG,EEG,CURRENTSET,'overwrite','on');
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%% Save the ICA matrix

        %% Saving the ICA matrix 
        ICAEEG.icawinv = EEG.icawinv;
        ICAEEG.icasphere = EEG.icasphere;
        ICAEEG.icaweights = EEG.icaweights;
        ICAEEG.icachansind = EEG.icachansind;
        ICAEEG.etc = EEG.etc;
        
        save([ANGEL.icaDir, '\', fileLabel, '.mat'], 'ICAEEG');

    catch error
        warning('\nSkipped ICA for the condition: %s for file: %s \n ******\n', ANGEL.continuousFileEventLabels{erpConditionNo}, inputFile);
        fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped ICA for the condition: %s for file: %s with error: %s\n ******\n',...
        ANGEL.continuousFileEventLabels{erpConditionNo},...
        inputFile, error.message);
        continue;
    end

end  % End of for loop - iterating over erp conditions

catch error 
    errorReturn = 1;
    warning('\n ******\nSkipped processing file :  %s \n ******\n', inputFile);
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped processing file: %s with error: %s\n ******\n',...
        inputFile, error.message);
end
fprintf(ANGEL.logFileID,'\nCompleted running ICA for : %s \n',inputFile);
end

