format longG
% Lettura dati
opts = detectImportOptions("evaluations.csv");
opts = setvartype(opts,{'Var1'},'string');
Evaluations = readtable("evaluations.csv",opts);
Dates = table2array(Evaluations(:,4));
People = table2array(Evaluations(:,1));
[datesLength,~] = size(Dates);
windowSize = 10; % Numero di secondi
formatSpec = '%.0f';
matrix = [];
Responses = [];
for p = 1:datesLength
  disp(p)
  % Lettura file dei sensori
  Muse = readtable(strcat("SensorsCapture/Person_", num2str(People(p, :),formatSpec),"/Muse_0055DAB90EEB/", string(Dates(p,:)),".csv"),'ReadVariableNames',false);
  ShimmerEMG = readtable(strcat("SensorsCapture/Person_", num2str(People(p, :),formatSpec),"/Shimmer_000666809BE7/", string(Dates(p,:)),".csv"),'ReadVariableNames',false);
  ShimmerGSR_PPG = readtable(strcat("SensorsCapture/Person_", num2str(People(p, :),formatSpec),"/Shimmer_000666808EDD/", string(Dates(p,:)),".csv"),'ReadVariableNames',false);
  % Determino il minor numero di righe tra i tre file per tener conto di eventuali errori di sincronizzazione
  [museRows,~] = size(Muse);
  [emgRows,~] = size(ShimmerEMG);
  [gsrppgRows,~] = size(ShimmerGSR_PPG);
  minRows = min([museRows,emgRows,gsrppgRows]);
  windowsNumber = fix(minRows/(256*windowSize))-1;
  for i = 0:windowsNumber
    row = [];
    % Estrazione delle features dai dati EEG
    for j = 22:25
      EEGRAW = table2array(Muse(1+i*windowSize*256:(i+1)*windowSize*256,j));
      % Estrazione onde delta, theta, alpha, beta, gamma
      fftEEGRAW = fft(EEGRAW);
      deltaWave = abs(ifft(bandpass(fftEEGRAW, [1 4], 256)));
      thetaWave = abs(ifft(bandpass(fftEEGRAW, [4 7.5], 256)));
      alphaWave = abs(ifft(bandpass(fftEEGRAW, [7.5 13], 256)));
      betaWave = abs(ifft(bandpass(fftEEGRAW, [13 30], 256)));
      gammaWave = abs(ifft(bandpass(fftEEGRAW, [30 44], 256)));
      % Calcolo features
      EEGFeatures = [median(EEGRAW), max(EEGRAW), min(EEGRAW), harmmean(EEGRAW), trimmean(EEGRAW, 10), kurtosis(EEGRAW), skewness(EEGRAW), mean(EEGRAW, 'omitnan'), std(EEGRAW), var(EEGRAW), peak2peak(EEGRAW), peak2rms(EEGRAW), rms(EEGRAW), rssq(EEGRAW), meanfreq(EEGRAW), medfreq(EEGRAW), obw(EEGRAW), max(deltaWave), min(deltaWave), median(deltaWave), mean(deltaWave), max(alphaWave), min(alphaWave), median(alphaWave), mean(alphaWave), max(betaWave), min(betaWave), median(betaWave), mean(betaWave), max(gammaWave), min(gammaWave), median(gammaWave), mean(gammaWave),max(thetaWave), min(thetaWave), median(thetaWave), mean(thetaWave)];
      row=[row,EEGFeatures];
    end
    % Estrazione delle features dai dati EMG
    EMG1 = table2array(ShimmerEMG(1+i*256*windowSize:(i+1)*windowSize*256,4));
    EMGFeatures1 = [median(EMG1), max(EMG1), min(EMG1), harmmean(EMG1), trimmean(EMG1, 10), kurtosis(EMG1), skewness(EMG1), mean(EMG1, 'omitnan'), std(EMG1), var(EMG1), peak2peak(EMG1), peak2rms(EMG1), rms(EMG1), rssq(EMG1), meanfreq(EMG1), medfreq(EMG1), obw(EMG1)];
    EMG2 = table2array(ShimmerEMG(1+i*256*windowSize:(i+1)*windowSize*256,5));
    EMGFeatures2 = [median(EMG2), max(EMG2), min(EMG2), harmmean(EMG2), trimmean(EMG2, 10), kurtosis(EMG2), skewness(EMG2), mean(EMG2, 'omitnan'), std(EMG2), var(EMG2), peak2peak(EMG2), peak2rms(EMG2), rms(EMG2), rssq(EMG2), meanfreq(EMG2), medfreq(EMG2), obw(EMG2)];
    row=[row,EMGFeatures1, EMGFeatures2];
    % Estrazione delle features dai dati GSR
    GSR = table2array(ShimmerGSR_PPG(1+i*256*windowSize:(i+1)*windowSize*256,5));
    GSRFeatures = [median(GSR), max(GSR), min(GSR), harmmean(GSR), trimmean(GSR, 10), kurtosis(GSR), skewness(GSR), mean(GSR, 'omitnan'), std(GSR), var(GSR), peak2peak(GSR), peak2rms(GSR), rms(GSR), rssq(GSR), meanfreq(GSR), medfreq(GSR), obw(GSR)];
    row=[row,GSRFeatures];
    % Estrazione delle features dai dati PPG
    PPG = table2array(ShimmerGSR_PPG(1+i*256*windowSize:(i+1)*windowSize*256,3));
    PPGFeatures = [median(PPG), max(PPG), min(PPG), harmmean(PPG), trimmean(PPG, 10), kurtosis(PPG), skewness(PPG), mean(PPG, 'omitnan'), std(PPG), var(PPG), peak2peak(PPG), peak2rms(PPG), rms(PPG), rssq(PPG), meanfreq(PPG), medfreq(PPG), obw(PPG)];
    row=[row,PPGFeatures];
    % Aggiorno matrice aggiungendo la nuova riga
    matrix=[matrix;row];
    Responses = [Responses;Evaluations(p,5:6)];
  end
