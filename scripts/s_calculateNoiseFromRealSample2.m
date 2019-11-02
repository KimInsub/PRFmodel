%% Calculate noise in a typical subject 
if (0)
    % The data comes from the processed reading_prf/heb_pilot09 subject
    % The data is now in /share/wandell/data but it will be in Flywheel too
    
    
    % N1 = niftiRead('Words_Hebrew1/TSeries/tSeriesScan1.nii.gz');
    % N2 = niftiRead('Words_Hebrew2/TSeries/tSeriesScan1.nii.gz');
    T1 = load('Words_Hebrew1/TSeries/Scan1/tSeries1.mat');
    T2 = load('Words_Hebrew2/TSeries/Scan1/tSeries1.mat');
    T3 = load('Words_English1/TSeries/Scan1/tSeries1.mat');
    
    Tsum  = (T1.tSeries+T2.tSeries+T3.tSeries) / 3;
    diff1 = T1.tSeries - Tsum;
    
    signalmeanmaxmin = [mean(mean(Tsum)), mean(max(Tsum)), mean(min(Tsum))];
    
    figure(99); plot(diff1(:,[300034,12332,234536]))
    diff1mean = mean(diff1,2);
    figure(999); plot(diff1mean)
    
    
    F1 = fft(diff1);
    
    figure(98);plot(abs(F1(2:end,[300034,12332,234536])))
    
    F1mean = mean(abs(F1(2:end,:)),2);
    
    figure(97);plot(F1mean)
    
    size(F1mean)
    
    % Save as data so that we can check noise levels elsewhere, we know where
    % this data is coming
    save(fullfile(pmRootPath,'data','noise','F1mean.mat'),'F1mean')
    save(fullfile(pmRootPath,'data','noise','diff1mean.mat'),'diff1mean')
    save(fullfile(pmRootPath,'data','noise','signalmeanmaxmin.mat'),'signalmeanmaxmin')
end

%% Generate synthetic data without noise
COMBINE_PARAMETERS               = [];
COMBINE_PARAMETERS.TR            = [1.5];
COMBINE_PARAMETERS.RF.Centerx0   = [-4,-3,-2,-1,0,1,2,3,4,5]; % [-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6];
COMBINE_PARAMETERS.RF.Centery0   = [-5,-4,-3,-2,-1,0,1,2,3,4];
COMBINE_PARAMETERS.RF.Theta      = [0]; %, deg2rad(45)];
COMBINE_PARAMETERS.RF.sigmaMajor = [1,4];
COMBINE_PARAMETERS.RF.sigmaMinor = 'same';
% HRF goes in groups, create 3
HRF(1).Type                      = 'canonical';
HRF(2).Type                      = 'popeye_twogammas';
HRF(3).Type                      = 'afni_spm';
COMBINE_PARAMETERS.HRF           = HRF;
% Noise goes in groups, create 1
Noise(1).white                   = false;
Noise(1).cardiac                 = false;
Noise(1).respiratory             = false;
Noise(1).lowfrequ                = false;
COMBINE_PARAMETERS.Noise         = Noise;
% CREATE AND CALCULATE
nonoise_synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS,'repeats',3);
nonoise_synthDT = pmForwardModelCalculate(nonoise_synthDT);
% Save it in local
save(fullfile(pmRootPath,'local','nonoise_Test1.mat'),'nonoise_synthDT')

%{
%% Generate synthetic data with normal noise, with slow drift
    noisemult = 1;

    COMBINE_PARAMETERS               = [];
    COMBINE_PARAMETERS.TR            = [1.5];
    COMBINE_PARAMETERS.RF.Centerx0   = [-4,-3,-2,-1,0,1,2,3,4,5]; 
    COMBINE_PARAMETERS.RF.Centery0   = [-5,-4,-3,-2,-1,0,1,2,3,4];
    COMBINE_PARAMETERS.RF.Theta      = [0]; %, deg2rad(45)];
    COMBINE_PARAMETERS.RF.sigmaMajor = [1,4];
    COMBINE_PARAMETERS.RF.sigmaMinor = 'same';
    % HRF goes in groups, create 3
    HRF(1).Type                    = 'canonical';
    HRF(2).Type                    = 'popeye_twogammas';
    HRF(3).Type                    = 'afni_spm';
    COMBINE_PARAMETERS.HRF         = HRF;
    % Noise goes in groups, create 1
    Noise(1).white                 = true;
    Noise(1).white_noise2signal    = 0.12 * noisemult;
    Noise(1).cardiac               = true;
    Noise(1).cardiac_frequency     = 1.17;
    Noise(1).cardiac_amplitude     = 0.014 * noisemult;
    Noise(1).respiratory           = true;
    Noise(1).respiratory_frequency = 0.23;
    Noise(1).respiratory_amplitude = 0.014 * noisemult;
    Noise(1).lowfrequ              = true;
    Noise(1).lowfrequ_frequ        = 120;
    Noise(1).lowfrequ_amplitude    = 0.23 * noisemult;
    COMBINE_PARAMETERS.Noise       = Noise;
    % CREATE AND CALCULATE
    synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS,'repeats',3);
    synthDT16 = pmForwardModelCalculate(synthDT);
    % Save it in local
    save(fullfile(pmRootPath,'local','noiseTest16.mat'),'synthDT16')
    
