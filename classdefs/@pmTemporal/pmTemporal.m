classdef pmTemporal <   matlab.mixin.SetGet & matlab.mixin.Copyable
    % This is a superclass for Temporal attributes
    % Syntax:
    %      rf = RF();
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
    %}
    
    %
    
    
    properties
        PM;         % prfModel that has some of the variables we need, such as TR
        stimseq          ;  % [cst] exp A exp B  exp C
        temporalModel    ;  % [cst] temporal modeling
        Type             ;
        IRFpath          ;
        chan_preds       ;
        run_preds        ;
        spc              ;
        synBOLD          ;
        synBOLDpath      ;
    end
    
    properties (SetAccess = private, GetAccess = public)
        values;    % Result. Only can be changes from within this func.
    end
    properties(Dependent= true, SetAccess = private, GetAccess = public)
        TR;            % Seconds, it will be read from the parent class pm
        Name;
        
    end
    
    
    
    %%
    methods (Static)
        function d = defaultsGet
            d.stimseq        = "a"; % [cst] stim sequance Exp a, b, or c
            d.temporalModel  = "None"; %[cst] stim temporal model
            d.Type           = 'mrvista';
            % Convert to table and return
            d = struct2table(d,'AsArray',true);
        end
    end
    methods
        % Constructor
        function temporal = pmTemporal(pm, varargin)
            % Obtain defaults table. If a parameters is not passed, it will use
            % the default one defined in the static function
            d = temporal.defaultsGet;
            % Read the inputs
            varargin = mrvParamFormat(varargin);
            p = inputParser;
            p.addRequired ('pm'            ,                   @(x)(isa(x,'prfModel')));
            p.addParameter('stimseq'        ,d.stimseq        , @ischar); %[cst]
            p.addParameter('temporalModel'   ,d.temporalModel   , @ischar); %[cst]
            p.addParameter('Type'          , d.Type{:}       , @ischar);
            p.parse(pm,varargin{:});
            
            % Initialize the pm model and hrf model parameters
            temporal.PM             = pm;
            % The receptive field parameters
            temporal.stimseq         = p.Results.stimseq; %[cst]
            temporal.temporalModel    = p.Results.temporalModel; %[cst]
            temporal.Type    = p.Results.Type; %[cst]
            
            % Set path for saving data
            temporal.IRFpath       = fullfile(stRootPath,'IRF/');
            temporal.synBOLDpath   = fullfile(stRootPath,'synBOLD/');

        end
        
        function v = get.TR(temporal)
            v      = temporal.PM.TR;
        end
        
        function Name = get.Name(temporal)
            Name = [...
                char(temporal.PM.Type)  ...
                '_dur-'         num2str(temporal.PM.Stimulus.timePointsN) ...
                '_shuff-'       choose(temporal.PM.Stimulus.Shuffle,'true', 'false')  ...
                '_seq-'         char(temporal.stimseq)      ...
                '_tmodel-'      char(temporal.temporalModel) ...
                ];
        end
        
        
        
        % Methods available to this class and childrens, if any
        
        function compute(temporal)
            if iscell(temporal.Type);type = temporal.Type{:};else;type=temporal.Type;end
            switch type
                case {'mrvista'}
                    
                    if strcmp(temporal.temporalModel,"None")
                        % do nothing
                    else
                        temporal.PM.Stimulus.compute;
                        temporal.PM.RF.compute;
                        temporal.PM.HRF.compute;
                        
                        irf_file = [temporal.IRFpath temporal.Name '_irf.mat'];
                        
                        % compute IRF
                        if isfile(irf_file)
                            disp('*st irf exists no need to make a new one!*')
                            %                         temporal.chan_preds      = [1,2,3];
                            load(irf_file);
                        else
                            tmodel = st_createIRF(temporal.PM);
                            
                        end
                        
                        % convolve rf with stimulus for each t-channel
                        for cc=1:tmodel.num_channels
                            pred = tmodel.chan_preds{cc}*(temporal.PM.RF.values(:));
                            
                            % apply css
                            %                       pred = bsxfun(@power, pred, 0.05);
                            pred = double(pred);
                            
                            % apply hrf
                            pred_cell = num2cell(pred,1)';
                            npixel_max = size(1,2);
                            
                            % use mrvista HRF
                            %   params.stim(n).images = filter(params.analysis.Hrf{n}, 1, params.stim(n).images'); % images: pixels by time (so images': time x pixels)
                            %                 hrf = params.analysis.Hrf;
                            
                            %                         hrf = {pm.HRF.values'};
                            hrf = tmodel.irfs.hrf;
                            
                            %                         vistaHRF = conv(pred_cell{1}, pm.HRF.values);
                            %                         vistaHRF = conv(pred_cell{1}', tmodel.irfs.hrf{1});
                            % hrf = tmodel.irfs.hrf;
                            curhrf = repmat(hrf, npixel_max, 1);
                            pred_hrf = cellfun(@(X, Y) convolve_vecs(X, Y, tmodel.fs, 1 / tmodel.tr), ...
                                pred_cell, curhrf, 'uni', false);
                            pred_hrf = cellfun(@transpose,pred_hrf,'UniformOutput',false);
                            pred_hrf=cell2mat(pred_hrf)';
                            %
                            if cc ==2
                                pred_hrf = pred_hrf*tmodel.normT;
                            end
                            
                            % store
                            tmodel.run_preds(:,cc) = pred_hrf;
                        end
                        
                        temporal.chan_preds      = tmodel.chan_preds;
                        temporal.run_preds       = tmodel.run_preds;
                    end
                        
                otherwise
                    error('%s not implemented yet', type)
            end
            
            
        
           
        end
        
        %         % Plot it
        %         function plot(rf,varargin)
        %             set(0, 'DefaultFigureRenderer', 'opengl');
        %             % Read the inputs
        %             varargin = mrvParamFormat(varargin);
        %             p = inputParser;
        %             p.addRequired ('rf'  ,  @(x)(isa(x,'pmRF')));
        %             p.addParameter('window',true, @islogical);
        %             p.parse(rf,varargin{:});
        %             w = p.Results.window;
        %             % Compute before plotting
        %             rf.compute
        %             % Plot it
        %             if w; mrvNewGraphWin('Receptive Field');end
        %             mesh(rf.values);
        %             grid on;
        %             if w; xlabel('x'); ylabel('y'); end
        %             set(0, 'DefaultFigureRenderer', 'painters');
        %         end
    end
    
end



