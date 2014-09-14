clear, close all, clc

% filename_input = fullfile('ClickDetection', 'authentic_degradations', 'data_5_authentic.wav');
% filename_input = fullfile('ClickDetection', 'original', 'data_10_music_lounge.wav');
% dir_signals = fullfile('ClickDetection', 'synthetic_degradations');
% dir_signals = fullfile('ClickDetection', 'authentic_degradations');

% dir_signals = '/media/matthias/daten_4/testsignale/disturbed/impulsive_disturbances/archive_org_78rpm_collection/clicks/Aileen_Stanley-All_By_Myself';
% dir_signals = '/media/matthias/daten_4/testsignale/disturbed/impulsive_disturbances/archive_org_78rpm_collection/crackle_severe/1iveBeenBukedAndIveBeenScorned2MostDoneTrabelling1iveBeenBukedAndIveBeenScorned2MostDoneTrabelling1iveBeenBukedAndIveBeenScorned2MostDoneTrabelling';
% dir_signals = '/media/matthias/daten_4/testsignale/disturbed/impulsive_disturbances/archive_org_78rpm_collection/crackle_mild/AbieTakeAnExampleFromYourFadder';
% dir_signals = fullfile('/media/matthias/daten_4/temp/1955');
% dir_signals = '/media/matthias/daten_4/tempvinyl/neu/';
% dir_signals = '/media/matthias/daten_4/tempvinyl/1986';
% dir_signals = '/media/matthias/daten_4/testsignale/tempsz/2000';
% dir_signals = '/home/matthias/Dropbox/projects/impulsive_noise_detection/code/matlab/topics/feature_analysis/detector_signals_2000_40db';
% dir_signals = '/home/matthias/Dropbox/projects/impulsive_noise_detection/code/matlab/topics/prony_fit';

dir_signals = '/media/matthias/daten_4/testsignale/project_related/impulse_disturbance_detector/evaluation_neu';
% dir_signals = '/media/matthias/daten_4/testsignale/project_related/impulse_disturbance_detector/fraunhofer/ClickDetection/';

% dir_signals = fullfile(dirup(3), 'signals')

% dir_signals = fullfile('ClickDetection');

% dir_signals = 'test';


% '06 - O.V. Wright - Ace of Spades_snippet.wav';

st_files = findFile('\w*.(wav)$', dir_signals, false, inf, true);
% st_files = st_files(2);
% st_files = findFile('04 - Paul Simon - Gumboots.wav', dir_signals, false, inf, true);

T_block=1000e-3;

st_results = [];

% b_impulse = false;

for a = 1 : length(st_files)
    filename_input = fullfile(dir_signals, st_files(a).path, st_files(a).name);
    
    c_temp = regexp(fullfile(st_files(a).path, st_files(a).name), '^(?<class>.*)\/(?<year>.*)\/(?<basename>.*)\.(?<extenstion>.*)$', 'tokens');
    
    class = c_temp{1}{1};
    year = c_temp{1}{2};
    basename = c_temp{1}{3};
    extension = c_temp{1}{4};
    
    % determine the expected detection result filename
    filename_detectionResult = fullfile(dir_signals, st_files(a).path, [removeExtension(st_files(a).name) sprintf('_detectionResult-%05.0fms.mat', T_block*1000)]);
    
    % determine the expected ground truth filename
    filename_groundTruth = fullfile(dir_signals, st_files(a).path, [removeExtension(st_files(a).name) sprintf('_groundTruth-%05.0fms.mat', T_block*1000)]);
    
    if exist(filename_detectionResult, 'file') ~= 2
        error(['detection result not found: ' st_files(a).name]);
    end
    
    b_ground_truth = true;
    if exist(filename_groundTruth, 'file') ~= 2
        warning(['ground truth not found: ' st_files(a).name]);
        display('assuming the signal is clean.');
        b_ground_truth = false;
    end
    
    st_data(a).filename_input = filename_input;
    
    % load the detection results
    st_temp = load(filename_detectionResult);
    st_data(a).st_detection_result = st_temp.st_impulsive_noise_block;
    
    if b_ground_truth
        % load the ground truth data
        st_temp = load(filename_groundTruth);
        
        if st_temp.T_block ~= T_block
            error('wrong block size stored in ground truth data.');
        end
        
        st_data(a).st_ground_truth = st_temp.st_annotations;
    else
        % generate artificial ground truth data
        for b = 1 : length(st_data(a).st_detection_result)
            st_ground_truth(b).idx_start = st_data(a).st_detection_result.idx_start;
            st_ground_truth(b).idx_end = st_data(a).st_detection_result.idx_end;
            st_ground_truth(b).click_intensity(b) = 0; % clean
            st_data(a).st_ground_truth = st_ground_truth;
        end
    end
    
    a / length(st_files)
end

% now we're done loading the data

% -> compare estimation result with ground truth
N_hit = 0;
N_false_alarm = 0;
N_miss = 0;
N_correct_reject = 0;
threshold = 0.5;
N_results = 0;

dir_blocks = '/media/matthias/daten_4/testsignale/project_related/impulse_disturbance_detector/wrong_classified_blocks';
mkdir(fullfile(dir_blocks, 'hit'));
mkdir(fullfile(dir_blocks, 'miss'));
mkdir(fullfile(dir_blocks, 'false_alarm'));
mkdir(fullfile(dir_blocks, 'correct_rejected'));

% store the results in a table
% -> plot in r (ggplot)

tab_data = table();

b_audio = false;