%}
    
%% Generate synthetic data with normal noise, with slow drift
    noisemult = 1;

    COMBINE_PARAMETERS               = [];
    COMBINE_PARAMETERS.TR            = [1.5];
    COMBINE_PARAMETERS.RF.Centerx0   = [-4,-3,-2,-1,0,1,2,3,4,5]; % [-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6];
    COMBINE_PARAMETERS.RF.Centery0   = [-5,-4,-3,-2,-1,0,1,2,3,4];
    COMBINE_PARAMETERS.RF.Theta      = [0]; %, deg2rad(45)];
    COMBINE_PARAMETERS.RF.sigmaMajor = [1,4];
    COMBINE_PARAMETERS.RF.sigmaMinor = 'same';
    % HRF goes in groups, create 3
    HRF(1).Type                    = 'canonical';
    HRF(2).Type                    = 'popeye_twogammas';
    HRF(3).Type                    = 'afni_spm';
    COMBINE_PARAMETERS.HRF         = HRF;
    % Noise goes in groups, create 1
    Noise(1).white                 = true;
    Noise(1).white_noise2signal    = 0.12 * noisemult;
    Noise(1).cardiac               = true;
    Noise(1).cardiac_frequency     = 1.17;
    Noise(1).cardiac_amplitude     = 0.014 * noisemult;
    Noise(1).respiratory           = true;
    Noise(1).respiratory_frequency = 0.23;
    Noise(1).respiratory_amplitude = 0.014 * noisemult;
    Noise(1).lowfrequ              = true;
    Noise(1).lowfrequ_frequ        = 120;
    Noise(1).lowfrequ_amplitude    = 0.23 * noisemult;
    COMBINE_PARAMETERS.Noise       = Noise;
    % CREATE AND CALCULATE
    synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS,'repeats',3);
    same_synthDT = pmForwardModelCalculate(synthDT);
    % Save it in local
    save(fullfile(pmRootPath,'local','same_noiseTest.mat'),'same_synthDT')    
      
%% Generate synthetic data with half the noise
    noisemult = 1/2;

    COMBINE_PARAMETERS               = [];
    COMBINE_PARAMETERS.TR            = [1.5];
    COMBINE_PARAMETERS.RF.Centerx0   = [-4,-3,-2,-1,0,1,2,3,4,5]; % [-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6];
    COMBINE_PARAMETERS.RF.Centery0   = [-5,-4,-3,-2,-1,0,1,2,3,4];
    COMBINE_PARAMETERS.RF.Theta      = [0]; %, deg2rad(45)];
    COMBINE_PARAMETERS.RF.sigmaMajor = [1,4];
    COMBINE_PARAMETERS.RF.sigmaMinor = 'same';
    % HRF goes in groups, create 3
    HRF(1).Type                    = 'canonical';
    HRF(2).Type                    = 'popeye_twogammas';
    HRF(3).Type                    = 'afni_spm';
    COMBINE_PARAMETERS.HRF         = HRF;
    % Noise goes in groups, create 1
    Noise(1).white                 = true;
    Noise(1).white_noise2signal    = 0.12 * noisemult;
    Noise(1).cardiac               = true;
    Noise(1).cardiac_frequency     = 1.17;
    Noise(1).cardiac_amplitude     = 0.014 * noisemult;
    Noise(1).respiratory           = true;
    Noise(1).respiratory_frequency = 0.23;
    Noise(1).respiratory_amplitude = 0.014 * noisemult;
    Noise(1).lowfrequ              = true;
    Noise(1).lowfrequ_frequ        = 120;
    Noise(1).lowfrequ_amplitude    = 0.23 * noisemult;
    COMBINE_PARAMETERS.Noise       = Noise;
    % CREATE AND CALCULATE
    synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS,'repeats',3);
    half_synthDT = pmForwardModelCalculate(synthDT);
    % Save it in local
    save(fullfile(pmRootPath,'local','half_noiseTest.mat'),'half_synthDT')
    
