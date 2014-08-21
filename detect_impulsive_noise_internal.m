function [p_contains_impulsive_noise, st_blocks] = detect_impulsive_noise_internal(st_parameters)%, T_safety_gap, T_block, FFT_Len, detectorsignal_mode, T_peak_search_region, tempo_multiplier)
% function to do something usefull (fill out)
% Usage [out_param] = decideImpulseNoiseReducer(szFileIn, Threshold)
% Input Parameter:
%	 in_param: 		 Explain the parameter, default values, and units
% Output Parameter:
%	 out_param: 	 Explain the parameter, default values, and units
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J.Bitzer (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 15-Feb-2013  Initials (eg. JB)

%Das Ding ist noch suboptimal, da an den Grenzen etwas schief l�uft
%Im Moment werden die Daten nach vorne und hinten durch spiegeln erweitert aber eigentlich sollten bei mn n�chsten Block die Daten vom alten restaurierten Blok als input genommen werden.

%Es scheint keine gute iDee zu sein, Blockgrenzen hart zu verwenden, aer Fensterung ist auch nicht gut. Eigentlich m�sste im Signal etwas zur�ckgegangen werden, bis zum letzten NichtClick, um auf der sicheren Seite zu sein, dass der �bergang heile bleibt.


%------------Your function implementation here---------------------------
% bSuccess = 0;
% iNrOfIter = 4;

% switch nargin
%     case 0;
%         help(mfilename)
%     case 1;
%         Threshold= 10;
%     case 2;
%
%         if ischar(Threshold)
%             Threshold = str2double(Threshold);
%         end
% end

%szOut = sprintf('%s_tempOut.wav',szFileIn(1:end-4));

%szFinalOut = sprintf('%s_FinalOut.wav',szFileIn(1:end-4));

[FileInfo,fs,nbits] = wavread(st_parameters.filename_input,'size');
iLenOfSig = FileInfo(1);
iNrOfChns = FileInfo(2);

% iLenOfSig = 500000;

% iNrOfChns = 1;

[szPath,szFile] = fileparts(st_parameters.filename_input);

if isempty(szPath)
    szPath = '.';
end

% st_features = struct('peak2rms', [], ...
% 'peak2rmeds', [], ...
% 'acf_value', [], ...
% 'acf_delay', [], ...
% 'kurtosis', [], ...
% 'skewness', [], ...
% 'sparseness', [], ...
% 'peak2rms_validOnly', [], ...
% 'acf_value_validOnly', [], ...
% 'acf_delay_validOnly', [], ...
% 'kurtosis_validOnly', [], ...
% 'skewness_validOnly', [], ...
% 'sparseness_validOnly', []);
st_features = struct('st_values', [], 'st_info', []);
N_blocks = 0;


%% DeClicking

x = wavread(st_parameters.filename_input);
% x=x(1:500000, 1);
for kk = 1:iNrOfChns
    % create one declick-decider for each channel
    stAlgo(kk) = DeClick(fs, st_parameters.T_safety_gap, st_parameters.L_DFT, st_parameters.detectorsignal_mode);
    stAlgo(kk).init();
    
    % determine rhythmic transient positions
    
    c_beat_detection_result{kk} = detect_beats(x(:,kk), fs, st_parameters.T_peak_search_region, st_parameters.tempo_multiplier);
end

% the block length in seconds
MaxBlockLen_s = st_parameters.T_block;

% the block length in samples
MaxBlockLen = MaxBlockLen_s*fs;

iStartIndex = 1;
BlockCounter = 1;
%
% for a = 1 : iNrOfChns
%     for b = 1 : length(st_beat_detection_result(a).st_beat_info)
%         idx_beat = st_beat_detection_result(a).st_beat_info(b).sample_pos;
%
%     end
% end



% as long as the end of the next block is before the end of the file
while iStartIndex + MaxBlockLen <= iLenOfSig
     WaveData = wavread(st_parameters.filename_input,[iStartIndex iStartIndex+MaxBlockLen-1]);
    
    
    
    % store one decision per block and per channel
    for kk = 1 :iNrOfChns
        % find beats that have been detected within this block
        if isfield(c_beat_detection_result{kk}, 'st_beat_info') % added for 468_-_1978_-_Max_Berlin_-_Elle_Et_Moi_(She_And_I)
            idx_beats_in_cur_block = find([c_beat_detection_result{kk}.st_beat_info.sample_pos] >= iStartIndex & ...
                [c_beat_detection_result{kk}.st_beat_info.sample_pos] <= (iStartIndex + MaxBlockLen - 1));
            
            idx_relative_to_block_start = [c_beat_detection_result{kk}.st_beat_info(idx_beats_in_cur_block).sample_pos] - iStartIndex + 1;
        else
            idx_relative_to_block_start  = [];
        end
        
        
        
        
         [bDecision, st_features_p] = stAlgo(kk).process(WaveData(:,kk),0, idx_relative_to_block_start);
        N_blocks = N_blocks + 1;
%         DecisionMatrix(BlockCounter,kk) = bDecision;
        st_features(N_blocks).st_values = st_features_p;
        st_features(N_blocks).st_info.idx_start = iStartIndex;
        st_features(N_blocks).st_info.idx_end = iStartIndex+MaxBlockLen-1;
        st_features(N_blocks).st_info.idx_channel = kk;
        
        st_blocks(N_blocks).idx_start = iStartIndex;
        st_blocks(N_blocks).idx_end = iStartIndex + MaxBlockLen-1;
        st_blocks(N_blocks).idx_channel = kk;
    end
    
    iStartIndex = iStartIndex+MaxBlockLen;
    
    BlockCounter = BlockCounter + 1;
end

% Final Block (or whole block if shorter than MaxBlockLen )
WaveData = wavread(st_parameters.filename_input,[iStartIndex iLenOfSig]);

% cut away parts of the data that don't contain tempo information
% Data = Data(1:st_beat_detection_result.st_global_info.idx_end_analyse-iStartIndex);
% iLenOfSig = st_beat_detection_result.st_global_info.idx_end_analyse;

for kk = 1 :iNrOfChns
    % find beats that have been detected within this block
    iLenOfSig = c_beat_detection_result{kk}.st_global_info.idx_end_analyse;
    if isfield(c_beat_detection_result{kk}, 'st_beat_info')
        idx_beats_in_cur_block = find([c_beat_detection_result{kk}.st_beat_info.sample_pos] >= iStartIndex & ...
            [c_beat_detection_result{kk}.st_beat_info.sample_pos] <= (iStartIndex + iLenOfSig - 1));
        
        idx_relative_to_block_start = [c_beat_detection_result{kk}.st_beat_info(idx_beats_in_cur_block).sample_pos] - iStartIndex + 1;
    else
        idx_relative_to_block_start = [];
    end
    
    temp_data = WaveData(1:c_beat_detection_result{kk}.st_global_info.idx_end_analyse-iStartIndex, kk);
    
    [bDecision, st_features_p] = stAlgo(kk).process(temp_data,0, idx_relative_to_block_start);
    if ~isempty(bDecision) % added by m.brandt for ID3_Eagles.wav
        DecisionMatrix(BlockCounter,kk) = bDecision;
        N_blocks = N_blocks + 1;
        st_features(N_blocks).st_values = st_features_p;
        st_features(N_blocks).st_info.idx_start = iStartIndex;
        st_features(N_blocks).st_info.idx_end = iLenOfSig;
        st_features(N_blocks).st_info.idx_channel = kk;
        
        st_blocks(N_blocks).idx_start = iStartIndex;
        st_blocks(N_blocks).idx_end = iLenOfSig;
        st_blocks(N_blocks).idx_channel = kk;
    end
end

st_features = [st_features.st_values];

st_features = compute_additional_features(st_features);

[mat_features, idx_valid] = struct2mat(st_features, false);

% mat_features = [abs([st_features.peak2rmeds_validOnly]').^(1), abs([st_features.kurtosis_validOnly]').^1, ...
%     [st_features.skewness]', [st_features.peak2rms_validOnly]', [st_features.peak2rmeds_validOnly]'./[st_features.peak2rmeds]', ...
%     [[st_features.L4_validOnly]./[st_features.L2_validOnly]]', [[st_features.L5_validOnly]./[st_features.L3_validOnly]]'];

% mat_features = [[st_features.L4_validOnly]./[st_features.L2_validOnly]; [st_features.L5_validOnly]./[st_features.L3_validOnly]]';

% mat_features = gen_quadratic_features(mat_features', 2)';

% mat_features = [([st_features.acf_value]').^(1/2), abs([st_features.skewness]').^(1/2)];

% mat_values_with = [abs([st_features_with.skewness]') .* [st_features [st_features_with.kurtosis]'];
% mat_values_without = [abs([st_features_without.skewness]') [st_features_without.kurtosis]'];

% vec_b_with = vec_target == 1;
% 
% idx_with = find(vec_b_with);
% idx_without = find(~vec_b_with);
% 
% if false
%     mat_features = gen_quadratic_features(mat_features');
% end

mat_features = [ones(1, size(mat_features, 2)); mat_features];

% figure;plot(DecisionMatrix);

% st_all_featurs = [st_features.st_values];

% combine all blocks features into a matrix
% mat_features = [abs([st_all_featurs.peak2rmeds_validOnly]').^(1), abs([st_all_featurs.kurtosis_validOnly]').^1, ...
%      [st_all_featurs.skewness_validOnly]', [st_all_featurs.peak2rms_validOnly]', ...
%      [[st_all_featurs.L4_validOnly]./([st_all_featurs.L2_validOnly]+1e-6)]', [[st_all_featurs.L5_validOnly]./([st_all_featurs.L3_validOnly] + 1e-6)]'];

% mat_features = gen_quadratic_features(mat_features, 3);

% add bias feature
% mat_features = [ones(N_blocks, 1), mat_features];

% scale features
mat_features = scale_features(mat_features, st_parameters.features_mean, st_parameters.features_std);

% h_theta = sigmoid(mat_features' * st_parameters.theta);

% h_theta_mean = mean(h_theta);

[predicted_label, accuracy, decision_values] = svmpredict(ones(size(mat_features, 2),1), mat_features', st_parameters.svm_model, '-b 1');

p_contains_impulsive_noise = decision_values(:, find(st_parameters.svm_model.Label == 1));

for a = 1 : length(idx_valid);
    st_blocks(idx_valid(a)).p_impulsive_noise = p_contains_impulsive_noise(a);
    
    
    % TODO: take care with the channel!
end

p_contains_impulsive_noise = mean(p_contains_impulsive_noise);

% b_contains_impulse_noise = mean(p_contains_impulsive_noise) >= st_parameters.p_threshold;
% if st_parameters.svm_model.Label(1) == 0
%     b_contains_impulse_noise = mean(decision_values) < 0;
% else
%     b_contains_impulse_noise = mean(decision_values) > 0;
% end

% p_contains_impulse_noise = NaN;%h_theta_mean;

%bDecision = median(DecisionMatrix(:,1));
% bDecision = median(DecisionMatrix(:));
% bDecision = ceil(bDecision);


% bSuccess = bDecision
% writeXMLfile;



    function writeXMLfile
        %% XML file output
        iXMLfid = fopen([szPath filesep szFile '.xml'],'w');
        
        % Preamble
        fprintf(iXMLfid, [ ...
            '<?xml version="1.0" encoding="utf-8"?>\n' ...
            '<!-- This XML file contains some audio specific information-->\n']);
        fprintf(iXMLfid,'<CreationDate>%s</CreationDate>\n', datestr(now, 30));
        fprintf(iXMLfid,'<File>\n');
        fprintf(iXMLfid,'\t<Name>%s</Name>\n',szFile);
        fprintf(iXMLfid,'\t<DecideImpulseRemove>\n');
        
        % Settings block
        fprintf(iXMLfid,[...
            '\t\t<Settings>\n' ...
            '\t\t\t<Threshold>%.4f</Threshold>\n' ...
            '\t\t</Settings>\n' ...
            ], ...
            Threshold);
        
        % Data block
        fprintf(iXMLfid, [ ...
            '\t\t<Data>\n' ...
            '\t\t\t<bDoRemoveImpulses>%i</bDoRemoveImpulses>\n' ...
            ], ...
            bDecision);
        
        % Postamble
        fprintf(iXMLfid,'\t\t</Data>\n');
        fprintf(iXMLfid,'\t</DecideImpulseRemove>\n');
        fprintf(iXMLfid,'</File>\n');
        
        fclose(iXMLfid);
        
    end

    function stAlgo = DeClick(fs, T_safety_gap, FFT_Len, detectorsignal_mode)
        
%         if (nargin < 2)
%             DetectThresh = 10;
%         end
%         DetectThresh = DetectThreshNew;
        stAlgo.init = @init;
        stAlgo.process = @process;
        
        % some parameters for beat-related impulse removal
        % T_safety_gap = 1e-1; % sec
        L_safety_gap = floor(T_safety_gap * fs);
        L_safety_gap_half = floor(L_safety_gap / 2);
        L_safety_gap = 2 * L_safety_gap_half + 1; % is odd now
        % vec_window = 1 - hann(L_safety_gap, 'symmetric');
        
        % detectorsignal_mode = detectorsignal_mode;
        
        m_fs = fs;
        % FFT_Len = 1024*4;
        
        TempMem = [];
        
        function init()
        end
        
        function [bDecision, st_features] = process(DataIn,Mode, idx_beats)
            % 4 Modi = 0  first Block repition
            %        = 1  first Block last repition
            %        = 2  inbetween blocks repition
            %        = 3  inbetween block last repition
            
            %         % copy input if input block is to small
            if (length(DataIn) < FFT_Len)
                % the input data is too short
                %             DataOut = DataIn;
                bDecision = [];
                st_features = [];
                return;
            end
            %
            %         if (Mode == 0 || Mode == 1) % first Block
            %             TempMem = DataIn(BlockStartNoClickDetect+1:-1:1);
            %             TempMemOut = DataIn(end:-1:end-BlockEndNoClickDetect-1);
            %             InternalData = [TempMem; DataIn ; TempMemOut];
            %         else
            %             TempMemOut = DataIn(end:-1:end-BlockEndNoClickDetect-1);
            %             InternalData = [TempMem; DataIn; TempMemOut];
            %         end
            
            b_compress = false;
            if b_compress
                DataIn = sign(DataIn) .* sqrt(abs(DataIn));
            end
            
            InternalData = DataIn;
            % Generate DetectorSignal
            
            switch(detectorsignal_mode)
                case 'phat'
                    [Data,FreqVek,TimeVek] = spectrogram(InternalData,sqrt(hanning(FFT_Len,'periodic')),FFT_Len/2,FFT_Len,fs,'yaxis');
                    Data_log = 20*log10(abs(Data)+eps);
                    
                    % this is the phat-transform:
                    tDeClick = ispecgram((ones(size(Data_log)).*exp(j*angle(Data))), FFT_Len,fs);
                case 'ar'
                    tDeClick = ar_error(DataIn, 16, 1024);
                case 'product_1'
                    [Data,FreqVek,TimeVek] = spectrogram(InternalData,sqrt(hanning(FFT_Len,'periodic')),FFT_Len/2,FFT_Len,fs,'yaxis');
                    Data_log = 20*log10(abs(Data)+eps);
                    
                    % this is the phat-transform:
                    tDeClick = ispecgram((ones(size(Data_log)).*exp(j*angle(Data))), FFT_Len,fs);
                    
                    ar_err_sig = ar_error(DataIn, 16, 128); % NOTE: reduced the block size for the case of crackle (lots of clicks). this way, the ar-model seems to predict better...
                    
                    tDeClick = tDeClick .* ar_err_sig(1:length(tDeClick));
            end
            
            
            if b_compress
                tDeClick = sign(tDeClick) .* tDeClick.^2;
            end
            
            vec_b_valid = true(length(tDeClick), 1);
            
            for a = 1 : length(idx_beats)
                idx_beat = idx_beats(a);
                
                idx_start_clear = idx_beat - L_safety_gap_half;
                idx_start_clear = max(idx_start_clear, 1);
                idx_end_clear = idx_beat + L_safety_gap_half;
                idx_end_clear = min(idx_end_clear, length(tDeClick));
                
                vec_idx_clear = idx_start_clear : idx_end_clear;
                
                
                
                if false
                    tDeClick(vec_idx_clear) = 0;%Data(vec_idx_clear, kk) .* vec_window;
                else
                    vec_b_valid(vec_idx_clear) = false;
                end
            end
            
            if false
                figure(10);
                plot(tDeClick);
                hold on;
                plot(find(~vec_b_valid), tDeClick(~vec_b_valid), 'r');
                hold off;
            end
            
            if false
                figure(1);
                plot([InternalData(1:length(tDeClick)) tDeClick-0.5])
            end
            
            [xc,lags] = xcorr(tDeClick(vec_b_valid),tDeClick(vec_b_valid),'coeff');
            
            idx = lags>5000;
            
            %figure;plot(lags(idx),xc(idx));
            
            if false%b_removeNoise
                th = 3 * var(tDeClick.^(1/2));
                %             vec_b_valid = vec_b_valid & abs(tDeClick)>th;
                tDeClick(abs(tDeClick)<th) = 0;
            end
            
            [MaxData,MaxIdx] = max(abs(xc(idx)));
            %         kurData = kurtosis(tDeClick);
            %         kurCorr = kurtosis(xc(idx));
            cf =  peak2rms(tDeClick(vec_b_valid));
            
            [xc_all,lags] = xcorr(tDeClick,tDeClick,'coeff');
            idx_all = lags>5000;
            [MaxData_all, MaxIdx_all] = max(abs(xc_all(idx_all)));
            
            st_features.peak2rms = peak2rms(tDeClick);
            st_features.peak2rmeds = peak2rmeds(tDeClick);
            st_features.acf_value = MaxData_all;
            st_features.acf_delay = (MaxIdx_all+4999) / fs;
            st_features.kurtosis = kurtosis(tDeClick);
            st_features.skewness = skewness(tDeClick);
            st_features.sparseness = sparseness(tDeClick);
            
            st_features.peak2rms_validOnly = cf;
            st_features.peak2rmeds_validOnly = peak2rmeds(tDeClick(vec_b_valid));
            st_features.acf_value_validOnly = MaxData;
            st_features.acf_delay_validOnly = (MaxIdx+4999) / fs;
            st_features.kurtosis_validOnly = kurtosis(tDeClick(vec_b_valid));
            st_features.skewness_validOnly = skewness(tDeClick(vec_b_valid));
            st_features.sparseness_validOnly = sparseness(tDeClick(vec_b_valid));
            
            % compute l-moments
            vec_lmom = lmom(tDeClick, 5);
            st_features.L1 = vec_lmom(1);
            st_features.L2 = vec_lmom(2);
            st_features.L3 = vec_lmom(3);
            st_features.L4 = vec_lmom(4);
            st_features.L5 = vec_lmom(5);
            
            vec_lmom_validOnly = lmom(tDeClick(vec_b_valid), 5);
            st_features.L1_validOnly = vec_lmom_validOnly(1);
            st_features.L2_validOnly = vec_lmom_validOnly(2);
            st_features.L3_validOnly = vec_lmom_validOnly(3);
            st_features.L4_validOnly = vec_lmom_validOnly(4);
            st_features.L5_validOnly = vec_lmom_validOnly(5);
            
            %        if kurData > DetectThresh && MaxData < 0.015
            %if cf > DetectThresh && MaxData < th_corr
            %    bDecision = 1;
            %else
            %    bDecision = 0;
            %end
            bDecision = -1; % anyway - we don't use that here...
            
            % not used in original (bitzer) version
            %         % Remove the artificial added audio
            %         DataOut(1:length(TempMem)) = [];
            %         DataOut(length(DataIn)+1:end) = [];
            %         if (Mode == 1 || Mode == 3)
            %             TempMem = DataOut(end-BlockStartNoClickDetect-1:end);
            %         end
        end
    end
%
%
%
% %figure;pwelch(aa,FFT_Len,FFT_Len/2,FFT_Len,fs);
%
% [Data,FreqVek,TimeVek] = spectrogram(aa,sqrt(hanning(FFT_Len,'periodic')),FFT_Len/2,FFT_Len,fs,'yaxis');
% Data_log = 20*log10(abs(Data)+eps);
% tDeClick = ispecgram((ones(size(Data_log)).*exp(j*angle(Data))), FFT_Len,fs);
%
% % Hier Loesung um Pitch zu sch�tzen beim DeClicken
% % % Idee hier �ber Tiefpass und percentile und dann Pitch suchen
% %
% % fgrenz = 3000;
% % idx = find(FreqVek > fgrenz,1,'first');
% % DataLP = Data;
% % DataLP(idx:end,:) = 0;
% % t_low = ispecgram((ones(size(Data_log)).*exp(j*angle(DataLP))), FFT_Len,fs);
% %
% % figure;
% % plot(t);
% % hold on;
% % plot(t_low,'r');
% % pause;
%
%
% % Automatic DeClicking
%
% idx = find(abs(tDeClick)>DetectThresh);
%
%
% %PreLen = 15;
% %PostLen = 25;
% PreLen = 25;
% PostLen = 125;
% ArOrdnung = (PostLen+PreLen)*8;
%
% BlockStartNoClickDetect = 2*ArOrdnung+PreLen;
% BlockEndNoClickDetect = 2*ArOrdnung+PostLen + FFT_Len;
%
% idxNoClick = idx < BlockStartNoClickDetect;
% if ~isempty(idxNoClick)
%     idx(idxNoClick) = [];
% end
%
% idxNoClick = idx > size(aa,1) - BlockEndNoClickDetect;
% if ~isempty(idxNoClick)
%     idx(idxNoClick) = [];
% end
%
%
% detectDeClick = zeros(size(tDeClick));
% detectDeClick(idx) = 1;
%
% for tt = -PreLen:PostLen
%     detectDeClick(idx+tt)= 1;
% end
% StartEnd = diff(detectDeClick);
% idxStart = find(StartEnd == 1);
% idxEnd = find(StartEnd == -1);
%
% if (~isempty(idxNoClick))
%     if (length(idxEnd)>1)
%         LastClickPos = idxEnd(end-1)-BlockStartNoClickDetect;
%     else
%         LastClickPos = idxEnd(end)-BlockStartNoClickDetect;
%     end
% else
%     LastClickPos = size(aa,1)-BlockStartNoClickDetect;
% end
%
% if (length(idxStart) ~= length(idxEnd))
%     error('Hier stimmt was nicht');
% end
%
%
%
%
% for kk = 1:length(idxStart)
%     %pos = idx(kk);
%
%     InterpolStart = idxStart(kk)-2*ArOrdnung+1;
%     if InterpolStart < 0
%         continue;
%     end
%     InterpolEnd = idxEnd(kk)+2*ArOrdnung+1;
%     if InterpolEnd> length(aa)
%         continue;
%     end
%     signal = aa(InterpolStart:InterpolEnd);
%     GapStart = 2*ArOrdnung+1;
%     GapEnd = 2*ArOrdnung+1+idxEnd(kk)-idxStart(kk);
%
%     signal1 = InterpolatorKappaunen(signal,GapStart, GapEnd,2*ArOrdnung);
%     %    signal2 = InterpolatorKappaunen(signal1,GapStart, GapEnd,2*ArOrdnung);
%     %    signal3 = InterpolatorKappaunen(signal2,GapStart, GapEnd,2*ArOrdnung);
%     aa(InterpolStart:InterpolEnd) = signal1;
% end
%
    function signalOut = InterpolatorKappaunen(signal,...
            GapStart,...
            GapEnd, ArOrdnung)
        
        signalOut = signal;
        
        GapLen   = GapEnd - GapStart+1;
        
        ArCoeffs = aryule(signal.*hanning(length(signal)), ArOrdnung);
        
        % get initial coefficients for filter
        % elements near the gap are considered as newer
        zPre  = filtic(1,ArCoeffs,signal((GapStart-1)-(0:(ArOrdnung-1))));
        zPost = filtic(1,ArCoeffs,signal(GapEnd+1:GapEnd+ArOrdnung));
        
        
        % filter zeros with impulse calculated impulse response
        extraSigPre  = filter(1,ArCoeffs,zeros(1,GapLen),zPre);
        extraSigPost = fliplr(filter(1,ArCoeffs,zeros(1,GapLen),zPost));
        
        
        % crossfade backward and forward extrapolation
        xfadeWin  = linspace(0,1,GapLen);
        xfadeSig  =  extraSigPre.*(1-xfadeWin) + extraSigPost.*xfadeWin;
        %xfadeWin  = linspace(0,pi/2,GapLen);
        %xfadeSig  =  extraSigPre.*cos(xfadeWin) + extraSigPost.*sin(xfadeWin);
        
        
        signalOut(GapStart:GapEnd) = xfadeSig ;
        
        debugPlot = 0;
        
        if debugPlot
            figure;
            plot(signal);
            hold on;
            plot(signalOut,'r');
            plot([GapStart:GapEnd],extraSigPre,'g');
            plot([GapStart:GapEnd],extraSigPost,'k');
            
            pause;
        end
    end
    function x = ispecgram(d, ftsize, sr, win, nov)
        % X = ispecgram(D, F, SR, WIN, NOV)           Inverse specgram
        %    Overlap-add the inverse of the output of specgram
        %    ftsize is implied by sizeof d, sr is ignored, nov defaults to ftsize/2
        % dpwe 2005may16.  after istft
        
        [nspec,ncol] = size(d);
        
        if nargin < 2
            ftsize = 2*(nspec-1);
        end
        if nargin < 3
            % who cares?
        end
        if nargin < 4
            win = ftsize;  % doesn't matter either - assume it added up OK
        end
        if nargin < 5
            nov = ftsize/2;
        end
        
        hop = win - nov;
        
        if nspec ~= (ftsize/2)+1
            error('number of rows should be fftsize/2+1')
        end
        
        window = sqrt(hanning(ftsize,'periodic'));
        
        xlen = ftsize + (ncol-1) * hop;
        x = zeros(xlen,1);
        
        halff = ftsize/2;   % midpoint of win
        
        % No reconstruction win (for now...)
        
        for c = 1:ncol
            ft = d(:,c);
            ft = [ft(1:(ftsize/2+1)); conj(ft([(ftsize/2):-1:2]))];
            
            if max(imag(ifft(ft))) > 1e-5
                disp('imag oflow');
            end
            
            px = real(ifft(ft));  % no shift in specgram
            
            %  figure;plot(px);pause;
            
            b = (c-1)*hop;
            x(b+[1:ftsize]) = x(b+[1:ftsize]) + window.*px;
        end;
        
        x = x * win/ftsize;  % scale amplitude
        
    end





end






%--------------------Licence ---------------------------------------------
% Copyright (c) <2013> J.Bitzer
% Institute for Hearing Technology and Audiology
% Jade University of Applied Sciences
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.