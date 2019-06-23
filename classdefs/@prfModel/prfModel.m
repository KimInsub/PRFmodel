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
       pm.rfCompute;
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
        % Basic, CSS ... (char)
        Type            ;
        % Components required to build the synthetic bold signal (classes)
        Stimulus        ;
        RF              ;
        HRF             ;
        Noise           ;
        % Other required options (double)
        BOLDmeanValue   ; % Required mean value of the synthetic BOLD signal
        BOLDcontrast    ; % Required  contrast  of the synthetic BOLD signal
        % BOLD signal value (before noise)
        BOLD            ;
        % The result: synthetic BOLD series (1 dim array of doubles)
        BOLDnoise       ; % Final value, composed of the BOLD + noise
    end
    properties (Dependent)
        TR              ; % This one is derived and copied to all other classes
        timePointsN     ; % Defined by the stimulus.
        timePointsSeries; % Defined by the stimulus.
        defaultsTable   ;
    end
    
    methods (Static)
        function d = defaultsGet
            d.TR            = 1;
            d.Type          = 'basic';
            d.BOLDmeanValue = 10000;
            d.BOLDcontrast  = 8;
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
            p.addParameter('tr'           ,  d.TR           , @isnumeric);
            p.addParameter('type'         ,  d.Type{:}      , @ischar);
            p.addParameter('boldmeanValue',  d.BOLDmeanValue, @isnumeric);
            p.addParameter('boldcontrast' ,  d.BOLDcontrast , @isnumeric);
            
            
            p.parse(varargin{:});
            % Assign defaults/parameters to class/variables
            pm.TR            = p.Results.tr;
            pm.Type          = p.Results.type;
            pm.BOLDmeanValue = 10000;
            pm.BOLDcontrast  = 8;  % In percentage
            
            % Create the classes, and initialize a prfModel inside it
            pm.Stimulus      = pmStimulus(pm);
            pm.HRF           = pmHRF(pm);
            pm.RF            = pmRF(pm);
            
            % We should initialize the RNG here and return the seed
            
            % pm.Noise takes one or several noise models that will be added
            % recursively and independently to the bold signal, i.e. each noise
            % is independent from each other.
            pm.Noise = {pmNoise(pm, 'Type','white'), ...
                pmNoise(pm, 'Type','cardiac',...
                'params',struct('frequency',1.3)), ...
                pmNoise(pm, 'Type','respiratory',...
                'params',struct('frequency',1.3))};
        end
        
        
        % Functions that apply the setting of main parameters to subclasses
        % TR: set and get
        function set.TR(pm, tr)
            pm.uniqueTR           = tr;
            % pm.HRF.setTR(tr);
            % pm.Stimulus.setTR(tr);
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
        
        function defaultsTable = get.defaultsTable(pm)
            % This function obtains all the defaults from all the
            % subclasses, so that we can construct a parameter table
            defaultsTable           = pm.defaultsGet;
            defaultsTable.HRF       = pm.HRF.defaultsGet;
            defaultsTable.RF        = pm.RF.defaultsGet;
            defaultsTable.Stimulus  = pm.Stimulus.defaultsGet;
            % Noise are several noise models by default, add them all
            for nn = 1:length(pm.Noise)
                tmp                 = pm.Noise{nn}.defaultsGet;
                tmp.Type            = pm.Noise{nn}.Type;
                defaultsTable.(['Noise_' tmp.Type]) = tmp;
            end
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
            p.parse(pm,varargin{:});
            
            % Load example stimulus
            stimValues = pm.Stimulus.getStimValues;
            
            % Initialize timeSeries, it is the signal prior to convolution
            [r,c,t] = size(stimValues);
            spaceStim = reshape(stimValues,r*c,t);
            
            % Calculate time series
            timeSeries  = pm.RF.values(:)' * spaceStim;
            
            % Convolution between the timeSeries and the HRF
            % The HRF is defined in its own time frame
            % hrfValues   = pm.HRF.values;
            % hrftSteps   = pm.HRF.tSteps;
            % hrfDuration = pm.HRF.Duration;
            % Resample the HRF to n timepoints corresponding to the TR and duration
            % pm.TR has to be multiple of 0.1
            
            % hrfResampled= 0:pm.TR:hrfDuration-pm.TR;
            
            
            pm.BOLD = conv(timeSeries, pm.HRF.values, 'same');
            
            % Scale the signal so that it has the required mean and contrast
            % Normalize to 0-1, so that min(normBOLD) == 0
            normBOLD    = (pm.BOLD - min(pm.BOLD))/(max(pm.BOLD) - min(pm.BOLD));
            % Calculate the max value, so that the relation between the
            % meanValue and the amplitude is the one set in pm.BOLDcontrast
            maxValue    = (pm.BOLDcontrast/100) * pm.BOLDmeanValue;
            % No obtain the scaled value with the following formula
            minValue    = 0;
            scaledBOLD  = minValue + normBOLD .* (maxValue - minValue);
            % Now 100 * (max(scaledBOLD) - min(scaledBOLD)) / pm.BOLDmeanValue
            % is equal to pm.BOLDcontrast. Now we need to add the correct mean
            % to the signal so that pm.BOLD == pm.BOLDmeanValue
            pm.BOLD     = (scaledBOLD - mean(scaledBOLD)) + pm.BOLDmeanValue;
            
            switch pm.Type
                case 'basic'
                    pm.BOLD = pm.BOLD;
                case 'CSS'
                    pm.BOLD = pm.BOLD;
                otherwise
                    error('Model %s not implemented, select basic or CSS', pm.Type)
            end
            
        end
        % Compute synthetic BOLD with noise in top of the BOLD signal
        function compute(pm)
            % Computes the mean BOLD response and then adds noise.
            
            % First, compute the values in the required sub-classes
            pm.Stimulus.compute;
            pm.RF.compute;
            pm.HRF.compute;
            
            % Every sub-class has a computeBOLD function to compute the mean response.
            pm.computeBOLD;
            
            % Compute and add noise
            sumOfNoise = zeros(size(pm.BOLD));
            for ii=1:length(pm.Noise)
                pm.Noise{ii}.compute;
                sumOfNoise = sumOfNoise + pm.Noise{ii}.values;
            end
            
            pm.BOLDnoise = pm.BOLD + sumOfNoise;
        end
        
        % Plot it
        function plot(pm, what)
            what = mrvParamFormat(what);
            switch what
                case 'nonoise'
                    mrvNewGraphWin([pm.Type 'Synthetic BOLD signal (no noise)']);
                    plot(pm.timePointsSeries, pm.BOLD);
                    grid on; xlabel('Time (sec)'); ylabel('Relative amplitude');
                case 'withnoise'
                    mrvNewGraphWin([pm.Type 'Synthetic BOLD signal (noise)']);
                    plot(pm.timePointsSeries, pm.BOLDnoise);
                    grid on; xlabel('Time (sec)'); ylabel('Relative amplitude');
                case 'both'
                    mrvNewGraphWin([pm.Type 'Synthetic BOLD signals']);
                    plot(pm.timePointsSeries, pm.BOLD); hold on;
                    plot(pm.timePointsSeries, pm.BOLDnoise);
                    grid on; xlabel('Time (sec)'); ylabel('Relative amplitude');
                    legend({'No Noise','With Noise'})
                otherwise
                    error("Only 'no noise', 'with noise' and 'both' are acepted")
            end
            
        end
        
    end
    
end
