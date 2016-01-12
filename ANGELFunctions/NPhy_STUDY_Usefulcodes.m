%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY_Usefulcodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Useful for the methodology paper

%Setting the parameters
STUDY = pop_statparams(STUDY, 'condstats','on','naccu',100,'method','perm','mcorrect','fdr','alpha',0.05);
STUDY = pop_erpparams(STUDY, 'filter',35,'plotconditions','together','ylim',[-4 4] ,'timerange',[-200 800] ,'topotime',[]);
STUDY = pop_specparams(STUDY, 'plotconditions','together','ylim',[0 4] ,'freqrange',[1 30] );
STUDY = pop_erspparams(STUDY, 'timerange',[-200 800] ,'freqrange',[1 30] );
STUDY = pop_erspparams(STUDY, 'ersplim',[-2 2] ,'itclim',0.5);

%Plots
STUDY = std_erpplot(STUDY,ALLEEG,'channels',{'FCz'}, 'plotsubjects', 'on' );
STUDY = std_specplot(STUDY,ALLEEG,'channels',{'FCz'});
STUDY = std_erspplot(STUDY,ALLEEG,'channels',{'FCz'});
STUDY = std_itcplot(STUDY,ALLEEG,'channels',{'FCz'});


%Topography - time
STUDY = pop_erpparams(STUDY, 'topotime',[170 350] );
STUDY = std_specplot(STUDY,ALLEEG,'channels',{'F10' 'AF8' 'AF4' 'F2' 'E5' 'FCz' 'E7' 'E8' 'FP2' 'E10' 'Fz' 'E12' 'FC1' 'E14' 'FPz' 'AFz' 'E17' 'E18' 'F1' 'E20' 'E21' 'FP1' 'AF3' 'F3' 'E25' 'AF7' 'F5' 'FC5' 'FC3' 'C1' 'E31' 'F9' 'F7' 'FT7' 'E35' 'C3' 'CP1' 'FT9' 'E39' 'E40' 'C5' 'CP3' 'E43' 'T9' 'T7' 'TP7' 'CP5' 'E48' 'E49' 'E50' 'P5' 'P3' 'E53' 'E54' 'CPz' 'E56' 'M1' 'P7' 'E59' 'P1' 'E61' 'Pz' 'E63' 'P9' 'PO7' 'PO5' 'PO3' 'E68' 'E69' 'O1' 'E71' 'POz' 'CB1' 'E74' 'Oz' 'E76' 'PO4' 'E78' 'E79' 'E80' 'E81' 'E82' 'O2' 'PO6' 'P2' 'E86' 'CP2' 'CB2' 'E89' 'PO8' 'E91' 'P4' 'CP4' 'E94' 'P10' 'P8' 'P6' 'CP6' 'E99' 'M2' 'E101' 'TP8' 'C6' 'C4' 'C2' 'E106' 'E107' 'T8' 'E109' 'E110' 'FC4' 'FC2' 'E113' 'T10' 'E115' 'FT8' 'FC6' 'E118' 'E119' 'E120' 'FT10' 'F8' 'F6' 'F4' 'E125' 'E126' 'E127' 'E128' 'Cz'});

%Topography - frequency
STUDY = pop_specparams(STUDY, 'ylim',[-4 4] );
STUDY = pop_specparams(STUDY, 'topofreq',[4 8] );
STUDY = std_specplot(STUDY,ALLEEG,'channels',{'F10' 'AF8' 'AF4' 'F2' 'E5' 'FCz' 'E7' 'E8' 'FP2' 'E10' 'Fz' 'E12' 'FC1' 'E14' 'FPz' 'AFz' 'E17' 'E18' 'F1' 'E20' 'E21' 'FP1' 'AF3' 'F3' 'E25' 'AF7' 'F5' 'FC5' 'FC3' 'C1' 'E31' 'F9' 'F7' 'FT7' 'E35' 'C3' 'CP1' 'FT9' 'E39' 'E40' 'C5' 'CP3' 'E43' 'T9' 'T7' 'TP7' 'CP5' 'E48' 'E49' 'E50' 'P5' 'P3' 'E53' 'E54' 'CPz' 'E56' 'M1' 'P7' 'E59' 'P1' 'E61' 'Pz' 'E63' 'P9' 'PO7' 'PO5' 'PO3' 'E68' 'E69' 'O1' 'E71' 'POz' 'CB1' 'E74' 'Oz' 'E76' 'PO4' 'E78' 'E79' 'E80' 'E81' 'E82' 'O2' 'PO6' 'P2' 'E86' 'CP2' 'CB2' 'E89' 'PO8' 'E91' 'P4' 'CP4' 'E94' 'P10' 'P8' 'P6' 'CP6' 'E99' 'M2' 'E101' 'TP8' 'C6' 'C4' 'C2' 'E106' 'E107' 'T8' 'E109' 'E110' 'FC4' 'FC2' 'E113' 'T10' 'E115' 'FT8' 'FC6' 'E118' 'E119' 'E120' 'FT10' 'F8' 'F6' 'F4' 'E125' 'E126' 'E127' 'E128' 'Cz'});

