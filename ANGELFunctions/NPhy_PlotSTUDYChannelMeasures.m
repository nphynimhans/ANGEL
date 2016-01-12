function [errorReturn] =  NPhy_PlotSTUDYChannelMeasures(ANGEL, erp)
%NPhy_PlotSTUDYChannelMeasures Plot Channel Measures for STUDY 
%   
% Date of Creation: 25 May 2015
% Authors: Ajay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errorReturn = 0;

tempFileList = dir(['ANGEL_', erp, '.study']);
targetFolder = [ANGEL.resultsDir, '\'];

if isempty(tempFileList)
    fprintf('\n*****Study file missing for erp %s****\n', erp);
    fprintf(ANGEL.logFileID,'\n ******\nStudy file missing for erp %s****\n', erp);
    errorReturn = 1;
    return;
end
% Convert struct to cell 
fileList = {tempFileList.name};

try
    [STUDY, ALLEEG] = pop_loadstudy(...
        'filename', fileList{:},...
        'filepath', ANGEL.studyDir);    

    %Setting the parameters
    STUDY = pop_statparams(STUDY, 'condstats','on','naccu',100,'method','perm','mcorrect','fdr','alpha',0.05);
    STUDY = pop_erpparams(STUDY, 'filter',35,'plotconditions','together','ylim',[-4 4] ,'timerange',[-200 800] ,'topotime',[]);
    STUDY = pop_specparams(STUDY, 'plotconditions','together','ylim',[0 4] ,'freqrange',[1 30] );
    STUDY = pop_erspparams(STUDY, 'timerange',[-200 800] ,'freqrange',[1 30] );
    STUDY = pop_erspparams(STUDY, 'ersplim',[-2 2] ,'itclim',0.5);
    
    
    switch erp

        case 'C1'
            electrode = 'POz';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode}, 'plotsubjects', 'off' );
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);   

        case 'CD'
            electrode = 'CPz';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);   

        case 'ERN'
            electrode = 'FCz';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);   

        case 'LRP'
            electrode = 'C4';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);              

            electrode = 'C3';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);                 
 
            
            %Topography - time
            STUDY = pop_erpparams(STUDY, 'topotime',[250 500] );
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{'F10' 'AF8' 'AF4' 'F2' 'E5' 'FCz' 'E7' 'E8' 'FP2' 'E10' 'Fz' 'E12' 'FC1' 'E14' 'FPz' 'AFz' 'E17' 'E18' 'F1' 'E20' 'E21' 'FP1' 'AF3' 'F3' 'E25' 'AF7' 'F5' 'FC5' 'FC3' 'C1' 'E31' 'F9' 'F7' 'FT7' 'E35' 'C3' 'CP1' 'FT9' 'E39' 'E40' 'C5' 'CP3' 'E43' 'T9' 'T7' 'TP7' 'CP5' 'E48' 'E49' 'E50' 'P5' 'P3' 'E53' 'E54' 'CPz' 'E56' 'M1' 'P7' 'E59' 'P1' 'E61' 'Pz' 'E63' 'P9' 'PO7' 'PO5' 'PO3' 'E68' 'E69' 'O1' 'E71' 'POz' 'CB1' 'E74' 'Oz' 'E76' 'PO4' 'E78' 'E79' 'E80' 'E81' 'E82' 'O2' 'PO6' 'P2' 'E86' 'CP2' 'CB2' 'E89' 'PO8' 'E91' 'P4' 'CP4' 'E94' 'P10' 'P8' 'P6' 'CP6' 'E99' 'M2' 'E101' 'TP8' 'C6' 'C4' 'C2' 'E106' 'E107' 'T8' 'E109' 'E110' 'FC4' 'FC2' 'E113' 'T10' 'E115' 'FT8' 'FC6' 'E118' 'E119' 'E120' 'FT10' 'F8' 'F6' 'F4' 'E125' 'E126' 'E127' 'E128' 'Cz'});
            saveas(gcf, [targetFolder, erp, '_STUDY_Topo_250to500ms'],'fig');
            close(gcf);
            
            
            %Topography - frequency
            STUDY = pop_specparams(STUDY, 'ylim',[-4 4] );
            STUDY = pop_specparams(STUDY, 'topofreq',[4 8] );
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{'F10' 'AF8' 'AF4' 'F2' 'E5' 'FCz' 'E7' 'E8' 'FP2' 'E10' 'Fz' 'E12' 'FC1' 'E14' 'FPz' 'AFz' 'E17' 'E18' 'F1' 'E20' 'E21' 'FP1' 'AF3' 'F3' 'E25' 'AF7' 'F5' 'FC5' 'FC3' 'C1' 'E31' 'F9' 'F7' 'FT7' 'E35' 'C3' 'CP1' 'FT9' 'E39' 'E40' 'C5' 'CP3' 'E43' 'T9' 'T7' 'TP7' 'CP5' 'E48' 'E49' 'E50' 'P5' 'P3' 'E53' 'E54' 'CPz' 'E56' 'M1' 'P7' 'E59' 'P1' 'E61' 'Pz' 'E63' 'P9' 'PO7' 'PO5' 'PO3' 'E68' 'E69' 'O1' 'E71' 'POz' 'CB1' 'E74' 'Oz' 'E76' 'PO4' 'E78' 'E79' 'E80' 'E81' 'E82' 'O2' 'PO6' 'P2' 'E86' 'CP2' 'CB2' 'E89' 'PO8' 'E91' 'P4' 'CP4' 'E94' 'P10' 'P8' 'P6' 'CP6' 'E99' 'M2' 'E101' 'TP8' 'C6' 'C4' 'C2' 'E106' 'E107' 'T8' 'E109' 'E110' 'FC4' 'FC2' 'E113' 'T10' 'E115' 'FT8' 'FC6' 'E118' 'E119' 'E120' 'FT10' 'F8' 'F6' 'F4' 'E125' 'E126' 'E127' 'E128' 'Cz'});
            saveas(gcf, [targetFolder, erp, '_STUDY_Topo_4to8Hz'],'fig');
            close(gcf);            
            
 
        case 'MMN'
            electrode = 'FCz';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{'FCz'});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{'FCz'});   
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_C4'],'fig');
            close(gcf);            
    

        case 'N2pc'
            electrode = 'PO8';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);   
    
  
        case 'N170'
            electrode = 'PO8';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;            
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);   
            

        case 'P300'
            electrode = 'Pz';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;      
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);           


        case 'P50'

            electrode = 'FCz';
            STUDY = std_erpplot(STUDY,ALLEEG,'channels',{electrode});
            NPhy_UpdateFigureProperties;                  
            saveas(gcf, [targetFolder, erp, '_STUDY_ERP_', electrode],'fig');
            close(gcf);            
            
            STUDY = std_specplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_Spectra_', electrode],'fig');
            close(gcf);
            
            STUDY = std_erspplot(STUDY,ALLEEG,'channels',{electrode});
            saveas(gcf, [targetFolder, erp, '_STUDY_ERSP_', electrode],'fig');
            close(gcf);
            
            STUDY = std_itcplot(STUDY,ALLEEG,'channels',{electrode});    
            saveas(gcf, [targetFolder, erp, '_STUDY_ITC_', electrode],'fig');
            close(gcf);              
            
    
    end
        
        
catch error
    errorReturn = 1;  
    warning('\n ******\nSkipped precompute \n ******\n');
    fprintf(ANGEL.logFileID,'\n ******\nSkipped precompute  with error %s\n ******\n', error.message);
end
    
fprintf('\nSTUDY Precompute completed\n');
fprintf(ANGEL.logFileID,'\nSTUDY Precompute completed\n');
    
end
