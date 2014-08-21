function [p_impulsive_noise_overall, st_blocks] = detect_impulsive_noise(filename_input, T_block, p_threshold)

if nargin < 3
    p_threshold = 0.5;
end

% determine which svm model to load
% filename_model = ['svm_model_phat_' num2str(T_block) '_file'];
filename_model = ['svm_model_product_' num2str(T_block) '_file'];
st_temp = load(filename_model);
st_parameters = st_temp.st_parameters;

st_parameters_impulse_noise_detector.filename_input = filename_input;
st_parameters_impulse_noise_detector.T_safety_gap = st_parameters.T_safety_gap;
st_parameters_impulse_noise_detector.L_DFT = st_parameters.L_DFT;
st_parameters_impulse_noise_detector.detectorsignal_mode = st_parameters.detectorsignal_mode;
st_parameters_impulse_noise_detector.T_peak_search_region = st_parameters.T_peak_search_region;
st_parameters_impulse_noise_detector.tempo_multiplier = st_parameters.tempo_multiplier;
st_parameters_impulse_noise_detector.T_block = st_parameters.T_block;
%     st_parameters_impulse_noise_detector.theta = st_parameters.impulseDetector_theta;

% load some parameters for the svm model
%     st_temp = load('svm_model_phat');

st_parameters_impulse_noise_detector.features_mean = st_temp.mean_X;%st_parameters.impulseDetector_features_mean;
st_parameters_impulse_noise_detector.features_std = st_temp.std_X;%st_parameters.impulseDetector_features_std;
st_parameters_impulse_noise_detector.svm_model = st_temp.model;
% st_parameters_impulse_noise_detector.p_threshold = p_threshold;%st_parameters.impulseDetector_p_threshold;
[p_impulsive_noise_overall, st_blocks] = detect_impulsive_noise_internal(st_parameters_impulse_noise_detector);