%Clear the study
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Select the STUDY file
[file_List, rootDir, filterindex] = uigetfile({'*.study'}, ...
        'Select .study file to precompute ERSP & ITC', ...
        'MultiSelect', 'off');
% Take care of single file selection
if ischar(file_List) == 1
    file_List = {file_List};
end
cd(rootDir);

% Load the study
[STUDY ALLEEG] = pop_loadstudy(...
    'filename', file_List{:},...
    'filepath', rootDir);
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);

% Reduce components to analyze based on residual variance
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'commands',{{'inbrain' 'on' 'dipselect' 0.17}},'updatedat','on','savedat','on' );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);

% Precompute
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, 'components','recompute','off','erp','on','erpparams',{'rmbase' [-200 0] },'scalp','on','spec','on','specparams',{'specmode' 'fft' 'logtrials' 'off'},'erpim','off','erpimparams',{'nlines', 10, 'smoothing', 10,'erpimageopt',{'NoShow','on'}},'ersp','on','erspparams',{'cycles' [3 0.5]  'padratio' 1 'freqs' [3 30]  'ntimesout' 200},'itc','on');

% Precomputing ICA scalpmaps if failed using std_precomp
for file_no = 1:length(ALLEEG)    
    std_topo(ALLEEG(file_no), [], 'none', 'recompute','off');
    fprintf('Scalp maps computed for %s\n',ALLEEG(file_no).filename);
end

% Set stats & plot parameters
STUDY = pop_statparams(STUDY, 'groupstats','on','condstats','on','method','perm','mcorrect','fdr','alpha',0.05);
STUDY = pop_erspparams(STUDY, 'timerange',[-500 800] ,'freqrange',[1 30] );
STUDY = pop_erspparams(STUDY, 'ersplim',[-2 2] ,'itclim',0.5);

% Plot & Compute ERSP
STUDY = std_erspplot(STUDY,ALLEEG,'channels',{'Pz'}, 'plotsubjects', 'on' );
STUDY = std_erspplot(STUDY,ALLEEG,'channels',{'Pz'}, 'plotsubjects', 'on' ,'maskdata','off');
[STUDY, erspdata, ersptimes, erspfreqs, pgroup_ersp, pcond_ersp, pinter_ersp] =...
    std_erspplot(STUDY,ALLEEG,'channels',{'Pz'}, 'plotsubjects', 'on',...
    'topofreq',5);

% Plot & Compute ITC
[STUDY, itcdata, itctimes, itcfreqs, pgroup_itc, pcond_itc, pinter_itc] =...
    std_itcplot(STUDY,ALLEEG,'channels',{'Pz'}, 'plotsubjects', 'on',...
    'topofreq',5);

% Precluster
[STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1,{'dipoles' 'norm' 1 'weight' 10},{'ersp' 'npca' 10 'freqrange' [] 'timewindow' [] 'norm' 1 'weight' 1},{'itc' 'npca' 10 'freqrange' [] 'timewindow' [] 'norm' 1 'weight' 1});

% Cluster into different numbers
[STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  2 , 'outliers',  3 );
[STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  3 , 'outliers',  3 );
[STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  4 , 'outliers',  3 );
[STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  4 , 'outliers',  3 );
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);

%% Extract ERSP values
CDoff_window = SplitVec(find(sum(pgroup{1},1)/size(pgroup{1},1)==1),'consecutive');
CDon_window = SplitVec(find(sum(pgroup{2},1)/size(pgroup{2},1)==1),'consecutive');
CDinter_window = SplitVec(find(sum(pinter{3},1)/size(pinter{3},1)==1),'consecutive');
time1 = ersptimes(CDinter_window{1});
time2 = ersptimes(CDinter_window{2});

CNT_CDoff1 = squeeze(mean(mean(erspdata{1,1}(:,CDinter_window{1},1,:),1),2));
CNT_CDoff2 = squeeze(mean(mean(erspdata{1,1}(:,CDinter_window{2},1,:),1),2));

CNT_CDon1 = squeeze(mean(mean(erspdata{2,1}(:,CDinter_window{1},1,:),1),2));
CNT_CDon2 = squeeze(mean(mean(erspdata{2,1}(:,CDinter_window{2},1,:),1),2));

SCZ_CDoff1 = squeeze(mean(mean(erspdata{1,2}(:,CDinter_window{1},1,:),1),2));
SCZ_CDoff2 = squeeze(mean(mean(erspdata{1,2}(:,CDinter_window{2},1,:),1),2));

