classdef prfModel < matlab.mixin.SetGet & matlab.mixin.Copyable
    % Initialize a prf model object for the forward time series
    % calculation
    %
    % Syntax:
    %      pm = prfModel(varargin);
    %
    % Inputs:
    %
    % Outputs:
    %
    % Optional key/value pairs:
    %
    % Description
    %
    % See also
    %
    
    % Examples
    
    %{
       pm = prfModel;
       pm.plot;
    %}
    
    %{
        % Check how size is modeled
        pm = prfModel;
        pm.signalPercentage='frac'
        pm.BOLDcontrast  = 10;
        pm.RF.sigmaMajor = 1;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.Noise.seed    = 'random';
        pm.HRF.Type      = 'vista_twogammas';
        pm.Stimulus.durationSecs = 300;
    
        pm.TR = 1;
        pm.HRF.normalize = 'norm';
        pm.compute
        % pm.plot('what','componentfft','color','b','window',true); hold on
        sqrt(mean(pm.BOLD.^2))
    pm.plot('what','nonoise','color','b','window',true); hold on
        pm.HRF.normalize = 'sum';    
        pm.compute
        sqrt(mean(pm.BOLD.^2))
    pm.plot('what','nonoise','color','g','window',false,'line','--'); hold on
    
        pm.TR = 1.4;
        pm.HRF.normalize = 'norm';  
        pm.compute
        % pm.plot('what','componentfft','color','r','window',false); 
        sqrt(mean(pm.BOLD.^2))
    pm.plot('what','nonoise','color','r','window',false); 
        pm.TR = 1.4;
        pm.HRF.normalize = 'sum';
        pm.compute
        sqrt(mean(pm.BOLD.^2))
    pm.plot('what','nonoise','color','k','window',false,'line','--'); 
        legend({'norm, TR=1','sum, TR=1','norm, TR=1.4','sum, TR=1.4'})

    
    
        % PLOT HRF
        pm = prfModel;
        pm.TR = 1;
        pm.HRF.Type      = 'vista_twogammas';
    
        pm.HRF.normalize = 'norm';
        pm.compute
    pm.HRF.plot('window',true,'color' , 'b');hold on
        pm.HRF.normalize = 'sum';
        pm.compute
    pm.HRF.plot('window',false,'color' , 'g','line','--')
        
        pm.TR = 1.4;
        pm.HRF.normalize = 'norm';
        pm.compute
    pm.HRF.plot('window',false,'color' , 'r')
        pm.HRF.normalize = 'sum';
        pm.compute
    pm.HRF.plot('window',false,'color' , 'k','line','--')
    
    legend({'norm, TR=1','sum, TR=1','norm, TR=1.4','sum, TR=1.4'})
    
        % PLOT NOISE
        pm = prfModel;
        pm.TR = 1;
        pm.Noise.seed = 12345;
        pm.HRF.Type      = 'vista_twogammas';
    
        pm.HRF.normalize = 'norm';
        pm.compute
        sqrt(mean(pm.Noise.values.^2))
    pm.Noise.plot('window',true,'color' , 'b','windowfreq',false);hold on
        
        pm.HRF.normalize = 'sum';
        pm.compute
        sqrt(mean(pm.Noise.values.^2))
    pm.Noise.plot('window',false,'color' , 'g','line','--','windowfreq',false)
        
        pm.TR = 1.4;
        pm.HRF.normalize = 'norm';
        pm.compute
        sqrt(mean(pm.Noise.values.^2))
    pm.Noise.plot('window',false,'color' , 'r','windowfreq',false)
        pm.HRF.normalize = 'sum';
        pm.compute
        sqrt(mean(pm.Noise.values.^2))
    pm.Noise.plot('window',false,'color' , 'k','line','--','windowfreq',false)
    
    legend({'norm, TR=1','sum, TR=1','norm, TR=1.4','sum, TR=1.4'})
    
    
    
    
        pm.Stimulus.Shuffle = true;
        pm.Stimulus.shuffleSeed = 12345;
        pm.compute
        pm.plot('what','nonoise','color','r','window',true); hold on
        % pm.plot('what','componentfft','color','r','window',true); 
        pm.HRF.Type      = 'vista_twogammas';
        pm.compute
        pm.plot('what','nonoise','color','g','window',false); hold on
        % pm.plot('what','componentfft','color','r','window',false); 
        
        pm = prfModel;
        pm.signalPercentage='frac'
        pm.BOLDcontrast  = 10;
        pm.RF.sigmaMajor = 1;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.Noise.seed    = 'none';
        pm.HRF.Type      = 'boynton';
        pm.HRF.normalize = 'norm';
        pm.Stimulus.durationSecs = 300;
        pm.Stimulus.Shuffle = true;
        pm.Stimulus.shuffleSeed = 12345;
        pm.compute
        pm.plot('what','nonoise','color','r','window',true); hold on
        % pm.plot('what','componentfft','color','r','window',true); 
        pm.HRF.Type      = 'vista_twogammas';
        pm.compute
        pm.plot('what','nonoise','color','g','window',false); hold on
        % pm.plot('what','componentfft','color','r','window',false); 


pm.Stimulus.Shuffle = true;
        pm.compute
        pm.plot('what','componentfft','color','r','window',false); 
    
    
        pm = prfModel;
        pm.signalPercentage='frac'
        pm.RF.sigmaMajor = 2;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.HRF.Type = 'canonical';
        pm.compute
        pm.plot('what','nonoise','color','r','window',false)
    %}
    
    %{
        % Check how size is modeled
        pm = prfModel;
        pm.RF.sigmaMajor = 1;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.HRF.Type = 'canonical';
        pm.Stimulus.Shuffle = true;
        pm.Stimulus.shuffleSeed = '12345;
        pm.compute
        pm.SNR
        pm.plot('what','nonoise','color','b','window',true); hold on
        
        pm = prfModel;
        pm.RF.sigmaMajor = 2;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.HRF.Type = 'canonical';
        pm.Stimulus.Shuffle = true;
        pm.Stimulus.shuffleSeed = 12345;
        pm.compute
        pm.SNR
        pm.plot('what','nonoise','color','r','window',false)
    %}
    
    %{
        % Check how size is modeled
        pm = prfModel;
        pm.RF.sigmaMajor = 1;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.signalPercentage='bold';
        pm.HRF.Type = 'boynton';
        pm.HRF.normalize = 'sum';
        pm.Stimulus.Shuffle = false;
        pm.Stimulus.shuffleSeed = 12345;
        pm.Noise.seed = 12345;
        pm.compute
        pm.BOLDcontrast
        pm.SNR
        pm.plot('what','withnoise','color','b','window',true); hold on
        
        pm = prfModel;
        pm.RF.sigmaMajor = 1;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.signalPercentage='bold';
        pm.HRF.Type = 'boynton';
        pm.Stimulus.Shuffle = true;
        pm.Stimulus.shuffleSeed = 12345;
        pm.Noise.seed = 12345; 
        pm.compute
        pm.SNR
        pm.plot('what','withnoise','color','r','window',false)
    %}
    
    %{
        % Check how size is modeled
        pm = prfModel;
        pm.signalPercentage='spc';
        pm.BOLDcontrast = 10;
        pm.RF.sigmaMajor = .2;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.HRF.normalize = 'power'
        pm.HRF.compute
        
        pm.HRF.Type = 'canonical';
        pm.compute
        sum(pm.HRF.values .^2);
        sum(pm.BOLD .^2) 
        pm.plot('what','nonoise','color','b','window',true); hold on
        pm.HRF.Type = 'vista_twogammas';
        pm.compute
        sum(pm.HRF.values .^2);
        sum(pm.BOLD .^2)
        sqrt(mean(pm.BOLD .^2))
    
        pm.plot('what','nonoise','color','r','window',false); 

pm.Noise.seed=12345;
        pm.compute;
        pm.SNR
        pm.plot('what','withnoise','color','b','window',true); hold on
        
        pm = prfModel;
        pm.signalPercentage='bold'
        pm.RF.sigmaMajor = 2;
        pm.RF.sigmaMinor = pm.RF.sigmaMajor;
        pm.HRF.Type = 'canonical';
        pm.Noise.seed=12345;
        pm.compute
        pm.SNR
        pm.plot('what','withnoise','color','r','window',false)
    %}
    
    %{ 
       % Check mean BOLD, range, contrast
       pm = prfModel;
       pm.BOLDcontrast = 8;
       pm.signalPercentage='frac';
       pm.Noise.seed = 12345
       pm.Noise.setVoxelDefaults('low')
       pm.Noise.compute
       pm.HRF.Type = 'canonical'
       pm.compute;
       pm.plot;
       noiselessRange = (max(pm.BOLD)-min(pm.BOLD))/2;  % should be 0.16
       assert(pm.BOLDcontrast/100 == noiselessRange)
       pm.signalPercentage = bold; % Give real signal with a mean of BOLDmeanValue
       pm.compute;
       noiselessRange = (max(pm.BOLD)-min(pm.BOLD))/2;  % should be 0.16
       assert(pm.BOLDcontrast/100 == noiselessRange/pm.BOLDmeanValue)
       pm.plot
    %}
    %{ 
        % Test if the contrast scaling thing is working or not
        pm = prfModel;
        pm.Noise.seed = 'none';
        pm.BOLDcontrast  = 10;
        pm.RF.Centerx0   = 10;
        pm.RF.Centery0   = 10;
        pm.RF.sigmaMajor = 2;
        pm.RF.sigmaMinor = 2;
        pm.BOLDcontrast
        pm.plot
        pm.compute
        pm.BOLDcontrast
        pm.plot
        % If we add noise, we see how in the scaled case, there is no signal, just noise
        pm = prfModel;
        pm.Noise.seed = 12345;
        pm.BOLDcontrast  = 10;
        pm.RF.Centerx0   = 10;
        pm.RF.Centery0   = 10;
        pm.RF.sigmaMajor = 2;
        pm.RF.sigmaMinor = 2;
        pm.BOLDcontrast
        pm.plot
        pm.compute
        pm.BOLDcontrast
        pm.plot
    
        close all;
    %}
    properties (Access = private)
        % What do we need to create our synthetic bold series
        % The main model will have other subclasses with the required
        % components. Analogy: the main pm model is a car, and the subclasses are
        % components of the car (wheel, for example).
        % The color of the wheel is not independent of the color of the car, so
        % the pm model itself will be a property of the subclass as well.
        uniqueTR;          % This is part of the main model. It will be set in all subclasses
    
    end
    
    properties (GetAccess=public, SetAccess=public) % Changed from SetAccess=private, check
        Type             ; % Basic, CSS ... (char)
        cssexp           ;
        % Components required to build the synthetic bold signal (class)
        Stimulus         ;
        RF               ;
        HRF              ;
        Noise            ;
        Temporal         ; %[st]

        
        % Other required options (double, char, logical)
        signalPercentage ; % Provide results in BOLD signal (bold), in signal percent change (spc) or unitless (none) (default bold)
        BOLDmeanValue    ; % Required mean value of the synthetic BOLD signal (default 10000)
        BOLDcontrast     ; % Contrast of the synthetic BOLD signal, in % (default 8%)
        timeSeries       ; % No scaling
        computeSubclasses; % Logical
        BOLDconv         ; % Raw BOLD signal, before scaling
        BOLD             ; % BOLD signal value, scaled (before noise)
        BOLDnoise        ; % Final value, composed of the BOLD + noise
        SNR              ; % in DB, knowing the signal and the noise
    end
    properties (Dependent)
        TR               ; % This one is derived and copied to all other classes
        timePointsN      ; % Defined by the stimulus.
        timePointsSeries ; 
        frequencySeriesHz; 
        defaultsTable    ;
    end
    
    methods (Static)
        function d = defaultsGet
            % This provides the defaults of this class, which is the only one at the top level. 
            d.TR                = 1;
            d.Type              = 'linear'; 
