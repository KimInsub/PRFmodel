%% s_pmHRFtests_parallel.m

% Create the names that will be used in this script
TR       = 1.5;
HRFTypes = {'friston','boynton','canonical','vista_twogammas','popeye_twogammas',...
            'afni_gam','afni_spm'};
% INPUTS
niftiBOLDfile  = fullfile(pmRootPath,'local',['synthDT55b_TR' num2str(TR) '_HRF-all.nii.gz']);
jsonSynthFile  = fullfile(pmRootPath,'local',['synthDT55b_TR' num2str(TR) '_HRF-all.json']);
stimNiftiFname = fullfile(pmRootPath,'local',['Stim55b_TR'    num2str(TR) '.nii.gz']);
inputNiftis = {niftiBOLDfile, jsonSynthFile, stimNiftiFname};
% OUTPUTS
aprfcssresultfName     = fullfile(pmRootPath,'local',['synthDT55c_result_aprfcss.mat']);
aprfresultfName        = fullfile(pmRootPath,'local',['synthDT55c_result_aprf.mat']);
vistaresultfName       = fullfile(pmRootPath,'local',['synthDT55b_result_vista.mat']);
vistaandhrfresultfName = fullfile(pmRootPath,'local',['synthDT55b_result_vistaandhrf.mat']);
popresultfName         = fullfile(pmRootPath,'local',['synthDT55b_result_pop.mat']);
popresultnohrffName    = fullfile(pmRootPath,'local',['synthDT55b_result_popnohrf.mat']);
afni4resultfName       = fullfile(pmRootPath,'local',['synthDT55b_result_afni4.mat']);
afni6resultfName       = fullfile(pmRootPath,'local',['synthDT55b_result_afni6.mat']);
outputNiftis = {aprfcssresultfName,aprfresultfName, vistaresultfName,vistaandhrfresultfName, ...
                popresultfName, popresultnohrffName, afni4resultfName, afni6resultfName};          
% Connect to fw
st   = scitran('stanfordlabs'); st.verify;
cc   = st.search('collection','collection label exact','PRF_StimDependence');

%% Generate the big synthDT file
if (0)
synthDTsep = {};
parfor nh=1:length(HRFTypes)
    COMBINE_PARAMETERS                    = struct();
    COMBINE_PARAMETERS.RF.Centerx0        = [5];
    COMBINE_PARAMETERS.RF.Centery0        = [5];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
    COMBINE_PARAMETERS.RF.Theta           = [0]; %, deg2rad(45)];
    COMBINE_PARAMETERS.RF.sigmaMajor      = [0.5,2,8];  % [1,2,3,4];
    COMBINE_PARAMETERS.RF.sigmaMinor      = 'same'; % 'same' for making it the same to Major
    COMBINE_PARAMETERS.TR                 = [TR];
    HRF                                   = struct();
    HRF(1).Type                           = HRFTypes{nh};
    COMBINE_PARAMETERS.HRF                = HRF;
    % Right now only the parameter for white noise can be edited.
    COMBINE_PARAMETERS.Noise.noise2signal = [0,0.2];
    synthDTsep{nh} = pmForwardModelTableCreate(COMBINE_PARAMETERS, 'mult',100);
    synthDTsep{nh} = pmForwardModelCalculate(synthDTsep{nh});
end
% Concatenate
synthDT = synthDTsep{1};
for nh=2:length(HRFTypes)
    synthDT = [synthDT; synthDTsep{nh}];
end
end

%% Create niftis and upload  to FW
if (0)
% Save the default niftis with different TR and HRF to be used as tests later on
% BOLD FILE
if ~exist(niftiBOLDfile, 'file')
    pmForwardModelToNifti(synthDT,'fname',niftiBOLDfile, 'demean',false);   
end
% Upload it
stts = st.fileUpload(niftiBOLDfile, cc{1}.collection.id, 'collection');
% JSON FILE
if ~exist(jsonSynthFile, 'file')
    % Encode json
    jsonString = jsonencode(synthDT(:,1:(end-1)));
    % Format a little bit
    jsonString = strrep(jsonString, ',', sprintf(',\r'));
    jsonString = strrep(jsonString, '[{', sprintf('[\r{\r'));
    jsonString = strrep(jsonString, '}]', sprintf('\r}\r]'));
    % Write it
    fid = fopen(jsonSynthFile, 'w');if fid == -1,error('Cannot create JSON file');end
    fwrite(fid, jsonString, 'char');fclose(fid);
    % Read the json
    %{
    A = struct2table(jsonread(jsonSynthFile));
    for na=1:width(A)
        if isstruct(A{:,na})
            A.(A.Properties.VariableNames{na}) = struct2table(A{:,na});
        end
    end
    %}
    % Upload it
    stts = st.fileUpload(jsonSynthFile, cc{1}.collection.id, 'collection');
end
% STIM FILE
if ~exist(stimNiftiFname, 'file')
    pm1            = prfModel; 
    pm1.TR         = TR;
    pm1.compute;
    stimNiftiFname = pm1.Stimulus.toNifti('fname',stimNiftiFname);
end
% Upload it to FW
    stts = st.fileUpload(stimNiftiFname, cc{1}.collection.id, 'collection');
end

%% Solve and upload to FW
if (0)
% SOLVE
%  - aPRF CSS=true
options = struct('seedmode',[0,1,2], 'display','off', 'maxpolydeg',0, ...
                  'usecss',true);
aprfcssresults = pmModelFit(inputNiftis, 'aprf', 'options', options);
save(aprfcssresultfName, 'aprfcssresults');
%  - aPRF CSS=false
options = struct('seedmode',[0,1,2], 'display','off', 'maxpolydeg',0, ...
                  'usecss',false);
aprfresults = pmModelFit(inputNiftis, 'aprf', 'options', options);
save(aprfresultfName, 'aprfresults');

%  - mrVista
vistaresults = pmModelFit(inputNiftis, 'mrvista','model','one gaussian', ...
                  'grid', false, 'wSearch', 'coarse to fine');
save(vistaresultfName, 'vistaresults');
%  - mrvista and hrf
vistaresultsandhrf = pmModelFit(inputNiftis, 'mrvista','model','one gaussian', ...
                    'grid', false, 'wSearch', 'coarse to fine and hrf');
save(vistaandhrfresultfName, 'vistaresultsandhrf');
%  - popeye, default with hrf search
popresults = pmModelFit(inputNiftis, 'popeye'); save(popresultfName, 'popresults');
%  - popeye no hrf
popresultsnohrf= pmModelFit(inputNiftis, 'popeyenohrf'); save(popnohrfresultfName, 'popresultsnohrf');
%  - Afni 4
afni4results = pmModelFit(inputNiftis, 'afni_4','afni_hrf','SPM'); save(afni4resultfName, 'afni4results');
%  - Afni 6
afni6results = pmModelFit(inputNiftis, 'afni_6','afni_hrf','SPM'); save(afni6resultfName, 'afni6results');