SCZ_CDon1 = squeeze(mean(mean(erspdata{2,2}(:,CDinter_window{1},1,:),1),2));
SCZ_CDon2 = squeeze(mean(mean(erspdata{2,2}(:,CDinter_window{2},1,:),1),2));

ThetaERSP.CDon1 = [CNT_CDon1;SCZ_CDon1];
ThetaERSP.CDon2 = [CNT_CDon2;SCZ_CDon2];
ThetaERSP.CDoff1 = [CNT_CDoff1;SCZ_CDoff1];
ThetaERSP.CDoff2 = [CNT_CDoff2;SCZ_CDoff2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Measure Projection Codes

% read the data (calculated measure, etc.) from STUDY
STUDY.measureProjection.ersp.object = pr.dipoleAndMeasureOfStudyErsp(STUDY, ALLEEG);

% define HeadGRID based on GUI options (you can change this in your script of course)
STUDY.measureProjection.ersp.headGrid = pr.headGrid(STUDY.measureProjection.option.headGridSpacing);

% do the actual projection 
STUDY.measureProjection.ersp.projection = pr.meanProjection(STUDY.measureProjection.ersp.object,...
STUDY.measureProjection.ersp.object.getPairwiseMutualInformationSimilarity, ...
STUDY.measureProjection.ersp.headGrid, 'numberOfPermutations', ...
STUDY.measureProjection.option.numberOfPermutations, 'stdOfDipoleGaussian',...
STUDY.measureProjection.option.standardDeviationOfEstimatedDipoleLocation,'numberOfStdsToTruncateGaussian',...
STUDY.measureProjection.option.numberOfStandardDeviationsToTruncatedGaussaian, 'normalizeInBrainDipoleDenisty', ...
fastif(STUDY.measureProjection.option.normalizeInBrainDipoleDenisty,'on', 'off'));

% visualize significant voxels individually (voxel p < 0.01)
STUDY.measureProjection.ersp.projection.plotVoxel(0.01);

% visualize significant voxles as a volume (voxel p < 0.01)
STUDY.measureProjection.ersp.projection.plotVolume(0.01);

% create domains
 
% find out the significance level to use (e.g. corrected by FDR)
if STUDY.measureProjection.option.('erspFdrCorrection')
   significanceLevel = fdr(STUDY.measureProjection.ersp.projection.convergenceSignificance(...
STUDY.measureProjection.ersp.headGrid.insideBrainCube(:)), STUDY.measureProjection.option.(['erspSignificance']));
else
   significanceLevel = STUDY.measureProjection.option.('erspSignificance');
end;

maxDomainExemplarCorrelation = STUDY.measureProjection.option.('erspMaxCorrelation');

% the command below makes the domains using parameters significanceLevel and maxDomainExemplarCorrelation:
STUDY.measureProjection.(measureName).projection = ...
STUDY.measureProjection.(measureName).projection.createDomain(...
STUDY.measureProjection.(measureName).object, maxDomainExemplarCorrelation, significanceLevel);

% visualize domains (change 'voxle' to 'volume' for a different type of visualization) 
STUDY.measureProjection.ersp.projection.plotVoxelColoredByDomain;

domainNumber = 3;
dipoleAndMeasure = STUDY.measureProjection.ersp.object; % get the ERSP and dipole data (dataAndMeasure object) from the STUDY structure.
domain = STUDY.measureProjection.ersp.projection.domain(domainNumber); % get the domain in a separate variable
projection  = STUDY.measureProjection.ersp.projection;
[dipoleId sortedDipoleDensity orderOfDipoles dipoleDenisty dipoleDenistyInRegion] = dipoleAndMeasure.getDipoleDensityContributionToRegionOfInterest(domain.membershipCube, projection, [1 0.05])% the last value, [1 0.05]) indicates that we want all the ICs that at least has a 0.05 chance of being in the domain. You may want to use 0.1 or even 0.5 to get fewer ICs.

domainICs = dipoleAndMeasure.createSubsetForId(dipoleId); % here we create a new variable that contain information only for dipoles associates with domain ICs.

domainNumber = 3;
dipoleAndMeasure = STUDY.measureProjection.ersp.object; % get the ERSP and dipole data (dataAndMeasure object) from the STUDY structure.
domain = STUDY.measureProjection.ersp.projection.domain(domainNumber); % get the domain in a separate variable
projection  = STUDY.measureProjection.ersp.projection;
headGrid = STUDY.measureProjection.ersp.headGrid;
[linearProjectedMeasure sessionConditionCell groupId uniqeDatasetId dipoleDensity] = dipoleAndMeasure.getMeanProjectedMeasureForEachSession(headGrid, domain.membershipCube, projection.projectionParameter);