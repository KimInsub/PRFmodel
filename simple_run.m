clear
%% input
jsonname= 'normal_mid_noise.json';
sw = 'vista';
output_dir='/localhome/insubkim/Documents/experiments/testPRF/';

%% file & folder naming
makefolder= strsplit(jsonname,'.'); makefolder = makefolder{1};
session= strsplit(jsonname,'_'); session = session{1};

fig_save_dir = '/localhome/insubkim/Documents/experiments/testPRF/figures/';
result_dir = [output_dir 'results/'];
bold_file = [output_dir makefolder '/' session '.nii.gz'] ;
stim_file = [output_dir makefolder '/' session '_Stim.nii.gz'];
json_file = [output_dir makefolder '/' session '.json'];



%% Generation

if ~isfile(bold_file)    
    json= [output_dir jsonname];
    DTcalc = synthBOLDgenerator(json, output_dir);
end

%%
bold_file = [output_dir makefolder '/' session '.nii.gz'] ;
stim_file = [output_dir makefolder '/' session '_Stim.nii.gz'];
json_file = [output_dir makefolder '/' session '.json'];

% [pmEstimates, results] = pmModelFit({bold_file, json_file, stim_file}, sw);


%% Manual MrVista
homedir = [output_dir makefolder];
stimfile = [session '_Stim.nii.gz'];
datafile = [session '.nii.gz'];
model = 'one gaussian';
model = 'css';
model = 'cst';

% cst note
wSearch = 'coarse to fine';
stimradius = 10;
detrend = 1;
numberStimulusGridPoints = 50;
coarseDecimate = 0;

results = pmVistasoft(homedir, stimfile, datafile, stimradius,...
    'model'  , model, ...
    'grid'   , false, ...
    'wSearch', wSearch, ...
    'detrend', detrend, ...
    'keepAllPoints', false, ...
    'numberStimulusGridPoints', numberStimulusGridPoints)


 %% Prepare the outputs in a table format
 results =load('tmpResults-sFit-sFit-sFit.mat');
 
 niftiBOLDfile  = fullfile(tmpName, 'tmp.nii.gz')
 stimNiftiFname = fullfile(tmpName, 'tmpstim.nii.gz');
 
 copyfile(BOLDname,niftiBOLDfile)
 copyfile(STIMname,stimNiftiFname)
 
 
        pmEstimates = table();
        pmEstimates.Centerx0   = results.model{1}.x0';
        pmEstimates.Centery0   = results.model{1}.y0';
        pmEstimates.Theta      = results.model{1}.sigma.theta';
        pmEstimates.sigmaMajor = results.model{1}.sigma.major';
        pmEstimates.sigmaMinor = results.model{1}.sigma.minor';
        % Add the time series as well
        if niftiInputs
            data                   = niftiRead(BOLDname);
            pmEstimates.testdata   = squeeze(data.data);
        else
            pmEstimates.testdata   = repmat(ones([1,pm1.timePointsN]), ...
                [height(pmEstimates),1]);
            PMs                    = input.pm;
            for ii=1:height(pmEstimates); pmEstimates{ii,'testdata'}=PMs(ii).BOLDnoise;end
        end
                
                
        % Obtain the modelfit,
        pmEstimates = pmVistaObtainPrediction(pmEstimates, results);
        
        pmEstimates.R2         = calccod(pmEstimates.testdata,  pmEstimates.modelpred,2);
        pmEstimates.rss        = results.model{1}.rss';
        pmEstimates.RMSE       = sqrt(mean((pmEstimates.testdata - pmEstimates.modelpred).^2,2));


%%
% [pmEstimates, results] = pmModelFit({bold_file, json_file, stim_file}, sw);
% 
% cd  '/localhome/insubkim/Documents/experiments/testPRF'

%% extra


% 
% x=DTcalc.RF.Centerx0;
% y=DTcalc.RF.Centery0;
% sig = DTcalc.RF.sigmaMajor;
% cord = [x y];
% nv = length(DTcalc.TR);
% 
% 
% allR2=[];
% for voxel =1:nv
%     mdl = fitlm(pmEstimates.testdata(voxel,:),pmEstimates.modelpred(voxel,:));
%   allR2 =[allR2; mdl.Rsquared.Adjusted];
% end
% pmEstimates.R2 =allR2;
% 
% 
% pmEstimates.true_Centerx0 = DTcalc.RF.Centerx0;
% pmEstimates.true_Centery0 = DTcalc.RF.Centery0;
% pmEstimates.true_sigmaMajor = DTcalc.RF.sigmaMajor;
% 
% 
% 
% pmEstimates
% 
% save([result_dir makefolder '_' sw  '_simple_results.mat'], 'pmEstimates')