for a = 1 : length(st_data)
    for b = 1 : length(st_data(a).st_detection_result)
        if st_data(a).st_detection_result(b).p_impulsive_noise > threshold
            b_click_detected = true;
        else
            b_click_detected = false;
        end
        
        if st_data(a).st_ground_truth(b).click_intensity > 0
            b_click_present = true;
            cur_gt_string = 'disturbed';
        else
            b_click_present = false;
            cur_gt_string = 'clean';
        end
        
        if b_audio
        % load the wave data of the current block
        [x, fs] = audioread(st_data(a).filename_input, [st_data(a).st_detection_result(b).idx_start st_data(a).st_detection_result(b).idx_end]);
        
        [~, basename, ext] = fileparts(st_data(a).filename_input);
        end
        
        N_results = N_results + 1;
        
        if b_click_detected && b_click_present
            N_hit = N_hit + 1;
            %             audiowrite(fullfile(dir_blocks, 'hit', [basename '_' num2str(b) ext]), x, fs);
            cur_string = 'hit';
        end
        
        if b_click_detected && ~b_click_present
            N_false_alarm = N_false_alarm + 1;
            if b_audio
            audiowrite(fullfile(dir_blocks, 'false_alarm', [basename '_' num2str(b) ext]), x, fs);
            end           
            cur_string = 'false alarm';
        end
        
        if ~b_click_detected && b_click_present
            N_miss = N_miss + 1;
            if b_audio
            audiowrite(fullfile(dir_blocks, 'miss', [basename '_' num2str(b) ext]), x, fs);
            end
            cur_string = 'miss';
        end
        
        if ~b_click_detected && ~b_click_present
            N_correct_reject = N_correct_reject + 1;
            %             audiowrite(fullfile(dir_blocks, 'correct_rejected', [basename '_' num2str(b) ext]), x, fs);
            cur_string = 'correct rejection';
        end
        
        
        
        % store in the table
        if false
            tab_data = [tab_data; ...
                table(int8(b_click_present), int8(b_click_detected))];
            %int8( b_click_detected && b_click_present), int8(~b_click_detected && b_click_present), int8(b_click_detected && ~b_click_present), int8(~b_click_detected && ~b_click_present)
        else
            tab_data = [tab_data; ...
                table({cur_gt_string}, {cur_string})];
        end
    end
end

% for a = 1 : length(st_data)
%     for b = 1 : length(st_data(a).st_detection_result)
%         if st_data(a).st_detection_result(b).p_impulsive_noise > threshold
%             b_click_detected = true;
%         else
%             b_click_detected = false;
%         end
%         
%         if st_data(a).st_ground_truth(b).click_intensity > 0
%             b_click_present = true;
%         else
%             b_click_present = false;
%         end
%         
% %         % load the wave data of the current block
% %         [x, fs] = audioread(st_data(a).filename_input, [st_data(a).st_detection_result(b).idx_start st_data(a).st_detection_result(b).idx_end]);
%         
%         [~, basename, ext] = fileparts(st_data(a).filename_input);
%         
%         N_results = N_results + 1;
%         
%         if b_click_detected && b_click_present
%             N_hit = N_hit + 1;
%             %             audiowrite(fullfile(dir_blocks, 'hit', [basename '_' num2str(b) ext]), x, fs);
%             cur_string = 'hit';
%         end
%         
%         if b_click_detected && ~b_click_present
%             N_false_alarm = N_false_alarm + 1;
%             audiowrite(fullfile(dir_blocks, 'false_alarm', [basename '_' num2str(b) ext]), x, fs);
%             cur_string = 'false alarm';
%         end
%         
%         if ~b_click_detected && b_click_present
%             N_miss = N_miss + 1;
%             audiowrite(fullfile(dir_blocks, 'miss', [basename '_' num2str(b) ext]), x, fs);
%             cur_string = 'miss';
%         end
%         
%         if ~b_click_detected && ~b_click_present
%             N_correct_reject = N_correct_reject + 1;
%             %             audiowrite(fullfile(dir_blocks, 'correct_rejected', [basename '_' num2str(b) ext]), x, fs);
%             cur_string = 'correct rejection';
%         end
%         
%         
%         
%         % store in the table
%         if false
%             tab_data = [tab_data; ...
%                 table(int8(b_click_present), int8(b_click_detected))];
%             %int8( b_click_detected && b_click_present), int8(~b_click_detected && b_click_present), int8(b_click_detected && ~b_click_present), int8(~b_click_detected && ~b_click_present)
%         else
%             tab_data = [tab_data; ...
%                 table({cur_string})];
%         end
%     end
% end

% tab_data.Properties.VariableNames = {'present', 'detected'};
tab_data.Properties.VariableNames = {'class', 'result'};

writetable(tab_data, 'results_ground_truth_comparison.csv');

% tab_data_2 = table(

break;

% plot the value distributions
c_signal_types = stFindAllFieldValues(st_results, 'file_type');

c_p = cell(length(c_signal_types), 1);

for a = 1 : length(st_results)
    % determine the index of the signal type
    idx_signal_type = find(strcmp(st_results(a).file_type, c_signal_types));
    
    for b = 1 : length(st_results(a).vec_p_click)
        c_p{idx_signal_type}(end+1) = st_results(a).vec_p_click(b);
    end
end

% compute histogram
vec_edges = 0:.1:1;
mat_hist = zeros(length(c_signal_types), length(vec_edges));
for a = 1 : length(c_signal_types)
    mat_hist(a, :) = histc(c_p{a}, vec_edges)/length(c_p{a});
end

% plot
figure(1)
plot(vec_edges, mat_hist);
legend(c_signal_types);

% criterion 1
% (one block p_click >= 0.5)
for a = 1 : length(st_results)
    st_results(a).b_click_crit_1 = max(st_results(a).vec_p_click) >= 0.5;
end