% UPLOAD
for nu=1:length(outputNiftis)
    resultfName = outputNiftis{nu}
    stts      = st.fileUpload(resultfName, cc{1}.collection.id, 'collection');
end
end

%% Load files (download to local if don't exist)
if (1)
% (Download and) read the input nifti-s (only the json for now)
for ni=1:length(inputNiftis)
    [fpath,fname,ext] = fileparts(inputNiftis{ni});
    if ~exist(inputNiftis{ni},'file')
        st.fw.downloadFileFromCollection(cc{1}.collection.id,[fname ext],inputNiftis{ni});
    end
    if strcmp(ext, '.json')
        SynthDT  = struct2table(jsonread(inputNiftis{ni}));
        for na=1:width(SynthDT),if isstruct(SynthDT{:,na})
            SynthDT.(SynthDT.Properties.VariableNames{na}) = struct2table(SynthDT{:,na});
        end,end
    end
end

% (Download and) read the output nifti-s
for outputNifti=outputNiftis
    if exist(outputNifti{:},'file'), load(outputNifti{:});
    else
        % TODO Check that the data is there before trying to download
        [~,fname,ext] = fileparts(outputNifti{:});
        load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
                        [fname ext],outputNifti{:}));
    end 
end
end

%% PLOT
if (1)
    paramDefaults = {'Centerx0','Centery0','Theta','sigmaMinor','sigmaMajor'};
    % Create the concatenated result table
    compTable  = pmResultsCompare(SynthDT, ... % Defines the input params
        {'aprf','aprfcss','vista','vistahrf','pop','popno','afni4','afni6'}, ... % Analysis names we want to see: 'aPRF','vista',
        {aprfresults,aprfcssresults,vistaresults,vistaresultsandhrf,popresults,popresultsnohrf,afni4results,afni6results}, ...
        'params', paramDefaults, ...
        'shorten names',true, ...
        'dotSeries', false);
    % Now create the new plots
    sortHRFlike = {'friston','vista_twogammas','afni_gam','boynton','afni_spm',...
        'popeye_twogammas','canonical'};  % sorted according noise=0, RFsize=2
  
    
    % PLOTS
    tools = {'aprf','vista','popno','afni4'};
    
    pmNoisePlotsByHRF(compTable, tools, ... % 'x0y0',[0,0],...
        'sortHRF',sortHRFlike,'usemetric','eccentricity', ...
        'noisevalues',[0,0.2], 'userfsize',2, 'ylims',[6.5,11.5])
    
    pmNoisePlotsByHRF(compTable, tools, ... % 'x0y0',[0,0],...
        'sortHRF',sortHRFlike,'usemetric','polarangle', ...
        'noisevalues',[0,0.2], 'userfsize',2, 'ylims',[39,53])
    
    pmNoisePlotsByHRF(compTable, tools, 'x0y0',[5,5],...
        'sortHRF',sortHRFlike,'usemetric','rfsize', ...
        'noisevalues',[0,0.2], 'userfsize',2, 'ylims',[0,8])

    
end
  

%% CLOUD POINTS PLOT
% Optional params to be used as varargin when creating the function
tools = {'aprf','aprfcss','vista','vistahrf','pop','popno','afni4','afni6'};
% tools = {'aprf','vista','popno','afni4'};
tools = {'aprfcss','vista'};

pmCloudOfResults(compTable, tools, ...
                 'onlyCenters', false, ...
                 'userfsize'  , 2, ...
                 'centerPerc' , 10, ...
                 'useHRF'     , 'vista_twogammas', ...
                 'lineStyle'  , '-', ...
                 'lineWidth'  , .7, ...
                 'noiselevel' , 0.2, ...
                 'newWin'     , true)



