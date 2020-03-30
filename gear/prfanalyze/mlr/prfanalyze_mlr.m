function prfanalyze_mlr(opts_file, json_file, bold_file, stim_file, output_dir)
% 
% (C) Vista Lab, Stanford University, 2019
% 
%{
bold_file  = '/data/localhome/glerma/toolboxes/PRFmodel/local/output/alex/BIDS/sub-alexsynth/ses-stim5v02/func/sub-alexsynth_ses-stim5v02_task-prf_acq-normal_run-01_bold.nii.gz';
json_file  = '/data/localhome/glerma/toolboxes/PRFmodel/local/output/alex/BIDS/derivatives/prfsynth/sub-alexsynth/ses-stim5v02/sub-alexsynth_ses-stim5v02_task-prf_acq-normal_run-01_bold.json';
stim_file  = '/data/localhome/glerma/toolboxes/PRFmodel/local/output/alex/BIDS/stimuli/sub-alexsynth_ses-stim5v02_task-prf_apertures.nii.gz';
output_dir = '/data/localhome/glerma/toolboxes/PRFmodel/local/output/alex';
%}
    
%% Initial checks

% If nothing was passed in, display help and return
if nargin == 0
    help_file = '/opt/help.txt';
    if exist(help_file, 'file')
        system(['cat ', help_file]);
    else
        help(mfilename);
    end
    return
end

% Assume the user wanted to see the help, and show it
if ischar(json_file)
    if strcmpi(json_file, 'help') ...
            || strcmpi(json_file, '-help') ...
            || strcmpi(json_file, '-h') ...
            || strcmpi(json_file, '--help')
        help(mfilename);
    end
end

% read in the opts file
%{
opts = {};
if ~isempty(opts_file)
    tmp = loadjson(opts_file);
    if ~isempty(tmp)
        % tmp = tmp.options;
        fs = fields(tmp);
        for ii = 1:numel(fs)
            opts{end+1} = fs{ii};
            opts{end+1} = getfield(tmp, fs{ii});
        end
    end
end
%}

% read in the opts file
if ~isempty(opts_file)
    fprintf('This is the config.json file being read: %s\n',opts_file)
    tmp = loadjson(opts_file);
    disp('These are the contents of the json file:')
    tmp
    if ~isempty(tmp)
        opt.options.mlr = tmp.options;
        opts = {'options', opt};
    else
        opts = {};
    end
else
    opts = {};
end




% Make the output directory
mkdir(output_dir);

%% Parse the JSON file or object
%{
% Create a pm instance, we will use it in both cases
pm = prfModel;
% Check if we need to read a json or provide a default one
if exist(json_file, 'file') == 2
    J = loadjson(json_file);
    if iscell(J)
        J=J{:};
    end
else
    % #TODO --clean this up to be appropriate for prfanalyze-aprf
    % return the default json and exit
    DEFAULTS = pm.defaultsTable;
    % Add two params required to generate the file
    DEFAULTS.subjectName = "editDefaultSubjectName";
    DEFAULTS.sessionName = "editDefaultSessionName";
    DEFAULTS.repeats  = 2;
    % Reorder fieldnames
    DEF_colnames = DEFAULTS.Properties.VariableNames;
    DEF_colnames = DEF_colnames([end-2:end,1:end-3]);
    DEFAULTS     = DEFAULTS(:,DEF_colnames);
    % Select filename to be saved
    fname = fullfile(output_dir, 'defaultParams_ToBeEdited.json');
    % Encode json
    jsonString = jsonencode(DEFAULTS);
    % Format a little bit
    jsonString = strrep(jsonString, ',', sprintf(',\n'));
    jsonString = strrep(jsonString, '[{', sprintf('[\n{\n'));
    jsonString = strrep(jsonString, '}]', sprintf('\n}\n]'));

    % Write it
    fid = fopen(fname,'w');if fid == -1,error('Cannot create JSON file');end
    fwrite(fid, jsonString,'char');fclose(fid);
    % Permissions
    fileattrib(fname,'+w +x', 'o g'); 
    disp('defaultParams_ToBeEdited.json written, edit it and pass it to the container to generate synthetic data.')
    return
end
%}


%% check that the other relevant files eist
if exist(bold_file, 'file') ~= 2
    disp(sprintf('Given BOLD 4D nifti file does not exist: %s', bold_file))
    return
end
if exist(stim_file, 'file') ~= 2
    disp(sprintf('Given stimulus 3D nifti file does not exist: %s', stim_file))
    return
end

%% Call pmModelFit!
disp('================================================================================');
disp(opts_file);
disp(bold_file);
disp(json_file);
disp(stim_file);
disp('--------------------------------------------------------------------------------');

[pmEstimates, results] = pmModelFit({bold_file, json_file, stim_file}, 'vista', opts{:});
%% Write out the results
estimates_file = fullfile(output_dir, 'estimates.mat');
estimates = struct(pmEstimates);
save(estimates_file, 'estimates', 'pmEstimates');
results_file = fullfile(output_dir, 'results.mat');
save(results_file, 'results');


% Save it as  json file as well
% Select filename to be saved
fname = fullfile(output_dir, ['estimates.json']);
% Encode json
jsonString = jsonencode(pmEstimates);
% Format a little bit
jsonString = strrep(jsonString, ',', sprintf(',\n'));
jsonString = strrep(jsonString, '[{', sprintf('[\n{\n'));
jsonString = strrep(jsonString, '}]', sprintf('\n}\n]'));

% Write it
fid = fopen(fname,'w');if fid == -1,error('Cannot create JSON file');end
fwrite(fid, jsonString,'char');fclose(fid);







% Permissions
fileattrib(output_dir,'+w +x', 'o'); 

return 