end
% Rimpiazzo i valori NAN con 0
matrix(isnan(matrix))=0;
dataTable = array2table(matrix);
% Nomi delle colonne
variableNames={'EEG1median','EEG1max','EEG1min','EEG1harmmean','EEG1trimmean','EEG1kurtosis','EEG1skewness','EEG1mean','EEG1std', 'EEG1var','EEG1peak2peak','EEG1peak2rms','EEG1rms','EEG1rssq','EEG1meanfreq','EEG1medfreq','EEG1obw', 'EEG1deltaMax','EEG1deltaMin', 'EEG1deltaMedian','EEG1deltaMean', 'EEG1alphaMax','EEG1alphaMin', 'EEG1alphaMedian','EEG1alphaMean','EEG1betaMax','EEG1betaMin', 'EEG1betaMedian','EEG1betaMean','EEG1gammaMax', 'EEG1gammaMin', 'EEG1gammaMedian','EEG1gammaMean','EEG1thetaMax','EEG1thetaMin', 'EEG1thetaMedian','EEG1thetaMean','EEG2median','EEG2max','EEG2min','EEG2harmmean', 'EEG2trimmean','EEG2kurtosis','EEG2skewness','EEG2mean','EEG2std','EEG2var', 'EEG2peak2peak','EEG2peak2rms','EEG2rms','EEG2rssq', 'EEG2meanfreq','EEG2medfreq','EEG2obw','EEG2deltaMax','EEG2deltaMin', 'EEG2deltaMedian','EEG2deltaMean','EEG2alphaMax','EEG2alphaMin', 'EEG2alphaMedian','EEG2alphaMean','EEG2betaMax','EEG2betaMin', 'EEG2betaMedian','EEG2betaMean','EEG2gammaMax','EEG2gammaMin', 'EEG2gammaMedian','EEG2gammaMean','EEG2thetaMax', 'EEG2thetaMin', 'EEG2thetaMedian','EEG2thetaMean','EEG3median','EEG3max','EEG3min','EEG3harmmean','EEG3trimmean','EEG3kurtosis','EEG3skewness', 'EEG3mean','EEG3std','EEG3var', 'EEG3peak2peak','EEG3peak2rms','EEG3rms','EEG3rssq','EEG3meanfreq','EEG3medfreq','EEG3obw', 'EEG3deltaMax','EEG3deltaMin', 'EEG3deltaMedian','EEG3deltaMean','EEG3alphaMax','EEG3alphaMin', 'EEG3alphaMedian','EEG3alphaMean','EEG3betaMax','EEG3betaMin', 'EEG3betaMedian','EEG3betaMean','EEG3gammaMax','EEG3gammaMin', 'EEG3gammaMedian','EEG3gammaMean','EEG3thetaMax','EEG3thetaMin', 'EEG3thetaMedian','EEG3thetaMean','EEG4median', 'EEG4max','EEG4min','EEG4harmmean','EEG4trimmean','EEG4kurtosis','EEG4skewness','EEG4mean','EEG4std','EEG4var', 'EEG4peak2peak', 'EEG4peak2rms','EEG4rms','EEG4rssq','EEG4meanfreq','EEG4medfreq','EEG4obw','EEG4deltaMax','EEG4deltaMin', 'EEG4deltaMedian','EEG4deltMean', 'EEG4alphaMax','EEG4alphaMin', 'EEG4alphaMedian','EEG4alphaMean','EEG4betaMax','EEG4betaMin', 'EEG4betaMedian','EEG4betaMean','EEG4gammaMax','EEG4gammaMin', 'EEG4gammaMedian','EEG4gammaMean','EEG4thetaMax','EEG4thetaMin', 'EEG4thetaMedian','EEG4thetaMean','EMG1median','EMG1max','EMG1min','EMG1harmmean', 'EMG1trimmean','EMG1kurtosis','EMG1skewness','EMG1mean','EMG1std','EMG1var', 'EMG1peak2peak','EMG1peak2rms','EMG1rms', 'EMG1rssq','EMG1meanfreq','EMG1medfreq','EMG1obw','EMG2median','EMG2max','EMG2min','EMG2harmmean','EMG2trimmean','EMG2kurtosis', 'EMG2skewness','EMG2mean','EMG2std','EMG2var','EMG2peak2peak','EMG2peak2rms','EMG2rms','EMG2rssq','EMG2meanfreq','EMG2medfreq', 'EMG2obw', 'GSRmedian','GSRmax','GSRmin','GSRharmmean','GSRtrimmean','GSRkurtosis','GSRskewness','GSRmean','GSRstd','GSRvar', 'GSRpeak2peak','GSRpeak2rms','GSRrms','GSRrssq','GSRmeanfreq','GSRmedfreq','GSRobw', 'PPGmedian','PPGmax','PPGmin','PPGharmmean', 'PPGtrimmean','PPGkurtosis','PPGskewness','PPGmean','PPGstd','PPGvar','PPGpeak2peak','PPGpeak2rms','PPGrms','PPGrssq','PPGmeanfreq', 'PPGmedfreq','PPGobw'};
dataTable.Properties.VariableNames = variableNames;
Responses.Properties.VariableNames = {'Emotion', 'Level'};
T = [dataTable, Responses]
% Tabella normalizzata
dataTableNormalized = normalize(dataTable, 'Range');
TNormalized = [dataTableNormalized, Responses]
% Downsampling e augmentation
happiness = downsample(T(find(strcmp(T.Emotion,'happiness')), :), 3);
boredom = downsample(T(find(strcmp(T.Emotion,'boredom')), :), 3);
sadness = downsample(T(find(strcmp(T.Emotion,'sadness')), :), 2);
anxiety = T(find(strcmp(T.Emotion,'anxiety')), :);
anger = T(find(strcmp(T.Emotion,'anger')), :);
disgust = T(find(strcmp(T.Emotion,'disgust')), :);
fear = T(find(strcmp(T.Emotion,'fear')), :);
S = RandStream('mt19937ar','Seed',5489);
angerNoise = array2table(awgn(table2array(anger(:, 1:216)),10,0,S));
angerNoise = [angerNoise, anger(:,217:218)];
angerNoise.Properties.VariableNames = anger.Properties.VariableNames;
reset(S);
anger = [anger;angerNoise];
for i = 1:2
  S = RandStream('mt19937ar','Seed',5489);
  disgustNoise = array2table(awgn(table2array(disgust(:, 1:216)),10,0,S));
  disgustNoise = [disgustNoise, disgust(:,217:218)];
  disgustNoise.Properties.VariableNames = disgust.Properties.VariableNames;
  disgust = [disgust;disgustNoise];
  reset(S);
end
S = RandStream('mt19937ar','Seed',5489);
fearNoise = array2table(awgn(table2array(fear(:, 1:216)),10,0,S));
fearNoise = [fearNoise, fear(:,217:218)];
fearNoise.Properties.VariableNames = fear.Properties.VariableNames;
fear = [fear;fearNoise];
reset(S);
%Tabella con Augmentation e Downsampling senza normalizzazione
TAugmented = [happiness; boredom; sadness; anxiety; anger; disgust; fear];
