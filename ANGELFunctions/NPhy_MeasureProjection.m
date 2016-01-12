function [errorReturn] =  NPhy_MeasureProjection(ANGEL, erp)
%NPhy_MeasureProjection Run Measure Projection Analysis
%   
% Date of Creation: 14 May 2015
% Authors: Ajay
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
    [STUDY, ALLEEG] = pop_loadstudy(...
        'filename', fileList{:},...
        'filepath', ANGEL.studyDir);  
    
    erpPath = [ANGEL.resultsDir, '\', erp];
    
    %Get current date and time to store as part of log file name
    timeLogTemp = strrep(strrep(datestr(fix(clock)), ':','.'), ' ', '_');
    measureFileID =  fopen([erpPath, 'MPA_Analysis_AnatomicalInfo_', timeLogTemp, '.txt'], 'w');
    
    % Measures: ERP, ERSP, ITC, Spec
    for measureNo = 1:length(ANGEL.measures)
    
        measureName = lower(ANGEL.measures{measureNo});
        
        fprintf(measureFileID, 'Measure Name: %s\n', measureName);
        
        %Use caseconversion function (externally downloaded from
        %matlabcentral for titlecase
        measureFunction = caseconvert(ANGEL.measures{measureNo}, 'title');
    
        %% read the data (calculated measure, etc.) from STUDY
        STUDY.measureProjection.(measureName).object = pr.(sprintf('dipoleAndMeasureOfStudy%s',measureFunction))(STUDY, ALLEEG);

        % define HeadGRID based on GUI options (you can change this in your script of course)
        STUDY.measureProjection.(measureName).headGrid = pr.headGrid(ANGEL.option.headGridSpacing);

        % do the actual projection 
        STUDY.measureProjection.(measureName).projection = pr.meanProjection(...
            STUDY.measureProjection.(measureName).object,...
            STUDY.measureProjection.(measureName).object.getPairwiseMutualInformationSimilarity, ...
            STUDY.measureProjection.(measureName).headGrid,... 
            'numberOfPermutations', ANGEL.option.numberOfPermutations,...
            'stdOfDipoleGaussian', ANGEL.option.standardDeviationOfEstimatedDipoleLocation,...
            'numberOfStdsToTruncateGaussian', ANGEL.option.numberOfStandardDeviationsToTruncatedGaussian,...
            'normalizeInBrainDipoleDenisty', fastif(ANGEL.option.normalizeInBrainDipoleDensity,'on', 'off'));

        %% visualize significant voxels individually (voxel p < 0.01)
        STUDY.measureProjection.(measureName).projection.plotVoxel(0.01);
        saveas(gcf, [erpPath, '_', upper((measureName)),'_VoxelPlot'],'fig');
        close(gcf);

        %% visualize significant voxels as a volume (voxel p < 0.01)
        STUDY.measureProjection.(measureName).projection.plotVolume(0.01);
        saveas(gcf, [erpPath, '_', upper((measureName)),'_VolumePlot'],'fig');
        close(gcf);
        
        %% create domains

        % find out the significance level to use (e.g. corrected by FDR)
        if ANGEL.option.([measureName, 'FdrCorrection'])
           significanceLevel =...
               fdr(STUDY.measureProjection.(measureName).projection.convergenceSignificance(...
               STUDY.measureProjection.(measureName).headGrid.insideBrainCube(:)),...
               ANGEL.option.([measureName, 'Significance']));
        else
           significanceLevel = ANGEL.option.([measureName, 'Significance']);
        end;

        maxDomainExemplarCorrelation = ANGEL.option.([measureName, 'MaxCorrelation']);

        % the command below makes the domains using parameters significanceLevel and maxDomainExemplarCorrelation:
        STUDY.measureProjection.(measureName).projection = ...
            STUDY.measureProjection.(measureName).projection.createDomain(...
            STUDY.measureProjection.(measureName).object, maxDomainExemplarCorrelation, significanceLevel);

        %% visualize domains by voxel
        STUDY.measureProjection.(measureName).projection.plotVoxelColoredByDomain;
        saveas(gcf, [erpPath, '_', upper((measureName)),'_VoxelColouredByDomain'],'fig');
        close(gcf);        

        %% visualize domains by 'volume' 
        STUDY.measureProjection.(measureName).projection.plotVolumeColoredByDomain;  
        saveas(gcf, [erpPath, '_', upper((measureName)),'_VolumeColouredByDomain'],'fig');
        close(gcf);   
        
        for domainNo = 1:length(STUDY.measureProjection.(measureName).projection.domain)

            currentDomain = STUDY.measureProjection.(measureName).projection.domain(domainNo);
            currentDomain.plotVolumeColoredByAnatomy;
            saveas(gcf, [erpPath, '_', upper((measureName)),'_Domain', int2str(domainNo),'_ByAnatomy'],'fig');
            close(gcf);
            
            fprintf(measureFileID, 'Domain Number: %d\n', domainNo);
            anatomicalInfo = currentDomain.getAnatomicalInformation;
            for regionNo = 1:length(anatomicalInfo)
                fprintf(measureFileID, 'Domain Anatomical Info: %s\n', anatomicalInfo{regionNo});            
            end
            fprintf(measureFileID, '\n'); 
            
            currentDomain.plotMri
            saveas(gcf, [erpPath, '_', upper((measureName)),'_Domain', int2str(domainNo),'_MRI'],'fig');
            close(gcf);
            
            %Don't plot cortex - it crashes matlab
            %domain1.plotCortex;
            clear currentDomain;
        end
    
    end
        
catch error
    errorReturn = 1;  
    warning('\n ******\nSkipped Measure Projection\n ******\n');
    fprintf(ANGEL.logFileID,...
        '\n ******\nSkipped Measure Projection with error: %s\n ******\n', error.message);

end

fclose(measureFileID);  
fprintf('\nMeasure Projection not yet done\n');
fprintf(ANGEL.logFileID,'\nMeasure Projection not yet done\n');  
end