%             d.Type              = 'st'; 

            d.cssexp            = 0.05;
            d.signalPercentage  = 'bold';
            d.BOLDcontrast      = 5;    % Percent. Best case scenario (full stim and RF), will be scaled always lower
            d.BOLDmeanValue     = 10000; % Mean BOLD, needs signalPercentage='bold'
            d.computeSubclasses = true;  % Used to save computation time in pmForwardTableCalculate
            % Convert to table and return
            d = struct2table(d,'AsArray',true);
        end
    end
    methods
        % Constructor
        function pm = prfModel(varargin)
            % Obtain defaults table. If a parameters is not passed, it will use
            % the default one defined in the static function
            d = pm.defaultsGet;
            % Make varargin lower case, remove white spaces...
            varargin = mrvParamFormat(varargin);
            % Parse the inputs/assign default values
            p = inputParser;
            p.addParameter('tr'               , d.TR                  , @isnumeric);
            p.addParameter('type'             , d.Type{:}             , @ischar);
            p.addParameter('cssexp'           , d.cssexp              , @isnumeric);
            p.addParameter('signalpercentage' , d.signalPercentage{:} , @islogical);
            p.addParameter('boldmeanvalue'    , d.BOLDmeanValue       , @isnumeric);
            p.addParameter('boldcontrast'     , d.BOLDcontrast        , @isnumeric);
            p.addParameter('computesubclasses', d.computeSubclasses   , @islogical);
            
            p.parse(varargin{:});
            % Assign defaults/parameters to class/variables
            pm.TR                = p.Results.tr;
            pm.Type              = p.Results.type;
            pm.cssexp            = p.Results.cssexp;
            pm.signalPercentage  = p.Results.signalpercentage;
            pm.BOLDmeanValue     = p.Results.boldmeanvalue;
            pm.BOLDcontrast      = p.Results.boldcontrast;  % In percentage
            pm.computeSubclasses = p.Results.computesubclasses;

            % Create the classes, and initialize a prfModel inside it
            pm.Stimulus          = pmStimulus(pm);
            pm.HRF               = pmHRF(pm); 
            pm.RF                = pmRF(pm);
            pm.Noise             = pmNoise(pm);
            pm.Temporal          = pmTemporal(pm);

        end
        % Functions that apply the setting of main parameters to subclasses
        function set.TR(pm, tr)
            pm.uniqueTR      = tr;
        end
        
        
        
        function v = get.TR(pm)
            v = pm.uniqueTR;
        end
        % timePointsN and timePointsSeries: Stimulus is the source for the
        % number of timePoints that will be used in the rest of places.
        % NOTE: in a real experiment I think that the number of dicoms should
        % lead this, because then we calculate the stimuli that was shown in
        % every dicom.
        %
        % When creating this synthetic data, we are creating the forward model,
        % where starting with the stimulus we calculate the synthetic BOLD.
        function v = get.timePointsN(pm)
            v = pm.Stimulus.timePointsN;
        end
        function v = get.timePointsSeries(pm)
            v  = pm.Stimulus.timePointsSeries;
        end
        function v = get.frequencySeriesHz(pm)
            v  = (1/pm.TR)*(0:(pm.timePointsN-1))/pm.timePointsN;
        end
        function v = get.SNR(pm)
            pm.compute
            switch pm.signalPercentage
                case 'bold'
                    s  = (pm.BOLD - pm.BOLDmeanValue) / pm.BOLDmeanValue;
                    sn = (pm.BOLDnoise - pm.BOLDmeanValue) / pm.BOLDmeanValue;
                otherwise
                    s  = pm.BOLD;
                    sn = pm.BOLDnoise;
            end
            v  = snr(s, (sn - s));
        end
        function defaultsTable = get.defaultsTable(pm)
            % This function obtains all the defaults from all the
            % subclasses, so that we can construct a parameter table
            defaultsTable           = pm.defaultsGet;
            defaultsTable.HRF       = pm.HRF.defaultsGet;
            defaultsTable.RF        = pm.RF.defaultsGet;
            defaultsTable.Stimulus  = pm.Stimulus.defaultsGet;
            defaultsTable.Noise     = pm.Noise.defaultsGet;
            defaultsTable.Temporal  = pm.Temporal.defaultsGet;

        end
        % Compute synthetic BOLD without noise
        function computeBOLD(pm,varargin)
            % For this linear model we take the inner product of the
            % receptive field with the stimulus contrast. Then we
            % convolve that value with the HRF.
            varargin = mrvParamFormat(varargin);
            p = inputParser;
            p.addRequired('pm',@(x)(isa(x,'prfModel')));
            p.addParameter('randomseed',1000,@(x)(round(x) == x && x > 0));
            p.addParameter('showconv',false,@islogical);
            p.parse(pm,varargin{:});
            showconv = p.Results.showconv;
            
            % First, compute the values in the required sub-classes
            if pm.computeSubclasses
                pm.Stimulus.compute;
                pm.RF.compute;
                pm.HRF.compute;
                pm.Temporal.compute; %[cst]

            end            
            % Load stimulus
            stimValues = pm.Stimulus.getStimValues;
            
            
            % Initialize timeSeries, it is the signal prior to convolution
            [r,c,t]    = size(stimValues);
            spaceStim  = reshape(stimValues,r*c,t);
        
           

            
            % Calculate time series
            pm.timeSeries = spaceStim' * pm.RF.values(:);
            switch pm.Type
                case 'linear'
                    % Do nothing
                case {'CSS','css'}
                    % Exponentiate values
                    pm.timeSeries = pm.timeSeries .^ 0.05;
                    %{
                    % error('Untested, use only linear')
                    % Import function from analyzePRF and use it to generate the predicted BOLD signal.
                    %                     aprff = ...
                    %                         @(pp,dd) ...  % Defines the inputs to the function, params (to be guessed) and data
                    %                         conv2run(...  % Defines the main function, a convolution. We will want to guess the params
                    %                         posrect(pp(4)) * ...  % FIRST part of the convolution. It has form A * B. This is A
                    %                         (...                  % B starts here. Separate it as well
                    %                         dd * ...               % Data matrix
                    %                         [vflatten( ...         % Vector. vflatten just returns a vertical vector. Same as kk(:).
                    %                         placematrix( ...    % Substitutes matrix 2 into matrix 1 depending on matrix 3
                    %                         zeros(res), ...    % Matrix 1
                    %                         makegaussian2d(resmx,pp(1),pp(2),abs(pp(3)),abs(pp(3)),xx,yy,0,0) / ... % Matrix 2: element1
                    %                         (2*pi*abs(pp(3))^2) ...                                                 % Matrix 2: element2
                    %                         ) ...   % Close placematrix
                    %                         )...          % Close vflatten
                    %                         ;0]...               % Adds a 0 to the flattened matrix (vector) at the end
                    %                         ).^posrect(pp(5)),...% End of B part B of A*B part of the convolution. This is the parameter in the exponential
                    %                         options.hrf,...      % SECOND part of the convolution, the HRF signal
                    %                         dd(:,prod(res)+1) ...% THIRD part of the conv, according knk. Separates convs between runs. This third part is basically a categorization. See help conv2run
                    %                         );
                    % Remove most of his additionnal functions to make it simpler
                    % Obtain all the parameters required to run it.
                    % pp are the params and dd is the stimulus
                    % When we created signal with RF of
                    %       x0=0,y0=0,theta=0,sigmaMinor=1,sigmaMajor=1
                    % the parameters returned with a R2=57 where:
                    %       50.538, 50.278, 0.12756, 412.16, 0.015133
                    
                    pp(1) = 50;  % number of row location in a grid
                    pp(2) = 50;  % number of col location in a grid
                    pp(3) = 1; % Sigma minor and sigma mayor. only circles for now
                    pp(4) = 400;
                    pp(5) = 0.15;
                    res   = 100;
                    [xx,yy] = calcunitcoordinates(res);
                    RF = makegaussian2d(res,pp(1),pp(2),abs(pp(3)),abs(pp(3)),xx,yy,0,0) / (2*pi*pp(3)^2);
                    dd = spaceStim;
                    timeSeries = pp(4) * (dd' * RF(:)).^posrect(pp(5));
                    
                    pm.BOLD = conv2(timeSeries, getcanonicalhrf(pm.TR,pm.TR), 'same')'; % This is the same now
                    %}
%                     
%                   pm.RF.Type= 'tt';
%                   pm.RF.sigmaMajor=5;
%                   pm.RF.sigmaMinor=5;
%                   pm.RF.compute
% % 

% figure(1)
% subplot(1,3,1)
% x=linspace(-101, 101,101);
% y=x;
% [X,Y]=meshgrid(x,y);
% z = pm.RF.values;
% surf(X,Y,z);
% title(['my css'])
% shading interp
% axis tight
% 
% subplot(1,3,2)
% load('normal_rf.mat')
% x=linspace(-101, 101,101);
% y=x;
% [X,Y]=meshgrid(x,y);
% surf(X,Y,b);
% title(['nocss'])
% shading interp
% axis tight
%
% subplot(1,3,3)
% surf(X,Y,b-z);
% title(['nocss - css'])
% shading interp
% axis tight
%
% d=b-z;

%                   a= pm.RF.values;
%                   b=a
%
%   load('css_rf.mat')

                case {'st'}
                   % Do nothing = > moved to pmTemporal- compute

                    
%                     % create IRF
%                     irf_file = [pm.Temporal.IRFpath pm.Temporal.Name '_irf.mat'];
%                     
%                     if isfile(irf_file)
%                         disp('*st irf exists no need to make a new one!*')
%                         pm.Temporal.chan_preds      = [1,2,3];
% 
% %                         load(irf_file);
%                     else
%                         tmodel = st_createIRF(pm);
% 
%                     end
%                     
%                     % convolve rf with stimulus for each t-channel
%                     for cc=1:tmodel.num_channels
%                         pred = tmodel.chan_preds{cc}*(pm.RF.values(:));
%                         
%                         % apply css
%                         %                       pred = bsxfun(@power, pred, 0.05);
%                         pred = double(pred);
%                         
%                         % apply hrf
%                         pred_cell = num2cell(pred,1)';
%                         npixel_max = size(1,2);
%                         
%                         % use mrvista HRF
%                         %   params.stim(n).images = filter(params.analysis.Hrf{n}, 1, params.stim(n).images'); % images: pixels by time (so images': time x pixels)
%                         %                 hrf = params.analysis.Hrf;
%                         
% %                         hrf = {pm.HRF.values'};
%                         hrf = tmodel.irfs.hrf;
%                         
%                         %                         vistaHRF = conv(pred_cell{1}, pm.HRF.values);
%                         %                         vistaHRF = conv(pred_cell{1}', tmodel.irfs.hrf{1});
%                         % hrf = tmodel.irfs.hrf;
%                         curhrf = repmat(hrf, npixel_max, 1);
%                         pred_hrf = cellfun(@(X, Y) convolve_vecs(X, Y, tmodel.fs, 1 / tmodel.tr), ...
%                             pred_cell, curhrf, 'uni', false);
%                         pred_hrf = cellfun(@transpose,pred_hrf,'UniformOutput',false);
%                         pred_hrf=cell2mat(pred_hrf)';
%                         %
%                         if cc ==2
%                             pred_hrf = pred_hrf*tmodel.normT;
%                         end
%                         
%                         % store
%                         tmodel.run_preds(:,cc) = pred_hrf;
%                         %             prediction{n} = pred_hrf;
%                         %
%                     end
%                     
%                     % save Variables
% %                     pm.Temporal.chan_preds      = tmodel.chan_preds;
% %                     pm.Temporal.run_preds       = tmodel.run_preds;
%                        
%                        
                       
                otherwise
                    error('Model %s not implemented, select linear or CSS', pm.Type)
            end
            convValues    = conv(pm.timeSeries',pm.HRF.values);
            % Create the bold signal with the correct size
            % TODO: make all vectors columns whenever possible. Time vertical
            % The conv is longer (HRF size -1), we need to cut the end
                % of the conv, or paste the results in a correct sized vect
                pm.BOLDconv = zeros(size(pm.timeSeries))';
                pm.BOLDconv = convValues(1:length(pm.BOLDconv));
                if showconv
                    pm.showConvolution
                    hold on
                end
                
                
                
%                 figure()
% 
%                 pm.timeSeries = spaceStim' * pm.RF.values(:);
%                 convValues    = conv(pm.timeSeries',pm.HRF.values);
%                 subplot(4,1,1)
%                 plot(convValues);
%                 title(["mrVista- linear"])
% 
%                 
%                 pm.timeSeries = spaceStim' * pm.RF.values(:);
%                 pm.timeSeries = pm.timeSeries .^ 0.05;
%                 convValues    = conv(pm.timeSeries',pm.HRF.values);
%                 aa = zscore(convValues)
%                 subplot(4,1,2)
%                 plot(convValues);
%                 title(["mrVista- css after"])
%                 
%                 newRF = pm.RF.values(:) .^ 0.05;
%                 pm.timeSeries = spaceStim' * newRF;
%                 convValues    = conv(pm.timeSeries',pm.HRF.values);
%                 ab = zscore(convValues);
% 
%                 subplot(4,1,3)
%                 plot(convValues); hold on
%                 title(["mrVista- css before"])
%                 
%                 subplot(3,1,3)
%                 newRF = pm.RF.values(:) .^ 0.05;
%                 pm.timeSeries = spaceStim' * newRF;
%                 convValues    = conv(pm.timeSeries',pm.HRF.values);
%                 ab = zscore(convValues);
% 
%                 subplot(4,1,4)
%                 newStim = spaceStim'.^ 0.05;
%                 pm.timeSeries = newStim * pm.RF.values(:);
%                 convValues    = conv(pm.timeSeries',pm.HRF.values);
%                 plot(convValues); hold on
%                 title(["mrVista- css before"])


                
            % Scale the signal so that it has the required mean and contrast
            
            % Convert the output requested in pm.signalPercentage 
            % The BOLD signal has meaning: an Stimuli of all 1-s, an RF that
            % sums 1 (all RFs have been normalized to sum 1, if they fit in the
            % fov), and the HRF sums 1, will give a time series of 1, and if
            % maintained in time, it will generate a BOLD of 1 (with a peak and an
            % overshoot, see stimtest.m for an illustration). 
            
            % At this moment of the code, pm.BOLD is the fractional signal, we
            % need to multiply it by 100 to convert it to spc.
            
            % The formula will be the following then:
            % 
            %    boldAndNoise = MeanBold * (1 + contrast/100 * pm.BOLD + Noise);
            % 
            % Noise will be added in a later stage, here we want to provide the
            % pre-noise signal correctly scaled. 
          
            switch pm.signalPercentage
                case {'frac', 'fractional'}
                    pm.BOLD = 2 * pm.BOLDcontrast/100 * pm.BOLDconv;
                case {'spc'}
                    pm.BOLD = 2 * pm.BOLDcontrast * pm.BOLDconv;

%                     CST under construction
%                     [CST]: need to figure out amplitude
                    if strcmp(pm.Type,'st')
                        if contains(pm.Temporal.temporalModel,'2ch')
                            c1 = 2 * pm.BOLDcontrast * pm.Temporal.run_preds(:,1);
                            c2 = 2 * pm.BOLDcontrast * pm.Temporal.run_preds(:,2);
                            pm.Temporal.spc = [c1 c2  c1+c2]; % store channel prediction results
                        else
                            pm.Temporal.spc = 3 * pm.BOLDcontrast * pm.Temporal.run_preds(:,1);
                        end
                    end
%                     
%                     
                    





%                         pm.cst{1} = c1;
%                         pm.cst{2} = c2;
%                         pm.cst{3} = pm.BOLD;
% 
                            
                    % [cst] plot
%                         figure()
%                         subplot(1,2,1)
%                         plot(prediction(:,1),'LineWidth',2); hold on
%                         plot(prediction(:,2),'LineWidth',2,'color','red'); hold on
%                         plot(sum(prediction,2),'LineWidth',2,'color','k'); hold on
%                         legend('sus','tran','sum')
%                         title(['2-ch synth'])
%                         
%                         subplot(1,2,2)
%                         plot(c1,'LineWidth',2); hold on
%                         plot(c2,'LineWidth',2,'color','red'); hold on
%                         plot(cstBOLD,'LineWidth',2,'color','k'); hold on
%                         title(['artificial amplitidue given 2-ch synth'])
%                         
%                         %check the effect of exponent for mrVisa
%                         figure()
%                         pm.timeSeries = spaceStim' * pm.RF.values(:);
%                         pm.timeSeries = pm.timeSeries .^ 0.05;
%                         cssmodel    = conv(pm.timeSeries',pm.HRF.values);
%                         
%                         pm.timeSeries = spaceStim' * pm.RF.values(:);
%                         linearmodel    = conv(pm.timeSeries',pm.HRF.values);
%                         
%                         plot(cssmodel); hold on
%                         plot(linearmodel); hold on
%                         legend('css','linear')
%                         title(['exponent effect hrf'])


                    
%                     
                    
                    
                case {'frac', 'fractional'}
                    pm.BOLD = 2 * pm.BOLDcontrast/100 * pm.BOLDconv;
                case {'bold'}
                    pm.BOLD = pm.BOLDmeanValue * (1 + 2 * pm.BOLDcontrast/100 * pm.BOLDconv);




                    
                    
                otherwise
                    error('%s provided, valid values are frac, spc, and bold (default)', pm.signalPercentage)
            end
        end
        function showConvolution(pm)
            a_fig = mrvNewGraphWin('show convolution')
            % %%%%%%%%%%%%%%%%%%%%% Function: acnv.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            %  Title: Animation of Graphical Convolution
            %
            %  To run this script just type 'acnv' on the MatLab prompt: > acnv
            %
            %  Description:
            %   1. This is a simple MatLab demo to animate the process of convolution.
            %      It is meant to help student to visualize how convolution works.
            %
            %   2. When this script is run, two function f(t) and go(t) are convolved
            %      and the output figure will show animated graphical convolution.
            %
            %   3. The functions "f" and "go" and their range of interval can be changed
            %      by editing this script at line numbers around "48 to 64"
            %
            %   4. Note:  For a better scaled plots of the functions f(t) and go(t1),
            %             it is recommended to set the functions such that their
            %             maximum value remains comparable. e.g one can use appropriate
            %             scaling. Other functions are also given 'commented out'
            %
            %             Interger values are recommended for the intervals
            %
            %   5. The animation can be made faster or slower by changing the value of
            %      the pause function in the animation loop. (around line number 134)
            %
            %  Author:
            %      Laine Berhane Kahsay
            %      Uni-Ulm, Germany
            %
            %   email: kahsay_2004@yahoo.com
            %
            %     ver: 1.0, written in Matlab 6.5/7.0
            %
            %  To see this help - type on the Matlab Prompt: > help acnv
            %
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            % help acnv;
            % color of axis constant
            axis_color= [0.5 0.5 0.5];
            % sampling interval constant
            s_int = pm.TR;
            % interval for function 'f(t)'
            % t = [ -10:s_int:10 ];
            t = pm.timePointsSeries;
            % definition of function 'f(t)'
            % f = 0.1*(t.^2);
            f = pm.timeSeries';
            % HRFcontrast = (max(pm.HRF.values)-min(pm.HRF.values))/2;
            % f = 100 * pm.unitless2contrast(f,HRFcontrast,true);
            if f(1) >= 0, f = f - f(1);end
            if f(1) <= 0, f = f + abs(f(1));end
            %  f = 5*ones(1, length(t));
            %  f = t;
            % interval for function 'go(t1)'
            % t1 = [-7:s_int:7];
            t1 = pm.HRF.tSteps;
            
            
            % definition of function 'go(t1)'
            % go = -0.1*(t1.^2);
            go = pm.HRF.values;
            
            % go = .1*(t1.^3);
            % go = 5*cos(2*pi*t1);
            % go = 5*ones(1, length(t1));
            % go = zeros(1, length(t1));go(1)=5;
            % convolve: note the multiplation by the sampling interval
            c = s_int * conv(f, go);
            % Animation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % flip 'go(t1)' for the graphical convolutions g = go(-t1)
            g = fliplr(go);
            tf = fliplr(-t1);
            % slide range of 'g' to discard non-ovelapping areas with 'f' in the convolution
            tf = tf + ( min(t)-max(tf) );
            % get the range of function 'c' which is the convolution of 'f(t)' and 'go(t1)'
            tc = [ tf t(2:end)];
            tc = tc+max(t1);
            % start graphical output with three subplots
            % a_fig = figure;
            set(a_fig, 'Name', 'Animated Convolution', 'unit', 'pixel', ...
                'Position', [300, 150, 600, 750]);
            % plot f(t) and go(t1)
            ax_1 = subplot(3,1,1);
            op = plot(t,f, 'b',  t1, go, 'r');
            if isempty(pm.BOLDconv); pm.computeBOLD; end
            hold on; grid on;
            set(ax_1, 'XColor', axis_color, 'YColor', axis_color, 'Color', 'w', 'Fontsize', 9);
            xlim( [ ( min(t)-abs(max(tf)-min(tf)) - 1 ) ( max(t)+abs(max(tf)-min(tf)) + 1 ) ] );
            title('Graph of f(t) and go(t)', 'Color', axis_color );
            legend({'f(t)' 'go(t)'});
            % initialize animation the plot of 'g' is slided over the plot of 'f'
            % plot f in the subplot number 2
            ax_2 = subplot(3,1,2);
            p = plot(t, f);
            hold on; grid on;
            title('Graphical Convolution: f(t) and g = go(-t1)', 'Color', axis_color );
            
            % plot g in the subplot number 2
            q = plot(tf, g, 'r');
            xlim( [ ( min(t)-abs(max(tf)-min(tf))-1 ) ( max(t)+abs(max(tf)-min(tf))+1 ) ] );
            u_ym = get(ax_2, 'ylim');
            % plot two vertical lines to show the range of ovelapped area
            s_l = line( [min(t) min(t)], [u_ym(1) u_ym(2)], 'color', 'g'  );
            e_l = line( [min(t) min(t)], [u_ym(1) u_ym(2)], 'color', 'g'  );
            hold on; grid on;
            set(ax_2, 'XColor', axis_color, 'YColor', axis_color, 'Color', 'w', 'Fontsize', 9);
            % put a yellow shade on ovelapped region
            sg = rectangle('Position', [min(t) u_ym(1) 0.0001 u_ym(2)-u_ym(1)], ...
                'EdgeColor', [0 0 1]*0.7); %, 'FaceColor', [0 0 1]*0.7); %, 'EraseMode', 'xor');
            drawnow
            
            % initialize the plot the convolution result 'c'
            ax_3 = subplot(3,1,3);
            r = plot(tc, c);
            grid on; hold on;
            set(ax_3, 'XColor', axis_color, 'YColor', axis_color, 'Fontsize', 9);
            % xlim( [ min(tc)-1 max(tc)+1 ] );
            xlim( [ ( min(t)-abs(max(tf)-min(tf)) - 1 ) ( max(t)+abs(max(tf)-min(tf)) + 1 ) ] );
            title('Convolutional Product c(t). Black is our BOLD', 'Color', axis_color );
            % animation block
            for i=1:length(tc)
                
                % control speed of animation minimum is 0, the lower the faster
                pause(0.005);
                drawnow;
                
                % update the position of sliding function 'g', its handle is 'q'
                tf=tf+s_int;
                drawnow % set(q,'EraseMode','xor');
                
                set(q,'XData',tf,'YData',g);
                % show overlapping regions
                
                % show a vertical line for a left boundary of overlapping region
                sx = min( max( tf(1), min(t) ), max(t) );
                sx_a = [sx sx];
                drawnow % set(s_l,'EraseMode','xor');
                set(s_l, 'XData', sx_a);
                % show a second vetical line for the right boundary of overlapping region
                ex = min( tf(end), max(t) );
                ex_a = [ex ex];
                drawnow % set(e_l,'EraseMode','xor');
                set(e_l, 'XData', ex_a);
                
                % update shading on ovelapped region
                rpos = [sx u_ym(1) max(0.0001, ex-sx) u_ym(2)-u_ym(1)];
                set(sg, 'Position', rpos);
                
                % update the plot of convolutional product 'c', its handle is r
                drawnow % set(r,'EraseMode','xor');
                set(r,'XData',tc(1:i),'YData',c(1:i) );
                
            end;
            tccontrast = (max(c)-min(c))/2;
            % ourBOLD = 100 * pm.unitless2contrast(pm.BOLDconv,tccontrast,true);
            ourBOLD = pm.BOLDconv;
            if ourBOLD(1) >= 0, ourBOLD = ourBOLD - ourBOLD(1);end
            if ourBOLD(1) <= 0, ourBOLD = ourBOLD + abs(ourBOLD(1));end
            plot(ourBOLD,'k-.')
            
            %
            % end of acnv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        end
        function v = contrast2BOLD(pm, signal, contrast, meanBOLD)
            % Normalize to 0-1, so that min(normBOLD) == 0
            normBOLD    = (signal - min(signal))/(max(signal) - min(signal));
            % Calculate the max value, so that the relation between the
            % meanValue and the amplitude is the one set in pm.BOLDcontrast
            maxValue    = (2*contrast/100) * meanBOLD;
            % No obtain the scaled value with the following formula
            minValue    = 0;
            scaledBOLD  = minValue + normBOLD .* (maxValue - minValue);
            % Now 100 * (max(scaledBOLD) - min(scaledBOLD)) / pm.BOLDmeanValue
            % is equal to pm.BOLDcontrast. Now we need to add the correct mean
            % to the signal so that pm.BOLD == pm.BOLDmeanValue
            v           = (scaledBOLD - mean(scaledBOLD)) + meanBOLD;
        end
        function v = unitless2contrast(pm, signal, contrast, centerzero)
            
            % TODO: the contrast we set, is the max contrast we would get when
            % the stimuli hits the center of the RF.
            % If the stimuli doesn't hit it, then the unitless max values that we are
            % goint to obtain from the matrix multiplication, are going to be
            % smaller. Right now, in the normalization process, it creates the
            % same amplitude for all. First aproximation to solve this problem
            % is that we are going to use the scale that it is coming from the
            % unitless timeseries. 
            
            
            
            
            
            
            
            % Normalize to 0-1, so that min(normBOLD) == 0
            normBOLD    = (signal - min(signal))/(max(signal) - min(signal));
            % Calculate the max value, so that the relation between the
            % meanValue and the amplitude is the one set in pm.BOLDcontrast
            maxValue    = (2*contrast/100);
            % Now obtain the scaled value with the following formula
            minValue    = 0;
            scaledBOLD  = minValue + normBOLD .* (maxValue - minValue);
            v           = (scaledBOLD - mean(scaledBOLD));
            if centerzero
                if v(1) >= 0, v = v - v(1);end
                if v(1) <= 0, v = v + abs(v(1));end
            end
            
        end
        % Compute synthetic BOLD with noise in top of the BOLD signal
        function compute(pm)
            % Computes the mean BOLD response and then adds noise.
            if pm.computeSubclasses
                % First, compute the values in the required sub-classes
                pm.Stimulus.compute;
                pm.RF.compute;
                pm.HRF.compute;
                pm.Temporal.compute; %[cst]
                pm.Noise.compute;
                
            end
            % Compute BOLDconv signal
            pm.computeBOLD;
            switch pm.signalPercentage
                 case {'frac', 'fractional'}
                    pm.BOLDnoise = pm.BOLD + pm.Noise.values;
                 case {'spc'}
                    pm.BOLDnoise = pm.BOLD + 100 * pm.Noise.values;
                    
%                   [cst]
                    if strcmp(pm.Type,'st')
                        if contains(char(pm.Temporal.temporalModel),'2ch')
%                             chan1 = pm.spaceTime(:,1)';
%                             chan2 =  pm.spaceTime(:,2)';
%                             chan3 = pm.spaceTime(:,1)'+ pm.spaceTime(:,2)';
%                             chan3 = chan3 + 100 * pm.Noise.values;
%                             %                         pm.cst =[];
%                             pm.cst= [chan1;chan2;chan3 ];
%                             pm.BOLDnoise = chan3;

                            pm.BOLDnoise = pm.Temporal.spc(:,3)' + 100 * pm.Noise.values;
                            pm.Temporal.synBOLD = pm.BOLDnoise;
                        else % deal with one channel models
                            pm.BOLDnoise = pm.Temporal.spc(:,1)' + 100 * pm.Noise.values;
                            pm.Temporal.synBOLD = pm.BOLDnoise;
                        end
                     end
             %===============================================
%                         synBOLD = pm.spaceTime;
%                         syndir = [stRootPath '/synBOLD/'];
%                         syn_file = [syndir pm.Temporal.Name '_synBOLD.mat'];
%                         save(syn_file,'synBOLD');
%              ===============================================


                        % this gets saved as NIFTI
                        
%                         if strcmp(pm.Noise.seed, 'random')
%                            % noised
%                              if pm.Noise.white_amplitude == 0.016
%                                  noisecond = 'low';
%                              else
%                                  noisecond = 'high';
%                              end
% 
%                         else
%                             % no-noised
%                             noisecond = 'no_noise';
%                         end
%                         
%                         % save BOLD
%                         
%                         whatstimtype = char(pm.Stimulus.stimseq);
%                         temp_type = char(pm.Stimulus.temporalType);
%                         dur = num2str(size(pm.timeSeries,1));
%                         sigmaVal = num2str(pm.RF.sigmaMajor);
%                         
%                         whatname = char(pm.Stimulus.expName);
%                         a = strsplit(whatname,'_');
%                         for curstr = 1:length(a)
%                             if contains(a{curstr},dur)
%                                 if contains(a{curstr},'s')
%                                     shuff ='s';
%                                 else
%                                     shuff ='';
%                                 end
%                                 
%                             end
%                         end
%                         
%                         simplename = [char(pm.Type) '_' noisecond '_' dur shuff whatstimtype ...
%                             '_sigma-' sigmaVal ...
%                             '_model-' temp_type ...
%                          ];

                     
                        
%                     elseif strcmp(pm.Type,'linear')
%                         
%                         synBOLD = pm.BOLDnoise;
%                         
%                         if strcmp(pm.Noise.seed, 'random')
%                             % noised
%                             if pm.Noise.white_amplitude == 0.016
%                                 noisecond = 'low';
%                             else
%                                 noisecond = 'high';
%                             end
%                             
%                         else
%                             % no-noised
%                             noisecond = 'no_noise';
%                         end
%                         
%                         whatstimtype = char(pm.Stimulus.stimseq);
%                         temp_type = 'linear';
%                         dur = num2str(size(pm.timeSeries,1));
%                         sigmaVal = num2str(pm.RF.sigmaMajor);
%                         
%                         whatname = char(pm.Stimulus.expName);
%                         a = strsplit(whatname,'_');
%                         for curstr = 1:length(a)
%                             if contains(a{curstr},dur)
%                                 if contains(a{curstr},'s')
%                                     shuff ='s';
%                                 else
%                                     shuff ='';
%                                 end
%                                 
%                             end
%                         end
%                         
%                         
%                         
%                         simplename = [char(pm.Type) '_' noisecond '_' dur shuff whatstimtype ...
%                             '_sigma-' sigmaVal ...
%                             '_model-' temp_type ...
%                             ];
%                         syndir = [cstRootPath '/synBOLD/'];
%                         syn_file = [syndir simplename '_synBOLD.mat'];
%                         save(syn_file,'synBOLD');
%                         
                    
              
                    
                    
                    %
                    
                    
                case {'bold'}
                    pm.BOLDnoise = pm.BOLDmeanValue * ...
                                   (1 + 2 * pm.BOLDcontrast/100 * pm.BOLDconv + pm.Noise.values);
                otherwise
                   error('%s provided, valid values are frac, spc, and bold (default)', pm.signalPercentage)
            end
            
        end
        % Plot it
        function plot(pm, varargin)
            % Read the inputs
            varargin = mrvParamFormat(varargin);
            p = inputParser;
            p.addRequired ('pm'  ,  @(x)(isa(x,'prfModel')));
            p.addParameter('what', 'both', @ischar);
            p.addParameter('window', true, @islogical);
            p.addParameter('addtext', false, @islogical);
            p.addParameter('color', 'b');
            p.addParameter('line', '-');
            p.addParameter('centerzero', false, @islogical);
            p.addParameter('addhrf', true, @islogical);
            
            p.parse(pm,varargin{:});
            what = mrvParamFormat(p.Results.what);
            w  = p.Results.window;
            t  = p.Results.addtext;
            c  = p.Results.color;
            z  = p.Results.centerzero;
            h  = p.Results.addhrf;
            line  = p.Results.line;
            
            switch what
                case 'timeseries'
                    pm.computeBOLD
                    if w;mrvNewGraphWin([pm.Type 'timeseries']);end
                    % plot(pm.timePointsSeries, pm.unitless2contrast(pm.timeSeries, ...
                    %      pm.BOLDcontrast,true),'-o','color',c,'LineWidth',2);
                    plot(pm.timePointsSeries, pm.timeSeries, ...
                         '-o','color','b','LineWidth',2);
                    legend({'Time Series'})
                case 'nonoisetimeseries'
                    pm.computeBOLD
                    if w;mrvNewGraphWin([pm.Type 'Synthetic BOLD signals']);end
                    % plot(pm.timePointsSeries, pm.unitless2contrast(pm.timeSeries, ...
                    %      pm.BOLDcontrast,true),'--','color','k','LineWidth',1); hold on;
                    plot(pm.timePointsSeries, pm.timeSeries,'--','color','k',...
                                                        'LineWidth',1); hold on;
                    plot(pm.timePointsSeries, pm.BOLDconv,'color','b');
                    plot(pm.timePointsSeries, pm.BOLD,'color','r');
                    legend({'Time Series','No scaled BOLD','Scaled BOLD'})
                case {'nonoise','noiseless','noisefree'}
                    pm.computeBOLD
                    if w;mrvNewGraphWin([pm.Type 'Synthetic BOLD signal (no noise)']);end
                    plot(pm.timePointsSeries, pm.BOLD,'o','color',c,'LineStyle',line);
                case 'withnoise'
                    pm.compute;
                    if w;mrvNewGraphWin([pm.Type 'Synthetic BOLD signal (noise)']);end
                    plot(pm.timePointsSeries, pm.BOLDnoise,'color',c,'LineStyle',line);
                    grid on; xlabel('Time (sec)'); ylabel('Relative amplitude');
                case 'both'
                    pm.compute;
                    if w;mrvNewGraphWin([pm.Type 'Synthetic BOLD signals']);end
                    plot(pm.timePointsSeries, pm.BOLD,'--','color','k','LineStyle',line); hold on;
                    plot(pm.timePointsSeries, pm.BOLDnoise,'color',c,'LineStyle',line);
                    legend({'No Noise BOLD','With Noise BOLD'})
                case 'all'
                    pm.compute;
                    if w;mrvNewGraphWin([pm.Type 'Synthetic BOLD signals']);end
                    % plot(pm.timePointsSeries, pm.unitless2contrast(pm.timeSeries, pm.BOLDcontrast,true),'color','k'); hold on;
                    plot(pm.timePointsSeries, pm.timeSeries,'color','k','LineStyle',line); hold on;
                    plot(pm.timePointsSeries, pm.BOLD,'LineStyle',line);
                    plot(pm.timePointsSeries, pm.BOLDnoise,'LineStyle',line);
                    legend({'Time Series','No Noise BOLD','With Noise BOLD'})                    
                case 'withnoisetimeseries'
                    pm.compute;
                    if w;mrvNewGraphWin([pm.Type 'Synthetic BOLD signals']);end
                    % plot(pm.timePointsSeries, pm.unitless2contrast(pm.timeSeries, pm.BOLDcontrast,true),'color','k'); hold on;
                    plot(pm.timePointsSeries, pm.timeSeries,'color','k','LineStyle',line); hold on;
                    plot(pm.timePointsSeries, pm.BOLDnoise);
                    legend({'Time Series','With Noise BOLD'})
                case 'componentfft'
                    % Plots the stimulus and HRF amplitude spectrum
                    
                    % Obtain time series (matrix mult between stim and rf) and hrf
                    ts    = pm.timeSeries;
                    hrf   = zeros(size(ts));
                    hrf(1:size(pm.HRF.values,2)) = pm.HRF.values;
                    
                    % Obtain the FFT of both signals
                    Pts   = abs(fft(ts)/pm.timePointsN);
                    Phrf  = abs(fft(hrf)/pm.timePointsN);
                    
                    % Halve it
                    hlftpN = round(pm.timePointsN/2);
                    Fts    = Pts(1:hlftpN);
                    Fhrf   = Phrf(1:hlftpN);
                    % The amplitude is divided in the two halfs, so we take one half and
                    % multiply the amplitude by two
                    Fts(2:end-1) = 2*Fts(2:end-1);
                    Fhrf(2:end-1) = 2*Fhrf(2:end-1);
                    % Get the frequency vector (for the half points)
                    fts  = (1/pm.TR)*(0:hlftpN-1)./pm.timePointsN;
                    fhrf = (1/pm.TR)*(0:hlftpN-1)./pm.timePointsN;
                    
                    % Plot it
                    if w;mrvNewGraphWin(['Individual component spectrum']);end
                    plot(fts, Fts, 'Color', c);hold on;
                    if h;plot(fhrf, Fhrf,'k-');end
                    grid on; xlabel('f[Hz]'); ylabel('Relative amplitude');
                    title(['Individual component spectrum, TR=' num2str(pm.TR)])
                    
                    
                otherwise
                    error('no noise, with noise, both, all, with noise timeseries, no noise timeseries are acepted')
            end
            grid on;
            if ~strcmp(what,'componentfft')
                 xlabel('Time (sec)'); ylabel('Relative amplitude');
            end
            aa = gca;
            if t, text(5,aa.YLim(1)*(1.0025),...
                    sprintf('TR=%1.1fs, Center(x0,y0)=[%1.1f,%1.1f]deg, Theta=%1.1frad, \\sigmaMaj=%1.1fdeg, \\sigmaMin=%1.1fdeg, FoVh=%1.1fdeg, FoVv=%1.1fdeg' ,...
                    pm.TR,        pm.RF.Centerx0, pm.RF.Centery0, pm.RF.Theta,    pm.RF.sigmaMajor,     pm.RF.sigmaMinor,     pm.Stimulus.fieldofviewHorz, pm.Stimulus.fieldofviewVert))
            end
        end
    end
end