%% Generate synthetic data with double noise
    noisemult = 2;

    COMBINE_PARAMETERS               = [];
    COMBINE_PARAMETERS.TR            = [1.5];
    COMBINE_PARAMETERS.RF.Centerx0   = [-4,-3,-2,-1,0,1,2,3,4,5]; % [-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6];
    COMBINE_PARAMETERS.RF.Centery0   = [-5,-4,-3,-2,-1,0,1,2,3,4];
    COMBINE_PARAMETERS.RF.Theta      = [0]; %, deg2rad(45)];
    COMBINE_PARAMETERS.RF.sigmaMajor = [1,4];
    COMBINE_PARAMETERS.RF.sigmaMinor = 'same';
    % HRF goes in groups, create 3
    HRF(1).Type                    = 'canonical';
    HRF(2).Type                    = 'popeye_twogammas';
    HRF(3).Type                    = 'afni_spm';
    COMBINE_PARAMETERS.HRF         = HRF;
    % Noise goes in groups, create 1
    Noise(1).white                 = true;
    Noise(1).white_noise2signal    = 0.12 * noisemult;
    Noise(1).cardiac               = true;
    Noise(1).cardiac_frequency     = 1.17;
    Noise(1).cardiac_amplitude     = 0.014 * noisemult;
    Noise(1).respiratory           = true;
    Noise(1).respiratory_frequency = 0.23;
    Noise(1).respiratory_amplitude = 0.014 * noisemult;
    Noise(1).lowfrequ              = true;
    Noise(1).lowfrequ_frequ        = 120;
    Noise(1).lowfrequ_amplitude    = 0.23 * noisemult;
    COMBINE_PARAMETERS.Noise       = Noise;
    % CREATE AND CALCULATE
    synthDT = pmForwardModelTableCreate(COMBINE_PARAMETERS,'repeats',3);
    double_synthDT = pmForwardModelCalculate(synthDT);
    % Save it in local
    save(fullfile(pmRootPath,'local','double_noiseTest.mat'),'double_synthDT')
       
    %% Compare synthetic to the real data
    % Load real
    % load(fullfile(pmRootPath,'data','noise','F1mean.mat'),'F1mean')
    % load(fullfile(pmRootPath,'data','noise','diff1mean.mat'),'diff1mean')
    % load(fullfile(pmRootPath,'data','noise','signalmeanmaxmin.mat'),'signalmeanmaxmin')
    % 
    % % Load synthetic
    % % Noise free
    % load(fullfile(pmRootPath,'local','nonoise_Test1.mat'))
    % % With noise
    % load(fullfile(pmRootPath,'local','noiseTest4.mat'))

    % Generate matrices
    % Noise free
    PMnf       = nonoise_synthDT.pm;
    nfdata     = repmat(nan([1,PMnf(1).timePointsN]), [length(PMnf),1]);
    for ii=1:length(PMnf); nfdata(ii,:)=PMnf(ii).BOLDnoise;end
    
    % With noise: same
    PMs        = same_synthDT.pm;
    sdata      = repmat(nan([1,PMs(1).timePointsN]), [length(PMs),1]);
    for ii=1:length(PMs); sdata(ii,:)=PMs(ii).BOLDnoise;end
    % Generate same values
    diff_s = sdata - nfdata;  
    Fs     = fft(diff_s');
    same_Fsmean = mean(abs(Fs(5:end-3,:)),2);

     % With noise: half
    PMs        = half_synthDT.pm;
    sdata      = repmat(nan([1,PMs(1).timePointsN]), [length(PMs),1]);
    for ii=1:length(PMs); sdata(ii,:)=PMs(ii).BOLDnoise;end
    % Generate same values
    diff_s = sdata - nfdata;  
    Fs     = fft(diff_s');
    half_Fsmean = mean(abs(Fs(5:end-3,:)),2);
    
     % With noise: double
    PMs        = double_synthDT.pm;
    sdata      = repmat(nan([1,PMs(1).timePointsN]), [length(PMs),1]);
    for ii=1:length(PMs); sdata(ii,:)=PMs(ii).BOLDnoise;end
    % Generate same values
    diff_s = sdata - nfdata;  
    Fs     = fft(diff_s');
    double_Fsmean = mean(abs(Fs(5:end-3,:)),2);   
    
    % Plot it
    mrvNewGraphWin('F1mean');plot(F1mean);hold on;
                             plot(same_Fsmean);
                             plot(half_Fsmean);
                             plot(double_Fsmean);
    legend({'human','synth','synth/2','synth*2'})
    title('Real noise spectrum vs synthetic noise')