%%           
% % Revise and delete
% 
% {
% 
% 
% Read the files (black was rebooted and we need the files back)
% {
% cd(fullfile(pmRootPath,'local'));
% dateSelect = '20190902';
% allFiles   = [];
% for nh=1:length(HRFTypes)
%     tmp       = dir([HRFTypes{nh} '*_synthDT_parALL_' dateSelect '*']);
%     allFiles = [allFiles, tmp];
% end
% }
% 
% Load and concatenate it
% {
% res1    = load(allFiles(1).name);
% synthDT = res1.trozo1;
% for nh=2:(length(allFiles)*3)
%     res       = load(allFiles(nh).name);
%     trozoName = fieldnames(res);
%     synthDT = [synthDT; res.(trozoName{:})];
% end
% }
% 
% 
% 
% Create nifti-s
% The table is too big...
% {
% for nh=1:length(HRFTypes)
%     subTable  = synthDT(synthDT.HRF.Type==string(HRFTypes{nh}),:);
%    
%     % Create a tmp nifti file
%     niftiBOLDfile  = pmForwardModelToNifti(subTable, 'fname', ...
%                       fullfile(pmRootPath,'local',[char(HRFTypes{nh}) '_HRF_synthBOLD.nii.gz']));
% end
% }
% 
% Write the stimuli as a nifti
% pm1            = subTable.pm(1);
% pm1            = prfModel; 
% TR = 2; pm1.compute;
% stimNiftiFname = fullfile(pmRootPath,'local', 'defaultStim.nii.gz');
% stimNiftiFname = pm1.Stimulus.toNifti('fname',stimNiftiFname);
% 
% Upload it to fw
% st   = scitran('stanfordlabs'); st.verify;
% cc   = st.search('collection','collection label exact','PRF_StimDependence');
% stts = st.fileUpload(parALLsynthDTfName, cc{1}.collection.id, 'collection');
% 
% 
% Write the files
% Remove locations, only [5,5] for today
% synthDT55 = synthDT(synthDT.RF.Centerx0==5 & ...
%                   synthDT.RF.Centery0==5,:);
% TR = unique(synthDT55.TR);
% HRFs = unique(synthDT55.HRF.Type);
% 
% 
% TR = 1.5;
% Save the default niftis with different TR and HRF to be used as tests later on
% niftiBOLDfile = fullfile(pmRootPath,'local',['synthDT55_TR' num2str(TR) '_HRF-all.nii.gz']);
% if ~exist(niftiBOLDfile, 'file')
%     pmForwardModelToNifti(synthDT55,'fname',niftiBOLDfile, 'demean',false);
% end
% 
% jsonSynthFile = fullfile(pmRootPath,'local',['synthDT55_TR' num2str(TR) '_HRF-all.json']);
% if ~exist(jsonSynthFile, 'file')
%     Encode json
%     jsonString = jsonencode(synthDT55(:,1:(end-1)));
%     Format a little bit
%     jsonString = strrep(jsonString, ',', sprintf(',\r'));
%     jsonString = strrep(jsonString, '[{', sprintf('[\r{\r'));
%     jsonString = strrep(jsonString, '}]', sprintf('\r}\r]'));
%     Write it
%     fid = fopen(jsonSynthFile, 'w');if fid == -1,error('Cannot create JSON file');end
%     fwrite(fid, jsonString, 'char');fclose(fid);
%     Read the json
%     {
%     A = struct2table(jsonread(jsonSynthFile));
%     for na=1:width(A)
%         if isstruct(A{:,na})
%             A.(A.Properties.VariableNames{na}) = struct2table(A{:,na});
%         end
%     end
%     }
% end
% 
% 
% stimNiftiFname = fullfile(pmRootPath,'local', ['Stim55_TR' num2str(TR) '.nii.gz']);
% if ~exist(stimNiftiFname, 'file')
%     pm1            = prfModel; 
%     pm1.TR         = TR;
%     pm1.compute;
%     stimNiftiFname = pm1.Stimulus.toNifti('fname',stimNiftiFname);
% end
% 
% niftis = {niftiBOLDfile, jsonSynthFile, stimNiftiFname};
% 
% Solve per each tool
% and per each hrf
% 
% aPRF
% aprfresults = table();
% for nh=1:length(HRFTypes)
%     Obtain path to niftis
%     HRFType = HRFTypes{nh};
%     niftis = {fullfile(pmRootPath,'local',[char(HRFTypes{nh}) '_HRF_synthBOLD.nii.gz']), ...
%                stimNiftiFname};    
%     Solve with AnalyzePRF
%     options  = struct('seedmode',[0,1,2], 'display','off', 'maxpolydeg',0);
%     aprfresults.(HRFTypes{nh}) = pmModelFit(niftis, 'aprf', 'options', options);
%     aprfresults = pmModelFit(niftis, 'aprf', 'options', options);
% end
% Save it locally
% aprfresultfName = [HRFType '_result_aprf_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% aprfresultfName = ['synthDT55_result_aprf.mat'];
% save(fullfile(pmRootPath,'local',aprfresultfName), 'aprfresults');
% 
% mrVista
% for nh=1:length(HRFTypes)
%     Obtain path to niftis
%     HRFType = HRFTypes{nh};
%     niftis = {fullfile(pmRootPath,'local',[char(HRFTypes{nh}) '_HRF_synthBOLD.nii.gz']), ...
%                stimNiftiFname};    
%     
%            
%     Solve with mrvista
%     vistaresults    = pmModelFit(niftis, 'mrvista','model','one gaussian', ...
%         'grid', false, ... % if true, returns gFit
%         'wSearch', 'coarse to fine');
%     vistaresultfName = [HRFType '_result_vista_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
%     vistaresultfName = ['synthDT55_result_vista.mat'];
%     save(fullfile(pmRootPath,'local',vistaresultfName), 'vistaresults');
% end
% mrVista and hrf
% for nh=1:length(HRFTypes)
%     Obtain path to niftis
%     HRFType = HRFTypes{nh};
%     niftis = {fullfile(pmRootPath,'local',[char(HRFTypes{nh}) '_HRF_synthBOLD.nii.gz']), ...
%                stimNiftiFname};    
%     
%            
%     Solve with mrvista
%     vistaresultsandhrf    = pmModelFit(niftis, 'mrvista','model','one gaussian', ...
%         'grid', false, ... % if true, returns gFit
%         'wSearch', 'coarse to fine and hrf');
%     vistaresultfName = [HRFType '_result_vista_andhrf_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
%     vistaandhrfresultfName = ['synthDT55_result_vistaandhrf.mat'];
%     save(fullfile(pmRootPath,'local',vistaandhrfresultfName), 'vistaresultsandhrf');
% end
% 
% popeye
% for nh=1:length(HRFTypes) 
%     Obtain path to niftis
%     HRFType = HRFTypes{nh};
%     niftis = {fullfile(pmRootPath,'local',[char(HRFTypes{nh}) '_HRF_synthBOLD.nii.gz']), ...
%                stimNiftiFname};    
%     Solve
%     popresults        = pmModelFit(niftis, 'popeye_onegaussian');
%     
%     Save the results
%     popresultfName = [HRFType '_result_pop_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
%     popresultfName = ['synthDT55_result_pop.mat'];
%     save(fullfile(pmRootPath,'local',popresultfName), 'popresults');
% end
% 
% 
%     Solve: I created another docker and edited pmModelFit
%     Fix this and pass it as a parameter
%     popresultsnohrf        = pmModelFit(niftis, 'popeye_onegaussian');
%     
%     Save the results
%     popresultfName = [HRFType '_result_pop_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
%     popnohrfresultfName = ['synthDT55_result_pop-nohrf.mat'];
%     save(fullfile(pmRootPath,'local',popnohrfresultfName), 'popresultsnohrf');
% 
% 
% 
% 
% 
% 
% Afni 4
% results = {};
% afniresultfName = {};
% for nh=1:length(HRFTypes)
%     Obtain path to niftis
%     HRFType = HRFTypes{nh};
%     niftis = {fullfile(pmRootPath,'local',[char(HRFTypes{nh}) '_HRF_synthBOLD.nii.gz']), ...
%                stimNiftiFname};    
%     
%     afni4results         = pmModelFit(niftis, 'afni_4','afni_hrf','SPM');
%     afniresultfName{nh} = [HRFType '_result_afni4_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
%     afni4resultfName = ['synthDT55_result_afni4.mat'];
%     Save it
%     save(fullfile(pmRootPath,'local',afni4resultfName), 'afni4results');
%     
%     
% end
% for parfor
% for nh=1:length(HRFTypes)
%     tmpRes = results{nh};
%     save(fullfile(pmRootPath,'local',afniresultfName{nh}), 'tmpRes');
% end
% 
% 
% Afni 6
%     afni6results         = pmModelFit(niftis, 'afni_6','afni_hrf','SPM');
%     afniresultfName{nh} = [HRFType '_result_afni4_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
%     afni6resultfName = ['synthDT55_result_afni6.mat'];
%     Save it
%     save(fullfile(pmRootPath,'local',afni6resultfName), 'afni6results');
% 
%     
% 
%     
%     
%     
%     
%     
%     
%     
% Plot the files locally, for that we need to locate the files and download them. 
% If they are in the local folder, take from there instead of downloading them. 
% st          = scitran('stanfordlabs'); st.verify;
% cc          = st.search('collection','collection label exact','PRF_StimDependence');
% Check the file names and select the ones we want
% allFs       = st.search('file','collectionid',cc{1}.collection.id,'filetype','MATLAB data');
% 
% 
% 
% 
% 
% First the synthDT files, wich are the same for all of them
% synthDTcell = allFs(cellfun(@(s) (contains(s.file.name, '_synthDT_parALL_20190902')), allFs));
% Load it (download or from local)
% synthDT = table();
% for nf=1:length(synthDTcell)
%     localfname = fullfile(pmRootPath,'local',synthDTcell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% 
% Now do aprf 
% aprfResCell = allFs(cellfun(@(s) (contains(s.file.name,'_result_aprf_2019090')),allFs));
% Load it (download or from local)
% for nf=1:length(aprfResCell)
%     localfname = fullfile(pmRootPath,'local',aprfResCell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% Now do pop 
% aprfResCell = allFs(cellfun(@(s) (contains(s.file.name,'_result_pop_2019090')),allFs));
% Load it (download or from local)
% for nf=1:length(aprfResCell)
%     localfname = fullfile(pmRootPath,'local',aprfResCell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% 
% Now do vista 
% aprfResCell = allFs(cellfun(@(s) (contains(s.file.name,'_result_vista_2019090')),allFs));
% Load it (download or from local)
% for nf=1:length(aprfResCell)
%     localfname = fullfile(pmRootPath,'local',aprfResCell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% 
% Now do vista_hrf 
% aprfResCell = allFs(cellfun(@(s) (contains(s.file.name,'_result_vista_andhrf_2019090')),allFs));
% Load it (download or from local)
% for nf=1:length(aprfResCell)
%     localfname = fullfile(pmRootPath,'local',aprfResCell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% 
% Now do afni_4 
% aprfResCell = allFs(cellfun(@(s) (contains(s.file.name,'_result_afni4_2019090')),allFs));
% Load it (download or from local)
% for nf=1:length(aprfResCell)
%     localfname = fullfile(pmRootPath,'local',aprfResCell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% Now do afni_6
% aprfResCell = allFs(cellfun(@(s) (contains(s.file.name,'_result_afni6_2019090')),allFs));
% Load it (download or from local)
% for nf=1:length(aprfResCell)
%     localfname = fullfile(pmRootPath,'local',aprfResCell{nf}.file.name);
%     if exist(localfname,'file')
%         data{nf} = load(localfname);
%     else
%         Download and read the data from FW
%         [~,fname,ext] = fileparts(localfname);
%         tmp           = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%                              [fname ext],localfname));
%         Populate the table to know what is everything                 
%     end
% end
% 
% 
% 
% 
% 
% Plot the old and new plots. 
% Make the concatenated table
% paramDefaults = {'Centerx0','Centery0','Theta','sigmaMinor','sigmaMajor'};
% compTable = table();
% Concatenate several HRFs
% for nh=1:length(HRFTypes)
%     hrftype       = HRFTypes{nh};
%     Reconstruct the synthDT table back
%     trozo1nm = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_1_synthDT_parALL_20190902'])), allFs));
%     trozo2nm = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_2_synthDT_parALL_20190902'])), allFs));
%     trozo3nm = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_3_synthDT_parALL_20190902'])), allFs));
%     if length(trozo1nm)~=1 | length(trozo2nm)~=1 | length(trozo3nm)~=1
%         error('There is more than one element after filtering.')
%     end
%     load(fullfile(pmRootPath,'local',trozo1nm{1}.file.name));
%     load(fullfile(pmRootPath,'local',trozo2nm{1}.file.name));
%     load(fullfile(pmRootPath,'local',trozo3nm{1}.file.name));
%     tmpSynthDT = [trozo1; trozo2; trozo3];
%     
%     
%     Retrieve the aprf result for this HRF back
%     fName = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_result_aprf_2019090'])), allFs));
%     if size(fName,1) ~= 1
%         error('Filter the the results so that it returns only one')
%     else
%         load(fullfile(pmRootPath,'local',fName{1}.file.name));    
%     end
%     if height(aprfresults) ~= height(tmpSynthDT)
%         error('Height of synthetic and resutls for aprf is different')
%     end
%     Retrieve the vista result for this HRF back
%     fName = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_result_vista_2019090'])), allFs));
%     if size(fName,1) ~= 1
%         error('Filter the the results so that it returns only one')
%     else
%         load(fullfile(pmRootPath,'local',fName{1}.file.name));    
%     end
%     if height(vistaresults) ~= height(tmpSynthDT)
%         error('Height of synthetic and resutls for aprf is different')
%     end
%     Retrieve the vistahrf result for this HRF back
%     fName = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_result_vista_andhrf_2019090'])), allFs));
%     if size(fName,1) ~= 1
%         error('Filter the the results so that it returns only one')
%     else
%         andhrf = load(fullfile(pmRootPath,'local',fName{1}.file.name));    
%     end
%     if height(andhrf.vistaresults) ~= height(tmpSynthDT)
%         error('Height of synthetic and resutls for aprf is different')
%     end    
%     Retrieve the afni result for this HRF back
%     
%     Retrieve the popeye result for this HRF back
%     fName = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_result_pop_2019090'])), allFs));
%     if size(fName,1) ~= 1
%         error('Filter the the results so that it returns only one')
%     else
%         pop = load(fullfile(pmRootPath,'local',fName{1}.file.name));    
%     end
%     if height(pop.results) ~= height(tmpSynthDT)
%         error('Height of synthetic and resutls for aprf is different')
%     end
%     
%     Retrieve the afni4 result for this HRF back
%     fName = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_result_afni4_2019090'])), allFs));
%     if size(fName,1) ~= 1
%         error('Filter the the results so that it returns only one')
%     else
%         afni4 = load(fullfile(pmRootPath,'local',fName{1}.file.name));    
%     end
%     if height(afni4.tmpRes) ~= height(tmpSynthDT)
%         error('Height of synthetic and resutls for aprf is different')
%     end
%     
%     Retrieve the afni6 result for this HRF back
%     fName = allFs(cellfun(@(s) (contains(s.file.name, [hrftype '_result_afni6_2019090'])), allFs));
%     if size(fName,1) ~= 1
%         error('Filter the the results so that it returns only one')
%     else
%         afni6 = load(fullfile(pmRootPath,'local',fName{1}.file.name));    
%     end
%     if height(afni6.tmpRes) ~= height(tmpSynthDT)
%         error('Height of synthetic and resutls for aprf is different')
%     end
%             
%     
%     Create tables
%     tmp  = pmResultsCompare(tmpSynthDT, ... % Defines the input params
%                             {'aprf','vista','vistahrf','afni4','afni6','pop'}, ... % Analysis names we want to see: 'aPRF','vista',
%                             {aprfresults,vistaresults,andhrf.vistaresults,pop.results,afni4.tmpRes,afni6.tmpRes}, ... 
%                             'params', paramDefaults, ...
%                             'shorten names',true, ...
%                             'dotSeries', false); 
%      compTable = [compTable; tmp];                   
% end
% 
% Save all the data locally, so we don't need to go to all the generation
% process.
% save(fullfile(pmRootPath,'local','allData_v01.mat'), 'compTable')
% load(fullfile(pmRootPath,'local','allData_v01.mat'))
% 
% 
% Now create the new plots
% sortHRFlike = {'friston','vista_twogammas','afni_gam','boynton','afni_spm',...
%                'canonical','popeye_twogammas'};  % sorted according noise=0, RFsize=2
% pmNoisePlotsByHRF(compTable, {'aprf','vista','vistahrf'}, ... % 'x0y0',[0,0],...
%                   'sortHRF',sortHRFlike,'usemetric','eccentricity')
% 
% 
% pmNoisePlotsByHRF(compTable, {'aprf','vista','vistahrf'},'x0y0',[5,5],'sortHRF',sortHRFlike)
% 
% pmNoisePlotsByHRF(compTable, {'aprf','vista','vistahrf'},'x0y0',[0,-5],'sortHRF',sortHRFlike)
% 
% Plot the HRF in the same plot with hold
% pm    = prfModel;
% pm.TR = 1.5;
% 
% mrvNewGraphWin(['ALL HRFs']);
% for nh=1:length(sortHRFlike)
%     pm.HRF.Type = sortHRFlike{nh};
%     pm.HRF.compute;
%     x = pm.HRF.tSteps;
%     y = pm.HRF.values;
%     plot(x,y);hold on;
%     xlim([0,40])
%     grid on;
%     xlabel('time (sec)');
%     legend(strrep(sortHRFlike,'_','\_'))
% end
% 
% 
% Copy from below if needed, delete all at the end
% {
% 
% 
% 
% 
% 
% AFNI test to check circular versus elliptical
% - create hundreds of synthetic signals.
% - use the same HRF they use for solving it to generate the signal
% - vary the positions randomly in all of them, not controlling for them.
% Control this:
% - increasing levels of noise: 4 different levels for example
% - size of the prf: sigmaMinor = sigmaMajor = [1,2,3,4] for example. 
% 
% This is 4 (noise) x 4 (sigma size) x 2 (oldAfni,newAfni) groups. 
% In all of them, ideally, the sigma ratio (sigmaMajor/sigmaMinor) should 
% be 1+- epsilon. If it is not, or if it is for the old software and not for 
% the new, we'll have learned something. 
% }
% 
% 
% % IDEAL HRF: Create dataset for testing noiseless and noise values in all datasets. 
% 
% {
% DO aPRF
% COMBINE_PARAMETERS                    = struct();
% COMBINE_PARAMETERS.RF.Centerx0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Centery0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Theta           = [0]; %, deg2rad(45)];
% COMBINE_PARAMETERS.RF.sigmaMajor      = [0.5,1,2,4,8];  % [1,2,3,4];
% COMBINE_PARAMETERS.RF.sigmaMinor      = 'same'; % 'same' for making it the same to Major
% COMBINE_PARAMETERS.TR                 = [1.5];
%     HRF(1).Type                       = 'canonical';
% COMBINE_PARAMETERS.HRF                = HRF;
% Right now only the parameter for white noise can be edited. 
% COMBINE_PARAMETERS.Noise.noise2signal = [0:0.05:0.45];
% synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS, 'mult',100);
% synthDT = pmForwardModelCalculate(synthDT);
% Save it
% aprfsynthDTfName = ['synthDT_aprf_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',aprfsynthDTfName), 'synthDT');
% 
% Analyze it, it takes a lot of time
% results    = pmModelFit(synthDT, 'aprf', 'useParallel', true);
% Save the result, we don't want to lose it because matlab crashes...
% Use the same datetime to associate synthDT and result
% aprfresultfName = ['result_aprf_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% if exist(fullfile(pmRootPath,'local',aprfresultfName),'file')
%     error('Change file name or delete existing file.')
%     delete(fullfile(pmRootPath,'local',resultfName))
% else
%     save(fullfile(pmRootPath,'local',aprfresultfName), 'results');
% end
% 
% 
% 
% 
% 
% 
% 
% DO POPEYE
% COMBINE_PARAMETERS                    = struct();
% COMBINE_PARAMETERS.RF.Centerx0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Centery0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Theta           = [0]; %, deg2rad(45)];
% COMBINE_PARAMETERS.RF.sigmaMajor      = [0.5,1,2,4,8];  % [1,2,3,4];
% COMBINE_PARAMETERS.RF.sigmaMinor      = 'same'; % 'same' for making it the same to Major
% COMBINE_PARAMETERS.TR                 = [1.5];
%     HRF(1).Type                       = 'popeye_twogammas';
% COMBINE_PARAMETERS.HRF                = HRF;
% Right now only the parameter for white noise can be edited. 
% COMBINE_PARAMETERS.Noise.noise2signal = [0:0.05:0.45];
% synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS, 'mult',100);
% synthDT = pmForwardModelCalculate(synthDT);
% Save it
% popsynthDTfName = ['synthDT_pop_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',popsynthDTfName), 'synthDT');
% 
% Analyze it, it takes a lot of time
% results    = pmModelFit(synthDT, 'popeye_onegaussian');
% Save the result, we don't want to lose it because matlab crashes...
% Use the same datetime to associate synthDT and result
% popresultfName = ['results_pop_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% if exist(fullfile(pmRootPath,'local',popresultfName),'file')
%     error('Change file name or delete existing file.')
%     delete(fullfile(pmRootPath,'local',resultfName))
% else
%     save(fullfile(pmRootPath,'local',popresultfName), 'results');
% end
% 
% 
% 
%  
% 
% 
% DO mrVISTA
% COMBINE_PARAMETERS                    = struct();
% COMBINE_PARAMETERS.RF.Centerx0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Centery0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Theta           = [0]; %, deg2rad(45)];
% COMBINE_PARAMETERS.RF.sigmaMajor      = [0.5,1,2,4,8];  % [1,2,3,4];
% COMBINE_PARAMETERS.RF.sigmaMinor      = 'same'; % 'same' for making it the same to Major
% COMBINE_PARAMETERS.TR                 = [1.5];
%     HRF(1).Type                       = 'vista_twogammas';
% COMBINE_PARAMETERS.HRF                = HRF;
% TODO: implement a more complex noise addition system. 
% Right now only the parameter for white noise can be edited. 
% COMBINE_PARAMETERS.Noise.noise2signal = [0:0.05:0.45];
% synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS, 'mult',100);
% synthDT = pmForwardModelCalculate(synthDT);
% Save it
% vistasynthDTfName = ['synthDT_vista_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',vistasynthDTfName), 'synthDT');
% 
% Analyze it, it takes a lot of time
% results    = pmModelFit(synthDT, 'mrvista','model','one gaussian', ...
%                                         'grid', false, ... % if true, returns gFit
%                                         'wSearch', 'coarse to fine');
% Save the result, we don't want to lose it because matlab crashes...
% Use the same datetime to associate synthDT and result
% vistaresultfName = ['results_vista_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% if exist(fullfile(pmRootPath,'local',resultfName),'file')
%     error('Change file name or delete existing file.')
%     delete(fullfile(pmRootPath,'local',resultfName))
% else
%     save(fullfile(pmRootPath,'local',vistaresultfName), 'results');
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% DO AFNI
% COMBINE_PARAMETERS                    = struct();
% COMBINE_PARAMETERS.RF.Centerx0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Centery0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Theta           = [0]; %, deg2rad(45)];
% COMBINE_PARAMETERS.RF.sigmaMajor      = [0.5,1,2,4,8];  % [1,2,3,4];
% COMBINE_PARAMETERS.RF.sigmaMinor      = 'same'; % 'same' for making it the same to Major
% COMBINE_PARAMETERS.TR                 = [1.5];
%     HRF(1).Type                       = 'afni_spm';
% COMBINE_PARAMETERS.HRF                = HRF;
% TODO: implement a more complex noise addition system. 
% Right now only the parameter for white noise can be edited. 
% COMBINE_PARAMETERS.Noise.noise2signal = [0:0.05:0.45];
% synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS, 'mult',100);
% synthDT = pmForwardModelCalculate(synthDT);
% Save it
% afnisynthDTfName = ['synthDT_afnispm_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',afnisynthDTfName), 'synthDT');
% 
% Analyze it, it takes a lot of time
% results    = pmModelFit(synthDT, 'afni_4');
% Save the result, we don't want to lose it because matlab crashes...
% Use the same datetime to associate synthDT and result
% afniresultfName = ['results_afni4_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% if exist(fullfile(pmRootPath,'local',resultfName),'file')
%    error('Change file name or delete existing file.')
%     delete(fullfile(pmRootPath,'local',resultfName))
% else
%     save(fullfile(pmRootPath,'local',afniresultfName), 'results');
% end
% 
% 
% Now that they have been generated, and saved locally, load them to FW. 
% Next, we will check if they exist locally, otherwise download from FW.
%  ...and upload it to the collection
% 
% 
% THESE WILL BE 
% allFileNames = {
% fullfile(pmRootPath,'local','synthDT_aprf_oneCenter_20190825T212722.mat')
% fullfile(pmRootPath,'local','result_aprf_oneCenter_20190825T221545.mat')
% fullfile(pmRootPath,'local','synthDT_vista_oneCenter_20190826T015219.mat')
% fullfile(pmRootPath,'local','results_vista_oneCenter_20190826T020241.mat')
% fullfile(pmRootPath,'local','synthDT_afnispm_oneCenter_20190826T023028.mat')
% fullfile(pmRootPath,'local','results_afni4_oneCenter_20190826T094209.mat')
% fullfile(pmRootPath,'local','synthDT_pop_oneCenter_20190825T224055.mat')
% fullfile(pmRootPath,'local','results_pop_oneCenter_20190826T012732.mat')
% };
% 
% UPLOAD LOCAL FILES
% {
% st   = scitran('stanfordlabs'); st.verify;
% cc   = st.search('collection','collection label exact','PRF_StimDependence');
% 
% for nf=1:length(allFileNames)
%     localfname = allFileNames{nf};
%     stts = st.fileUpload(localfname, cc{1}.collection.id, 'collection');
%     Check that the data is there
%     [~,fname,ext] = fileparts(localfname);
%     data          = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%         [fname ext],localfname));
% end
% }
% 
% 
% 
% 
% {
% Identify the results we want to use manually
% If the file exists locally, read it, otherwise download from the server locally
% data = {};
% for nf=1:length(allFileNames)
%     localfname = allFileNames{nf};
%     if exist(localfname,'file')
%         data{nf}          = load(localfname);
%     else
%         Read the data
%         [~,fname,ext] = fileparts(localfname);
%         data{nf}          = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%             [fname ext],localfname));
%     end
% end
% 
% prfSynth   = load(fullfile(pmRootPath,'local','synthDT_aprf_oneCenter_20190825T212722.mat'));    % 1
% prfRes     = load(fullfile(pmRootPath,'local','result_aprf_oneCenter_20190825T221545.mat'));     % 2 
% 
% vistaSynth = load(fullfile(pmRootPath,'local','synthDT_vista_oneCenter_20190826T015219.mat'));   % 3
% vistaRes   = load(fullfile(pmRootPath,'local','results_vista_oneCenter_20190826T020241.mat'));   % 4
% 
% afni4Synth = load(fullfile(pmRootPath,'local','synthDT_afnispm_oneCenter_20190826T023028.mat')); % 5
% afni4Res   = load(fullfile(pmRootPath,'local','results_afni4_oneCenter_20190826T094209.mat'));   % 6
% 
% popSynth   = load(fullfile(pmRootPath,'local','synthDT_pop_oneCenter_20190825T224055.mat'));     % 7
% popRes     = load(fullfile(pmRootPath,'local','results_pop_oneCenter_20190826T012732.mat'));     % 8
% 
% 
% Plot the results ACCURACY AND PRECISION PLOT: by noise levels
% paramDefaults        = {'Centerx0','Centery0','Theta','sigmaMinor','sigmaMajor'};
% [compTable, tSeries] = pmResultsCompare(data{1}.synthDT, ... % Defines the input params
%                             {'aprf','vista','afni4','pop'}, ... % Analysis names we want to see: 'aPRF','vista',
%                             {data{2}.results, data{4}.results, data{6}.results, data{8}.results}, ... % results_analyzePRF,results_vista,
%                             'params', paramDefaults, ...
%                             'shorten names',true); 
%                         
% pmTseriesPlot(tSeries, prfSynth.synthDT(:,'TR'), 'voxel',[1:9], 'newWin',true, ...
%                             'to compare', {'synth','aprf','vista','afni4','pop'});
% 
% 
% Plot the tool comparison plots for noise and rfSize ACCURACY AND PRECISION PLOT: by noise levels
% pmNoiseSizePlots(compTable, {'aprf','vista','afni4','pop'})
% 
% CHECK the results, CLEAN, and PLOT again
% Well, the thing is that at least aPRF and popeye have several outliers that should be cleaned. 
% So, this is now a outlier cleaning tool, that will output:
%   - Cleaned result table. 
%   - A table with outlier counts, that will evaluate quality of analysis 
% [newDT,outlierReport] = pmResultsCleanOutliers(compTable,'outlierLevel',20);
% 
% Plot again, cleaned dataset
% pmNoiseSizePlots(newDT, {'aprf','vista','afni4','pop'},'randomHRF',false)
% }
% 
% 
% % RANDOM HRFs
% {
% DO RANDOM HRF
% COMBINE_PARAMETERS                    = struct();
% COMBINE_PARAMETERS.RF.Centerx0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Centery0        = [0];  % [-6 5 4 3 2 1 0 1 2 3 4 5 6];
% COMBINE_PARAMETERS.RF.Theta           = [0]; %, deg2rad(45)];
% COMBINE_PARAMETERS.RF.sigmaMajor      = [0.5,1,2,4,8];  % [1,2,3,4];
% COMBINE_PARAMETERS.RF.sigmaMinor      = 'same'; % 'same' for making it the same to Major
% COMBINE_PARAMETERS.TR                 = [1.5];
%     HRF(1).Type                       = 'random';
% COMBINE_PARAMETERS.HRF                = HRF;
% TODO: implement a more complex noise addition system. 
% Right now only the parameter for white noise can be edited. 
% COMBINE_PARAMETERS.Noise.noise2signal = [0:0.05:0.45];
% synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS, 'mult',100);
% synthDT = pmForwardModelCalculate(synthDT);
% Save it
% randomSynthDTfName = ['synthDT_RANDOM_HRF_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',randomSynthDTfName), 'synthDT');
% 
% 
% 
% 
% RUN
% 
% AnalyzePRF
% results    = pmModelFit(synthDT, 'aprf', 'useParallel', true);
% aprfresultfName = ['result_rnd_aprf_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',aprfresultfName), 'results');
% popeye
% results    = pmModelFit(synthDT, 'popeye_onegaussian');
% popresultfName = ['result_rnd_pop_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',popresultfName), 'results');
% mrvista
% results    = pmModelFit(synthDT, 'mrvista','model','one gaussian', ...
%                                         'grid', false, ... % if true, returns gFit
%                                         'wSearch', 'coarse to fine');
% vistaresultfName = ['results_rnd_vista_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',vistaresultfName), 'results');
% Afni
% results    = pmModelFit(synthDT, 'afni_4');
% afniresultfName = ['results_rnd_afni_oneCenter_' datestr(datetime,'yyyymmddTHHMMSS','local') '.mat'];
% save(fullfile(pmRootPath,'local',afniresultfName), 'results');
% 
% 
% 
% 
% 
% allFileNames = {
% fullfile(pmRootPath,'local','synthDT_RANDOM_HRF_oneCenter_20190826T100808.mat')
% fullfile(pmRootPath,'local','result_rnd_aprf_oneCenter_20190826T110119.mat')
% fullfile(pmRootPath,'local','results_rnd_vista_oneCenter_20190826T124614.mat')
% fullfile(pmRootPath,'local','results_rnd_afni_oneCenter_20190826T185712.mat')
% fullfile(pmRootPath,'local','result_rnd_pop_oneCenter_20190826T123508.mat')
% };
% 
% UPLOAD LOCAL FILES
% {
% st   = scitran('stanfordlabs'); st.verify;
% cc   = st.search('collection','collection label exact','PRF_StimDependence');
% 
% for nf=1:length(allFileNames)
%     localfname = allFileNames{nf};
%     stts = st.fileUpload(localfname, cc{1}.collection.id, 'collection');
%     Check that the data is there
%     [~,fname,ext] = fileparts(localfname);
%     data          = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%         [fname ext],localfname));
% end
% }
% 
% {
% Identify the results we want to use manually
% If the file exists locally, read it, otherwise download from the server locally
% data = {};
% for nf=1:length(allFileNames)
%     localfname = allFileNames{nf};
%     if exist(localfname,'file')
%         data{nf}          = load(localfname);
%     else
%         Read the data
%         [~,fname,ext] = fileparts(localfname);
%         data{nf}          = load(st.fw.downloadFileFromCollection(cc{1}.collection.id,...
%             [fname ext],localfname));
%     end
% end
% 
% 
% 
% Identify and read the results we want to use manually
%  TODO: Backup them in FW, run in the server and read them here
% rand_Synth      = load(fullfile(pmRootPath,'local','synthDT_RANDOM_HRF_oneCenter_20190826T100808.mat'));
% 
% rand_prfRes     = load(fullfile(pmRootPath,'local','result_rnd_aprf_oneCenter_20190826T110119.mat'));
% rand_vistaRes   = load(fullfile(pmRootPath,'local','results_rnd_vista_oneCenter_20190826T124614.mat'));
% rand_afni4Res   = load(fullfile(pmRootPath,'local','results_rnd_afni_oneCenter_20190826T185712.mat'));
% rand_popRes     = load(fullfile(pmRootPath,'local','result_rnd_pop_oneCenter_20190826T123508.mat'));
% 
% Plot the results
% paramDefaults                  = {'Centerx0','Centery0','Theta','sigmaMinor','sigmaMajor'};
% [rand_compTable, rand_tSeries] = pmResultsCompare(data{1}.synthDT, ... % Defines the input params
%                             {'aprf','vista','afni4','pop'}, ... % Analysis names we want to see: 'aPRF','vista',
%                             {data{2}.results, data{3}.results, data{4}.results, data{5}.results}, ... % results_analyzePRF,results_vista,
%                             'params', paramDefaults, ...
%                             'shorten names',true); 
% Plot some example voxels to see time series                        
% pmTseriesPlot(tSeries, rand_Synth.synthDT(:,'TR'), 'voxel',[1:9], 'newWin',true, ...
%                            'to compare', {'synth','aprf','vista','afni4','pop'});
% Plot the tool comparison plots for noise and rfSize ACCURACY AND PRECISION PLOT: by noise levels
% pmNoiseSizePlots(rand_compTable, {'aprf','vista','afni4','pop'},'randomHRF',true)
% 
% 
% CHECK the results, CLEAN, and PLOT again
% Well, the thing is that at least aPRF and popeye have several outliers that should be cleaned. 
% So, this is now a outlier cleaning tool, that will output:
%   - Cleaned result table. 
%   - A table with outlier counts, that will evaluate quality of analysis 
% [rand_newDT,rand_outlierReport] = pmResultsCleanOutliers(rand_compTable,'outlierLevel',20);
% 
% Plot again, cleaned dataset
% pmNoiseSizePlots(rand_newDT, {'aprf','vista','afni4','pop'},'randomHRF',true)
% 
% 
% % Difference between ideal and HRF
% meterlo en pmNoiseSizePlots, DT sera cell, if cell comparalos, si no hazlo uno a uno
%     comparacion 
% 
% pmNoiseSizePlots({newDT,rand_newDT}, {'aprf','vista','afni4','pop'})
% 
% % TODO
% (done) Investigate what happens to popeye and aPRF
%    --- Outliers!
% Run everything in black (or GCP)
%     (done) Docker is still failing after the reboot: reinstalled and rebooted
%     (done) Matlab with python crashes, segfault as Ariel said: hardcode the
%            popeye HRFs in Linux
%     ()     Actually run it
% (done) Plot the ideal and random hrf plots
% (ongoing) Plot difference between tools when using ideal HRF or random.
% () Kendrick:
%    () ask for HRF database?
%    () comment bad results big HRFs
% () Write manuscript
% () Noah: OSF and Dockers
% () Noise models: more tests
% () Location tests?
% () HRF: test with params? enough if we test with DDBB and randoms
% }
% 
% % OLD CODE
% {
% 
% 
% % ACCURACY AND PRECISION PLOT: by prfsize levels
% noiseVals    = unique(compTable.noise2sig); 
% rednoiseVals = noiseVals(2) : 0.1 : noiseVals(10);
% mrvNewGraphWin([useTool ' accuracy and precision']);
% 
% for np = 1:length(rednoiseVals)
%     subplot(length(rednoiseVals), 1, np);
%     noise      = rednoiseVals(np);
%     Reduce the table for only the RF size-s we want
%     DT         = compTable(compTable.noise2sig==noise,:);
%     Call the function for the distribution plot
%     subplot(length(prfsizes), 1, np);
%     [result,noiseVals,sds] = pmNoise2AccPrec(DT, 'both','plotIt',false);
%     errorbar(noiseVals,result, sds,'Color','b','LineStyle','-','LineWidth',2);hold on;
%     plot(noiseVals,result,'Color','b','LineStyle','-','LineWidth',2);hold on;
%     jbfill(noiseVals,result+sds,result-sds,'b','b',1,.5);hold on;
%     h1 = plot([noiseVals(1),noiseVals(end)],prfsize*[1,1],'Color','k','LineStyle','-.','LineWidth',2);
%     xlabel('Noise levels');
%     ylabel('Acc. & prec. (deg)');
%     title(['ACCURACY AND PRECISION (vs noise and RF size)']);
%     legend(num2str(prfsizes),'Location','northwest');
% end
% 
% 
% % DISTRIBUTION PLOTS
% prfsizes   = unique(compTable.synth.sMaj);
% mrvNewGraphWin([useTool ' comparisons']);
% 
% for np=1:length(prfsizes)
%     prfsize      = prfsizes(np);
%     Reduce the table for only the RF size-s we want
%     DT           = compTable(compTable.synth.sMaj==prfsize,:);
%     Select the variable to compare the distributions with
%     varToCompare = 'noise2sig';
%     Call the function for the distribution plot
%     subplot(length(prfsizes), 1, np);
%     pmAccPrecDistributions(DT, varToCompare,'normalksdensity','ksdensity');
%     Add text to the plots
%     xlabel('Prediction of RF size (deg)');
%     ylabel('Count');
%     title(['Encoded RF size:' num2str(prfsize) ' deg']);
%     xlim([-3,10])
%     xticks(-3:1:10)
%     xlim([-0.5,3])
%     xticks(-0.5:0.5:3)
% end
%  
% 
% 
% % ACCURACY AND PRECISION PLOTS
% prfsizes   = unique(compTable.synth.sMaj);
% mrvNewGraphWin([useTool ' accuracy and precision']);
% 
% Do precision
% subplot(1,2,1)
% for np=1:length(prfsizes)
%     prfsize      = prfsizes(np);
%     Reduce the table for only the RF size-s we want
%     DT           = compTable(compTable.synth.sMaj==prfsize,:);
%     Call the function for the distribution plot
%     subplot(length(prfsizes), 1, np);
%     [result,noiseVals] = pmNoise2AccPrec(DT, 'precision','plotIt',false);
%     plot(noiseVals,result);hold on;
% end
% xlabel('Noise levels'); 
% ylabel('SD of the results (deg)'); 
% title(['PRECISION for different noise and RF size']);
% legend(num2str(prfsizes),'Location','northwest');
% 
% Do accuracy
% subplot(1,2,2)
% for np=1:length(prfsizes)
%     prfsize      = prfsizes(np);
%     Reduce the table for only the RF size-s we want
%     DT           = compTable(compTable.synth.sMaj==prfsize,:);
%     Call the function for the distribution plot
%     subplot(length(prfsizes), 1, np);
%     [result,noiseVals] = pmNoise2AccPrec(DT, 'accuracy','plotIt',false);
%     plot(noiseVals,result);hold on;
% end
% xlabel('Noise levels'); 
% ylabel('Abs difference from the mean (deg)'); 
% title(['ACCURACY for different noise and RF size']);
% legend(num2str(prfsizes),'Location','northwest');
% 
% 
% 
% % TO DELETE
%     for ns=1:length(noise2sigs)
%         noise2sig = noise2sigs(ns);
%         
%         % Now we can create the subplots
%         
%         subplot(length(noise2sigs),length(prfsizes),plotIndex);
%         X = compTable.afni.sMin(compTable.noise2sig==noise2sig & compTable.synth.sMaj==prfsize);
%         Y = compTable.afni.sMaj(compTable.noise2sig==noise2sig & compTable.synth.sMaj==prfsize);
%         scatter(X,Y)
%         axis equal;
%         xlabel('sMin'); ylabel('sMaj')
%         title(sprintf('rfsize:%1.1f | noise2sig:%0.2f',prfsize,noise2sig))
%         grid on;
%         xlim([-0,8]); ylim([-0,8])
%         xticks([0:1:8]);yticks([0:1:8])
%         identityLine(gca);
%         % h1 = lsline;
%         % h1.Color = 'r';
%         hold on;
%         % [x0,y0] = fitEllipse(X,Y,'r');
%         x0  = median(X); y0 = median(Y);
%         sdx = std(X); sdy = std(Y);
%         plot([x0-sdx, x0+sdx],[y0 y0],'r');
%         plot([x0 x0],[y0-sdy, y0+sdy],'r');
%         text(2,0.5,sprintf('Median:[%1.2f(%1.2f),%1.2f(%1.2f)], ratio:%1.2f',x0,sdx,y0,sdy,y0/x0));
%     end
% end
% 
% }
% }