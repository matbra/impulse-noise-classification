function [p_impulsive_noise_overall, st_blocks, st_impulses] = detect_impulsive_noise(filename_input, T_block)

fs = 44100; % todo: unfix
% determine which svm model to load
% filename_model = ['svm_model_phat_' num2str(T_block) '_file'];
% filename_model = ['svm_model_product_' num2str(T_block) '_file'];

% T_safety_gap = 20e-3;
T_safety_gap = 50e-3;
L_safety_gap = floor(T_safety_gap * fs); 
L_safety_gap = 2 * floor(L_safety_gap/2); % even
L_safety_gap_half = L_safety_gap / 2;
% if b_beat
% load the scaling and model parameters
st_settings = settings();

b_beat = true;

   switch T_block
        %     case {100e-3, 500e-3, 1, 5}
        %         state = warning('off', 'MATLAB:table:ModifiedVarnames');
        %         str_blocklength = sprintf('%05.0f', T_block*1000);
        %
        %         tab_preproc = readtable(['preproc_' str_blocklength '.csv'], 'Delimiter', ',');
        %         tab_preproc.Properties.RowNames = table2cell(tab_preproc(:,1));
        %         tab_preproc = tab_preproc(:, 2:end);
        %
        %         tab_model = readtable(['model_coefficients_' str_blocklength '.csv']);
        %         tab_model.Properties.RowNames = table2cell(tab_model(:,1));
        %         tab_model = tab_model(:, 2:end);
        %
        %         warning(state);
        %     case 100e-3
        %         tab_preproc = table([8.99996797058204;0.277272203654736;0.292402317201386;0.323488082670602;0.363261803321868;0.429638502524786;17.3254483439606;35.883243072155;0.766269344014304;0.259289144254588;8.99996797058204;17.3254483439606;72.5672962385049;3.64957015313699;0.259289144254588], [7.74084542589978;0.465023404350968;0.49849734378142;0.555635006527105;0.625306172383058;0.741388139860848;21.3036268754851;109.187057316411;2.42450374341639;0.070398199197716;7.74084542589978;21.3036268754851;191.864793701739;5.30567063823427;0.070398199197716], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
        %         tab_model = table([-1.89000546941045;-1.42746282946492;-1.88524888674047;-1.58910357457033;1.47163938369679;2.72961662117253;0.672685633277776;-0.104539411061508;-0.936855538333141;-2.91925356097244;0.0237251195097378;-1.42746282946492;-0.104539411061508;-4.30245302285788;2.71894097298263;0.0237251195097378], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
        %     case 500e-3
        %         tab_preproc = table([14.4397932212738;0.385344609622213;0.405063941584956;0.448393785206688;0.504804864365218;0.599020531253138;26.2954035708918;37.7552568171129;0.782880580182473;0.258767720015288;14.4397932212738;26.2954035708918;96.4902202635894;4.21340017464346;0.258767720015288], [10.3158362206253;0.389500031478171;0.415198955078241;0.468433963582229;0.535782559766512;0.646595644883877;23.0278871047912;84.004610249225;1.8481645226513;0.0526168708071747;10.3158362206253;23.0278871047912;185.314086909331;4.80073259903492;0.0526168708071747], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
        %         tab_model = table([-3.79136747607437;-3.04711819784827;-3.13597498199524;-1.51275336412611;0.463844822939784;1.59915945531146;2.32592572386223;2.71297334082623;-0.384206321312551;-6.56831170884172;0.264846392338031;-3.04711819784827;2.71297334082623;-1.22515506448526;-1.96675712307549;0.264846392338031], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
        case {1, 0.5, 0.1}
            
            tab_model = readtable(fullfile(st_settings.dir_signal_set, st_settings.dir_sub_result_tables, sprintf('model_%.0fms.csv', T_block*1000)), 'ReadRowNames', true);
            %tab_preproc = table([16.2183762942308;0.422677133098771;0.44383469833661;0.490539973711522;0.551880343416677;0.654583031110825;29.2291380949731;36.9678135119439;0.757203782726611;0.258088633613287;16.2183762942308;29.2291380949731;98.4106827790745;4.25351801909802;0.258088633613287], [10.9455019389239;0.377588240367187;0.401042249727533;0.451193856227633;0.516156669977757;0.623937459762912;23.6073976449109;76.544424121966;1.65895859859828;0.0482653365030244;10.9455019389239;23.6073976449109;178.439000952624;4.6366739680386;0.0482653365030244], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
            %tab_model = table([-8.30865047556389;3.33130644223582;-134.669144800226;34.251771431982;101.450975205309;55.5764210424874;-68.4686877025411;0.210675625779703;-21.7664473506991;-8.10336341980966;0.311551404861211;3.33130644223582;0.210675625779703;15.9266970581344;-4.72443497963182;0.311551404861211], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             tab_preproc = table([18.61761021;0.61527618;0.64616418;0.72069533;0.82789902;1.02836327;39.36713212;52.96427051;1.36101196;0.29478687;18.61761021;39.36713212;125.1297407;4.58721515;0.29478687], [1.32623564e+01;4.91858779e-01;5.22251880e-01;5.96267375e-01;7.05810507e-01;9.20347635e-01;3.48073202e+01;8.14911399e+01;2.23627234e+00;6.15901345e-02;1.32623564e+01;3.48073202e+01;1.75685859e+02;4.58862998e+00;6.15901345e-02], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
              
% 2
% tab_preproc = table([18.61761021;0.61527618;0.64616418;0.72069533;0.82789902;1.02836327;39.36713212;52.96427051;1.36101196;0.29478687;18.61761021;39.36713212;125.1297407;4.58721515;0.29478687], [1.32623564e+01;4.91858779e-01;5.22251880e-01;5.96267375e-01;7.05810507e-01;9.20347635e-01;3.48073202e+01;8.14911399e+01;2.23627234e+00;6.15901345e-02;1.32623564e+01;3.48073202e+01;1.75685859e+02;4.58862998e+00;6.15901345e-02], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});

%            tab_model = table([12.49940368;15.36848632;21.0793675;5.23952616;-11.57853522;-20.98831293;-28.86408464;-4.52543831;11.74537695;24.28577547;0.82171667;15.36848632;-4.52543831;-23.63175471;23.01404392;0.82171667], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});

% 3
% tab_preproc = table([ 12.52519138,   0.58029325,   0.60219586,   0.65409441,0.72547375,   0.84930944,  20.75725452,  14.16086099,0.43904731,   0.23143817,  12.52519138,  20.75725452,45.98357693,   2.70872144,   0.23143817]', [ 7.66444917e+00,   3.83948455e-01,   4.00425126e-01,4.39271920e-01,   4.93185506e-01,   5.88925464e-01,1.41418131e+01,   1.86760423e+01,   7.91074320e-01,2.94080825e-02,   7.66444917e+00,1.41418131e+01,6.47106672e+01,   2.26171517e+00,   2.94080825e-02]', 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
% tab_model = table([4.27436199, 5.97708412,   0.63766184, -10.12792296, -12.01961104,-7.73522886,   2.79977563,   7.65763721,  -4.00943698,3.63813702,  -2.64423469,   5.97708412,   7.65763721,-7.66213131,  20.98759732,  -2.64423469]', 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});

% below 40 db
% tab_preproc = table([18.91264575,    0.67591147,    0.71166116,    0.78949221,          0.89212441,    1.06632615,   40.59909222,  126.00127894,          2.15437088,    0.27118083,   18.91264575,   40.59909222,        241.52530203,    6.21585386,    0.27118083]', [1.77797766e+01,   6.56185275e-01,   7.11241040e-01,         8.14740912e-01,   9.43075158e-01,   1.15691014e+00,         5.46778502e+01,   3.66254781e+02,   5.18385937e+00,         9.01311203e-02,   1.77797766e+01,   5.46778502e+01,         5.74143632e+02,   9.28935210e+00,   9.01311203e-02]', 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
% tab_model = table([21.81711944, 9.13277104,  126.34439058,  -63.59848758,  -96.60488099,-42.19969507,   76.7962603 ,  -11.22679916,   73.07832283,          34.75294694,    1.31945075,    9.13277104,  -11.22679916,         -42.51131639,    1.60649416,    1.31945075]', 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});



       
%               1.32623564e+01,   4.91858779e-01,   5.22251880e-01,
%          5.96267375e-01,   7.05810507e-01,   9.20347635e-01,
%          3.48073202e+01,   8.14911399e+01,   2.23627234e+00,
%          6.15901345e-02,   1.32623564e+01,   3.48073202e+01,
%          1.75685859e+02,   4.58862998e+00,   6.15901345e-02])

%             tab_model = table([7.06773563;5.18059316;6.39713746;-1.39890596;-5.90193505;-4.70704359;-4.88658774;-1.62254648;-14.42061342;29.51598115;-5.02189998;5.18059316;-1.62254648;-42.39960115;52.94430823;-5.02189998], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
            
            
            %     case 5
            %         tab_preproc = table([20.4423614618683;0.521817426547863;0.547280972261771;0.604195946658906;0.679356532852811;0.805880478654729;36.5307310480151;37.7667487262347;0.775583825239835;0.257846382647033;20.4423614618683;36.5307310480151;104.686423533886;4.38071865780996;0.257846382647033], [12.4692003905936;0.400106042370724;0.423449014976749;0.474526107890689;0.541566731689088;0.654458305792473;26.1696574440991;71.1603994047818;1.55133763500584;0.0450707638439861;12.4692003905936;26.1696574440991;175.648903221388;4.53060930752208;0.0450707638439861], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
            %         tab_model = table([-5.28862494105276;0.104770115743164;-1.09379800612095;-0.987736924513298;-0.843340248941049;-0.735663136970062;-0.631026399364734;0.267538508268824;-1.01592455057336;-4.47368049208217;0.715963071171949;0.104770115743164;0.267538508268824;-1.84583018806065;-3.25649273411527;0.715963071171949], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
            
            
            %     case 50e-3;
            %         theta = [0.559701594878139;2.41507006771533];
            %         mean_X = [1;8.72713722910893];
            %         std_X = [0;7.02812772105692];
            %     case 100e-3
            %         tab_preproc = readtable('preproc_00100.csv', 'Delimiter', ',');
            %         tab_preproc.Properties.RowNames = table2cell(tab_preproc(:,1));
            %         tab_preproc = tab_preproc(:, 2:end);
            %
            %         tab_model = readtable('model_coefficients_00100.csv');
            %         tab_model.Properties.RowNames = table2cell(tab_model(:,1));
            %         tab_model = tab_model(:, 2:end);
            %
            %     case 500e-3
            %         tab_preproc = readtable('preproc_00500.csv', 'Delimiter', ',');
            %         tab_preproc.Properties.RowNames = table2cell(tab_preproc(:,1));
            %         tab_preproc = tab_preproc(:, 2:end);
            %
            %         tab_model = readtable('model_coefficients_00500.csv');
            %         tab_model.Properties.RowNames = table2cell(tab_model(:,1));
            %         tab_model = tab_model(:, 2:end);
        otherwise
            error('This block length is not supported.');
    end
% else
%     
%     switch T_block
%         %     case {100e-3, 500e-3, 1, 5}
%         %         state = warning('off', 'MATLAB:table:ModifiedVarnames');
%         %         str_blocklength = sprintf('%05.0f', T_block*1000);
%         %
%         %         tab_preproc = readtable(['preproc_' str_blocklength '.csv'], 'Delimiter', ',');
%         %         tab_preproc.Properties.RowNames = table2cell(tab_preproc(:,1));
%         %         tab_preproc = tab_preproc(:, 2:end);
%         %
%         %         tab_model = readtable(['model_coefficients_' str_blocklength '.csv']);
%         %         tab_model.Properties.RowNames = table2cell(tab_model(:,1));
%         %         tab_model = tab_model(:, 2:end);
%         %
%         %         warning(state);
%         %     case 100e-3
%         %         tab_preproc = table([8.99996797058204;0.277272203654736;0.292402317201386;0.323488082670602;0.363261803321868;0.429638502524786;17.3254483439606;35.883243072155;0.766269344014304;0.259289144254588;8.99996797058204;17.3254483439606;72.5672962385049;3.64957015313699;0.259289144254588], [7.74084542589978;0.465023404350968;0.49849734378142;0.555635006527105;0.625306172383058;0.741388139860848;21.3036268754851;109.187057316411;2.42450374341639;0.070398199197716;7.74084542589978;21.3036268754851;191.864793701739;5.30567063823427;0.070398199197716], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%         %         tab_model = table([-1.89000546941045;-1.42746282946492;-1.88524888674047;-1.58910357457033;1.47163938369679;2.72961662117253;0.672685633277776;-0.104539411061508;-0.936855538333141;-2.91925356097244;0.0237251195097378;-1.42746282946492;-0.104539411061508;-4.30245302285788;2.71894097298263;0.0237251195097378], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%         %     case 500e-3
%         %         tab_preproc = table([14.4397932212738;0.385344609622213;0.405063941584956;0.448393785206688;0.504804864365218;0.599020531253138;26.2954035708918;37.7552568171129;0.782880580182473;0.258767720015288;14.4397932212738;26.2954035708918;96.4902202635894;4.21340017464346;0.258767720015288], [10.3158362206253;0.389500031478171;0.415198955078241;0.468433963582229;0.535782559766512;0.646595644883877;23.0278871047912;84.004610249225;1.8481645226513;0.0526168708071747;10.3158362206253;23.0278871047912;185.314086909331;4.80073259903492;0.0526168708071747], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%         %         tab_model = table([-3.79136747607437;-3.04711819784827;-3.13597498199524;-1.51275336412611;0.463844822939784;1.59915945531146;2.32592572386223;2.71297334082623;-0.384206321312551;-6.56831170884172;0.264846392338031;-3.04711819784827;2.71297334082623;-1.22515506448526;-1.96675712307549;0.264846392338031], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%         case 1
%             %tab_preproc = table([16.2183762942308;0.422677133098771;0.44383469833661;0.490539973711522;0.551880343416677;0.654583031110825;29.2291380949731;36.9678135119439;0.757203782726611;0.258088633613287;16.2183762942308;29.2291380949731;98.4106827790745;4.25351801909802;0.258088633613287], [10.9455019389239;0.377588240367187;0.401042249727533;0.451193856227633;0.516156669977757;0.623937459762912;23.6073976449109;76.544424121966;1.65895859859828;0.0482653365030244;10.9455019389239;23.6073976449109;178.439000952624;4.6366739680386;0.0482653365030244], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             %tab_model = table([-8.30865047556389;3.33130644223582;-134.669144800226;34.251771431982;101.450975205309;55.5764210424874;-68.4686877025411;0.210675625779703;-21.7664473506991;-8.10336341980966;0.311551404861211;3.33130644223582;0.210675625779703;15.9266970581344;-4.72443497963182;0.311551404861211], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             
%             % 2
%             %tab_preproc = table([18.32206204;0.7288149;0.76438359;0.8469709;0.96178259;1.16676466;36.38276679;64.72665266;1.84816928;0.27260706;18.32206204;36.38276679;160.1035969;5.95295537;0.27260706], [1.18361215e+01;5.91792216e-01;6.28303387e-01;7.13317824e-01;8.34848427e-01;1.06209624e+00;2.99397328e+01;9.16524547e+01;2.78715173e+00;7.50875772e-02;1.18361215e+01;2.99397328e+01;2.03161178e+02;5.84039937e+00;7.50875772e-02], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             
%             %tab_model = table([7.06773563;5.18059316;6.39713746;-1.39890596;-5.90193505;-4.70704359;-4.88658774;-1.62254648;-14.42061342;29.51598115;-5.02189998;5.18059316;-1.62254648;-42.39960115;52.94430823;-5.02189998], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             
%             % 3
% %             tab_preproc = table([13.22136684,   0.64197913,   0.66783868,   0.72840524,  0.81185621,   0.95775586,  22.88323015,  20.18962299,0.68221789,   0.24187058,  13.22136684,  22.88323015,60.22934757,   3.32591911,   0.24187058]', [  7.60306592e+00,   4.22352649e-01,   4.42577310e-01, 4.89580972e-01,   5.55251350e-01,   6.73919248e-01,1.55189643e+01,   2.71885852e+01,   1.14618145e+00,4.16550576e-02,   7.60306592e+00,   1.55189643e+01,8.16458864e+01,   2.96790452e+00,   4.16550576e-02]', 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
% %             tab_model = table([4.92806641,9.52228843,50.46614037,-44.63572901,-61.18246925,-23.99633569,54.33975652,2.26819401,7.46876141,6.22782534,-4.82638174,   9.52228843,   2.26819401,       -30.85618257,  38.37628708,  -4.82638174]', 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             
%             % 4 below 40dB
%             tab_preproc = table([19.89430927,    0.91933308,    0.98057178,    1.10302091,          1.25961774,    1.52230293,   48.60072664,  148.78710259,          2.7855409 ,    0.29407252,   19.89430927,   48.60072664,        250.81793614,    7.21718366,    0.29407252]', [  1.73199793e+01,   1.14099146e+00,   1.26962352e+00,         1.47910924e+00,   1.72327945e+00,   2.11856734e+00,         6.76060408e+01,   3.59049586e+02,   5.83596847e+00,         1.16599566e-01,   1.73199793e+01,   6.76060408e+01,         4.94615001e+02,   9.69435143e+00,   1.16599566e-01]', 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             tab_model = table([30.34196665, 5.27703939,  92.82648695, -25.49291971, -63.46307202,        -35.27272423,  30.24688738,  -6.44152563,  72.55808338,         45.14544287,   1.12681945,   5.27703939,  -6.44152563,        -46.75522471,   6.124925  ,   1.12681945]', 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
% 
%             % 5 - below 50 dB
% %             tab_preproc = table([18.3997677 ,    0.82893444,    0.8824558 ,    0.99026988,1.12854478,    1.36061307,   43.54999824,  125.46034867,          2.33351612,    0.2845912 ,   18.3997677 ,   43.54999824,        212.90213148,    6.37122355,    0.2845912 ]', [  1.63381409e+01,   1.06506688e+00,   1.18348341e+00,1.37745550e+00,   1.60422148e+00,   1.97183776e+00,         6.29079780e+01,   3.31968583e+02,   5.42442955e+00,         1.09420914e-01,   1.63381409e+01,   6.29079780e+01,         4.59916170e+02,   9.07459447e+00,   1.09420914e-01]', 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
% %             tab_model = table([22.88778984, 5.06349329,  85.65501779, -25.31103672, -64.06607924,        -33.28865087,  34.73513846,  -7.55751992,  70.15074404,         34.53386704,   0.66422069,   5.06349329,  -7.55751992,        -47.0558026 ,  10.42155782,   0.66422069]', 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
% 
%             
%           
% 
%             
%             %     case 5
%             %         tab_preproc = table([20.4423614618683;0.521817426547863;0.547280972261771;0.604195946658906;0.679356532852811;0.805880478654729;36.5307310480151;37.7667487262347;0.775583825239835;0.257846382647033;20.4423614618683;36.5307310480151;104.686423533886;4.38071865780996;0.257846382647033], [12.4692003905936;0.400106042370724;0.423449014976749;0.474526107890689;0.541566731689088;0.654458305792473;26.1696574440991;71.1603994047818;1.55133763500584;0.0450707638439861;12.4692003905936;26.1696574440991;175.648903221388;4.53060930752208;0.0450707638439861], 'VariableNames', {'preProc_mean', 'preProc_std'}, 'RowNames', {'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             %         tab_model = table([-5.28862494105276;0.104770115743164;-1.09379800612095;-0.987736924513298;-0.843340248941049;-0.735663136970062;-0.631026399364734;0.267538508268824;-1.01592455057336;-4.47368049208217;0.715963071171949;0.104770115743164;0.267538508268824;-1.84583018806065;-3.25649273411527;0.715963071171949], 'VariableNames', {'lrFit_finalModel_coefficients'}, 'RowNames', {'Intercept', 'peak2rms', 'peak2trimmedrms_1', 'peak2trimmedrms_2', 'peak2trimmedrms_5', 'peak2trimmedrms_10', 'peak2trimmedrms_20', 'peak2rmeds', 'kurtosis', 'skewness', 'sparseness', 'peak2rms_abs', 'peak2rmeds_abs', 'kurtosis_abs', 'skewness_abs', 'sparseness_abs'});
%             
%             
%             %     case 50e-3;
%             %         theta = [0.559701594878139;2.41507006771533];
%             %         mean_X = [1;8.72713722910893];
%             %         std_X = [0;7.02812772105692];
%             %     case 100e-3
%             %         tab_preproc = readtable('preproc_00100.csv', 'Delimiter', ',');
%             %         tab_preproc.Properties.RowNames = table2cell(tab_preproc(:,1));
%             %         tab_preproc = tab_preproc(:, 2:end);
%             %
%             %         tab_model = readtable('model_coefficients_00100.csv');
%             %         tab_model.Properties.RowNames = table2cell(tab_model(:,1));
%             %         tab_model = tab_model(:, 2:end);
%             %
%             %     case 500e-3
%             %         tab_preproc = readtable('preproc_00500.csv', 'Delimiter', ',');
%             %         tab_preproc.Properties.RowNames = table2cell(tab_preproc(:,1));
%             %         tab_preproc = tab_preproc(:, 2:end);
%             %
%             %         tab_model = readtable('model_coefficients_00500.csv');
%             %         tab_model.Properties.RowNames = table2cell(tab_model(:,1));
%             %         tab_model = tab_model(:, 2:end);
%         otherwise
%             error('This block length is not supported.');
%     end
% end




% determine the size of the file
st_audioinfo = audioinfo(filename_input);

L_block = floor(T_block * st_audioinfo.SampleRate);
if mod(L_block, 2)
    L_block = L_block + 1; % make even
end
L_feed = L_block / 1;

% L_DFT = 2^nextpow2(L_block);
L_DFT = 1024;

% load the file
x = audioread(filename_input);

x_preprocessed = zeros(size(x));
fs_target = 192e3;


fs_target = 192e3;

T_fit = 0.1e-3;
L_fit = floor(T_fit * fs_target)+1;

lpc_order = 10;

% if b_beat
%     % load the beat positions from file
%     c_temp = regexp(filename_input, '^(?<path>.*)/(?<basename>.*).(wav)$', 'tokens');
%     
%     path = c_temp{1}{1};
%     basename = c_temp{1}{2};
%     extension = c_temp{1}{3};
%     
%     st_temp = load(fullfile(path, [basename '_beats-00100ms-times1.mat']));
%     
%     c_beat_detection_result  = st_temp.c_beat_detection_result;
%     
%     idx_beats = [c_beat_detection_result.st_beat_info.sample_pos];
% else
%     idx_beats = [];
% end

% run the beat detector
T_peak_search_region = 100e-3;
tempo_multiplier = 1;
st_beat_detection_result = detect_beats(x, fs, T_peak_search_region, tempo_multiplier);
idx_beats = [st_beat_detection_result.st_beat_info.sample_pos];

vec_window = sqrt(hanning(L_DFT,'periodic'));

% st_audioinfo.NumChannels = 1;

% preprocessing
detectorsignal_mode = 'phat';
switch(detectorsignal_mode)
    case 'phat'
        for a = 1 : st_audioinfo.NumChannels;
            mat_X = spectrogram(x(:,a),vec_window,L_DFT/2,L_DFT,st_audioinfo.SampleRate,'yaxis');
            %                     Data_log = 20*log10(abs(mat_X)+eps);
            
            % this is the phat-transform:
            x_temp = ispecgram((ones(size(mat_X)).*exp(j*angle(mat_X))), L_DFT,st_audioinfo.SampleRate);
            x_preprocessed(1:length(x_temp), a) = x_temp;
        end
        %                 case 'ar'
        %                     tDeClick = ar_error(DataIn, 16, 1024);
        %                 case 'product_1'
        %                     [Data,FreqVek,TimeVek] = spectrogram(InternalData,sqrt(hanning(FFT_Len,'periodic')),FFT_Len/2,FFT_Len,fs,'yaxis');
        %                     Data_log = 20*log10(abs(Data)+eps);
        %
        %                     % this is the phat-transform:
        %                     tDeClick = ispecgram((ones(size(Data_log)).*exp(j*angle(Data))), FFT_Len,fs);
        %
        %                     ar_err_sig = ar_error(DataIn, 16, 128); % NOTE: reduced the block size for the case of crackle (lots of clicks). this way, the ar-model seems to predict better...
        %
        %                     tDeClick = tDeClick .* ar_err_sig(1:length(tDeClick));
end

% x_preprocessed_resampled = resample(x, fs_target, st_audioinfo.SampleRate);
% if size(x_preprocessed_resampled, 2) > 1
%     x_preprocessed_resampled = x_preprocessed_resampled(:,2);
% end

L_x_preprocessed = length(x_preprocessed);

N_blocks = floor( (L_x_preprocessed - (L_block - L_feed)) / L_feed );

st_blocks = struct('idx_start', [], ...
    'idx_end', [], ...
    'idx_channel', [], ...
    'p_impulsive_noise', []);
st_blocks = repmat(st_blocks, N_blocks * st_audioinfo.NumChannels, 1); % TODO : multichannel

st_impulses = struct('idx_start', [], ...
    'idx_end', [], ...
    'idx_channel', [], ...
    'p_impulsive_noise', []);
% st_impulses = repmat(st_impulses, N_blocks * st_audioinfo.NumChannels, 1); % TODO : multichannel

for p = 1 : N_blocks
    idx_start = (p-1) * L_feed + 1;
    idx_end = (p-1) * L_feed + L_block;
    
    for a = 1 : st_audioinfo.NumChannels
        
        vec_b_valid = true(L_block, 1);
        
        idx_beats_in_cur_block = find(idx_beats >= idx_start & ...
            idx_beats <= (idx_start + L_block - 1));
        
        idx_relative_to_block_start = idx_beats(idx_beats_in_cur_block) - idx_start + 1;
        %         else
        %             idx_relative_to_block_start  = [];
        %         end
        
        for b = 1 : length(idx_relative_to_block_start)
            idx_beat = idx_relative_to_block_start(b);
            
            idx_start_clear = idx_beat - L_safety_gap_half;
            idx_start_clear = max(idx_start_clear, 1);
            idx_end_clear = idx_beat + L_safety_gap_half;
            idx_end_clear = min(idx_end_clear, L_block);
            
            vec_idx_clear = idx_start_clear : idx_end_clear;
            
            
            
            %             if false
            %             tDeClick(vec_idx_clear) = 0;%Data(vec_idx_clear, kk) .* vec_window;
            %             else
            vec_b_valid(vec_idx_clear) = false;
            %             end
        end
        
        % read a block from the audio file
        %     x_p = audioread(filename_input, [idx_start, idx_end]);
        x_preprocessed_p = x_preprocessed(idx_start:idx_end, a);
        
        if b_beat
            % remove invalid parts
            x_preprocessed_p = x_preprocessed_p(vec_b_valid);
        end
        
        st_features_p = compute_features(x_preprocessed_p);
        
        % pre-process the features
        st_features_p_preprocessed = struct();
        %         c_fieldnames_preproc = fieldnames(st_preproc);
        c_fieldnames_features = fieldnames(st_features_p);
        for b = 1 : length(c_fieldnames_features)
            cur_fieldname_feature = c_fieldnames_features{b};
            temp = deal(table2array(tab_model({cur_fieldname_feature}, {'mean', 'std'})));
            cur_mean = temp(1);
            cur_std = temp(2);
            st_features_p_processed.(cur_fieldname_feature) = ...
                (st_features_p.(cur_fieldname_feature) - cur_mean) / cur_std;
            %             for c = 1 : length(st_preproc)
            %                 if strcmp(cur_fieldname_feature, c_fieldnames_preproc{c})
            %                     st_features_p_preprocessed.(cur_fieldname) = ...
            %                         (st_features_p.(cur_fieldname) - st_preproc.(c_fieldnames_preproc{c})) / st_preproc.(c_fieldnames_preproc{c})
            %                 end
            %             end
        end
        
%         % determine the feature names
        
        % make a prediction for the current block
        X = struct2mat(st_features_p_processed, false, c_fieldnames_features)';
        X = [ones(size(X, 1), 1), X]';
        %         X = scale_features(X', mean_X, std_X);
        
        intercept = table2array(tab_model('intercept', 'coef'));
        
        theta = intercept;
        
        for b = 1 : length(c_fieldnames_features)
            theta(b+1, 1) = table2array(tab_model(c_fieldnames_features{b}, 'coef'));
        end
        
        
        
        h_theta_p = X' * theta;
        p_disturbed_p = sigmoid(h_theta_p);
        
        idx_write = (p-1) * st_audioinfo.NumChannels + a;
        st_blocks(idx_write).idx_start = idx_start;
        st_blocks(idx_write).idx_end = idx_end;
        st_blocks(idx_write).idx_channel = a;
        st_blocks(idx_write).p_impulsive_noise = p_disturbed_p;
    end
    
    %p / N_blocks
end

% process individual impulses
L_fit = 20;
m = 3;
theta = [0.260546720450068;-0.412345659627858;-0.96191935043976;1.23735870481068;-1.14542301819429;0.000594271922670567;8.24350370147618;6.78412821544139;2.82686420034407];
mean_X = [1;-0.0135879380051452;-0.0127472752196062;0.00880457362629873;-0.00577932130981608;1;-1.17490294243252;0.406679165563958;-0.0785379027367869];
std_X = [0;0.153540470007478;0.0970147004473844;0.10113678721246;0.0914892895799546;0;0.66419446442744;0.70090715305393;0.298633472285987];
idx_block_click = find([st_blocks.p_impulsive_noise] > 0.5);
N_block_click = length(idx_block_click);

N_impulses = 0;


if nargout == 3
    % load the impulse model
    st_impulse_model = load('impulse_model.mat');
    % st_impulse_model.mean_X = st_temp.mean
    
    for a = 1 : N_block_click
        idx_cur_block = idx_block_click(a);
        
        idx_start = st_blocks(idx_cur_block).idx_start;
        idx_end = st_blocks(idx_cur_block).idx_end;
        
        p_impulse = zeros(idx_end-idx_start, 1);
        
        p_impulse_best = 0;
        for b = 1 : (idx_end-idx_start)+1
            st_features = compute_impulse_model_features(x_preprocessed_resampled, idx_start+b-1, L_fit, lpc_order, fs_target);
            
            
            if isempty(st_features)
                warning('could not fit');
                b_fit = false;
            else
                b_fit = true;
            end
            
            
            
            p_impulse(b) = NaN; % if no fit was possible
            if b_fit
                % determine impulse probability
                %         p_impulse = 0;
                
                x = [st_features.T_attack_60, ...
                    st_features.T_decay_60, ...
                    st_features.decay_osc_ar_coeffs(2:end), ...
                    st_features.first_osc_delta_t, ...
                    st_features.first_osc_relative_amplitude];
                
                p_impulse(b) = st_impulse_model.fac_norm * mvnpdf([x], st_impulse_model.mean_X, st_impulse_model.cov_X);
            end
            
            
            if p_impulse(b) > p_impulse_best
                idx_start_best = b;
                p_impulse_best = max(p_impulse);
            end
            
        end
        
        st_blocks(idx_cur_block).p_impulse = p_impulse_best;% + b - 1;
        
        N_impulses = N_impulses + 1;
        st_impulses(N_impulses).idx_start = idx_start + idx_start_best - 1;% + b - 1;
        st_impulses(N_impulses).p_impulse = p_impulse_best;
        %             st_impulses(N_impulses).idx_end = idx_start + idx_start_best - 1 + L_fit;
        %                 %             st_impulses(N_impulses).idx_end = idx_start + idx_start_best - 1 + L_fit;
        %                 st_impulses(N_impulses).p_impulse = p_impulse_best;
        st_impulses(N_impulses).idx_end = idx_start + idx_start_best - 1 + L_fit;
        %             st_impulses(N_impulses).p_impulse = p_impulse_best
        
        %     for a = 1 : N_block_click
        %         idx_cur_block = idx_block_click(a);
        %         idx_start = st_blocks(idx_cur_block).idx_start;
        %         idx_end = st_blocks(idx_cur_block).idx_end;
        %         idx_channel = st_blocks(idx_cur_block).idx_channel;
        %         x_a = x(idx_start:idx_end, idx_channel);
        %
        %         x_a_enh = [x_a; x(idx_end+1:idx_end+L_fit-1, idx_channel)];
        %
        %         if any(~x_a_enh)
        %             continue;
        %         end
        %
        %         %     vec_e = zeros(length(x_a), 1);
        %         p_impulse_best = 0;
        %         vec_b_best = [];
        %         vec_a_best = [];
        %         idx_start_best = [];
        %         % fit the prony model
        %         b_within_impulse = false;
        %         for b = 1 : length(x_a)
        %             [vec_b, vec_a] = prony(x_a_enh(b:b+L_fit-1), m, m);
        %
        %             % apply logistic model for current sample
        %             theta = [0.260546720450068;-0.412345659627858;-0.96191935043976;1.23735870481068;-1.14542301819429;0.000594271922670567;8.24350370147618;6.78412821544139;2.82686420034407];
        %             h_theta = scale_features([1; vec_b'; vec_a'], mean_X, std_X)' * theta;
        %
        %             p_impulse = sigmoid(h_theta);
        %
        %             %         vec_p(b) = p_impulse;
        %             if p_impulse > p_impulse_best
        %                 % %             vec_b_best = vec_b;
        %                 % %             vec_a_best = vec_a;
        %                 p_impulse_best = p_impulse;
        %                 %             idx_start_best = b;
        %                 %         end
        %             end
        %
        %             if ~b_within_impulse && p_impulse > 0.5
        %
        %                 N_impulses = N_impulses + 1;
        %                 st_impulses(N_impulses).idx_start = idx_start + b - 1;% + b - 1;
        %                 %             st_impulses(N_impulses).idx_end = idx_start + idx_start_best - 1 + L_fit;
        %                 st_impulses(N_impulses).p_impulse = p_impulse_best;
        %                 %             break;
        %             elseif b_within_impulse && p_impulse < 0.5
        %                 st_impulses(N_impulses).idx_end = idx_start + b + L_fit - 1;
        %                 b_within_impulse = false;
        %
        %             end
        %         end
        
        %     if p_impulse_best > 0.5
        %
        %             N_impulses = N_impulses + 1;
        %             st_impulses(N_impulses).idx_start = idx_start + idx_start_best;% + b - 1;
        %             st_impulses(N_impulses).idx_end = idx_start + idx_start_best - 1 + L_fit;
        %             st_impulses(N_impulses).p_impulse = p_impulse_best;
        % %             break;
        %         end
    end
    
    a / N_block_click
end


p_impulsive_noise_overall = mean([st_blocks.p_impulsive_noise]);

% return;
%
%
%
%
% % st_temp = load(filename_model);
% % st_parameters = st_temp.st_parameters;
%
% % st_parameters_impulse_noise_detector.filename_input = filename_input;
% st_parameters_impulse_noise_detector.T_safety_gap = st_parameters.T_safety_gap;
% st_parameters_impulse_noise_detector.L_DFT = st_parameters.L_DFT;
% st_parameters_impulse_noise_detector.detectorsignal_mode = st_parameters.detectorsignal_mode;
% st_parameters_impulse_noise_detector.T_peak_search_region = st_parameters.T_peak_search_region;
% st_parameters_impulse_noise_detector.tempo_multiplier = st_parameters.tempo_multiplier;
% st_parameters_impulse_noise_detector.T_block = st_parameters.T_block;
% %     st_parameters_impulse_noise_detector.theta = st_parameters.impulseDetector_theta;
%
% % load some parameters for the svm model
% %     st_temp = load('svm_model_phat');
%
% st_parameters_impulse_noise_detector.features_mean = st_temp.mean_X;%st_parameters.impulseDetector_features_mean;
% st_parameters_impulse_noise_detector.features_std = st_temp.std_X;%st_parameters.impulseDetector_features_std;
% st_parameters_impulse_noise_detector.svm_model = st_temp.model;
% % st_parameters_impulse_noise_detector.p_threshold = p_threshold;%st_parameters.impulseDetector_p_threshold;
% [p_impulsive_noise_overall, st_blocks] = detect_impulsive_noise_internal(st_parameters_impulse_noise_detector);
