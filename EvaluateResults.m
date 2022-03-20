%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

% set the evaluation dataset
EvalDataset = {'SENTINEL','PRISMA'};

for e = 1:length(EvalDataset)
    EvalOn = EvalDataset{e};
    AllEvaluatedResultsOutputName = fullfile(configuration.ModelOutputDirectory, sprintf('TestSetEvaluations_%s.mat', EvalOn));

    % load the apropriate dataset for evaluation
    if strcmp(EvalOn, 'PRISMA')
        load(configuration.prisma.TrainValidationTestSets, 'TestImageSet');
    elseif strcmp(EvalOn, 'SENTINEL')
        load(configuration.sentinel.TrainValidationTestSets, 'TestImageSet');
    else
        fprintf('Unknown dataset for evaluation!\n');
        return;
    end

    % get the images and labels
    [TestImages,  TestLabels]  = GetImageSet(TestImageSet);

    % try to load the previous results
    if exist(AllEvaluatedResultsOutputName, 'file')
        fprintf('Model already evaluated, loading the previously evaluated model!\n');
        load(configuration.AllEvaluatedResults);
    else

        % set the model names
        ModelNames = {'U-Net', 'Random Forest', 'Linear Regressor', 'Vescovi Index'};

        %% get UNet model
        load(configuration.UNetTrainedNetwork);
        UNetTestPredictions = GetUNetPredictions(TestImages, UNetNetwork);

        %% get Linear Regressor model
        load(configuration.LinearRegressorTrainedNetwork);
        LinearRegressorTestPredictions = GetLinearRegressorPredictions(TestImages, LinearRegressorNetwork);

        %% get Random Forest model
        load(configuration.RandomForestTrainedNetwork);
        RandomForestTestPredictions = GetRandomForestPredictions(TestImages, RandomForestNetwork);

        %% get Vescovi predictions
        VescoviIndexTestPredictions = GetVescoviPredictions(TestImages);

        %% get the results
        AllLabelsCell = cell(size(TestLabels, 3), 1);
        AllPredictionsCell = cell(size(TestLabels, 3), length(ModelNames));

        for idx = 1:size(TestLabels, 3)

            % get the labels
            TestLabel = reshape(TestLabels(configuration.OutputRange, configuration.OutputRange, idx), [], 1);

            % get predictions of different models
            AllPredictionsCell{idx, 1} = reshape(UNetTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
            AllPredictionsCell{idx, 2} = reshape(RandomForestTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
            AllPredictionsCell{idx, 3} = reshape(LinearRegressorTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
            AllPredictionsCell{idx, 4} = reshape(VescoviIndexTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);

            % save the result into array
            AllLabelsCell{idx} = TestLabel;
        end

        % save the results
        save(AllEvaluatedResultsOutputName, 'AllLabelsCell','AllPredictionsCell','ModelNames');
    end

    %% compute the ROC
    [TP, FP, FN, TN, thresholds] = GetROC(cell2mat(AllLabelsCell), cell2mat(AllPredictionsCell), 100);

    %% display results
    TPR = TP ./ (TP + FN);
    FPR = FP ./ (FP + TN);

    AUC = zeros(size(TPR, 2), 1);
    for c = 1:size(TPR, 2)
        AUC(c) = abs(trapz(FPR(:,c),TPR(:,c)));
    end

    legendStrings = cell(size(ModelNames));

    % plot and create legend
    FigH = figure('Position', [100 100 800 480]);
    hold on;
    for mm = 1:length(ModelNames)
        legendStrings{mm} = sprintf('%18s (AUC: %5.3f)', ModelNames{mm}, AUC(mm));
        plot(FPR(:, mm), TPR(:, mm), 'LineWidth', 3);
    end

    % set up plot
    ax=gca;
    ax.FontSize = 14;
    xlabel('False Positive Rate','FontName', 'Courier', 'FontWeight', 'b')
    ylabel('True Positive Rate','FontName', 'Courier', 'FontWeight', 'b')
    xlim([0 0.3]);
    grid minor;
    legend(legendStrings, 'FontName', 'Courier', 'FontWeight', 'b', 'Location', 'SouthEast');
    saveas(FigH, fullfile(configuration.AssetsDirectory, sprintf('results_%s.eps',EvalOn)),'epsc');

    % print TPR at fixed FPR
    FPRT = 0.05;
    TPRT = zeros(1,length(ModelNames));
    THRT = zeros(1,length(ModelNames));
    for mm = 1:length(ModelNames)
        % get uniques
        [fpr, fprIDX, ~] = unique(FPR(:,mm));
        tpr = TPR(fprIDX,mm);
        thres = thresholds(fprIDX);
        TPRT(mm) = interp1(fpr, tpr, FPRT);
        THRT(mm) = interp1(fpr, thres, FPRT);
        fprintf('Model: %s, TPR at FPR: %5.3f / %5.3f Threshold: %5.4f\n', ModelNames{mm}, TPRT(mm), FPRT, THRT(mm));
    end

    % now use thresholds to create sample outputs
    %% not the best way to create image mosaic
    RandomPatches = randperm(size(TestImages, 4), 3);
    AllImagesCell = cell(length(RandomPatches), length(ModelNames)+1);
    for n = 1:length(RandomPatches)

        % get the index
        nidx = RandomPatches(n);

        % get the TCI
        TCI = GetTCIFromBands(TestImages(configuration.OutputRange, configuration.OutputRange,:,nidx), configuration.sentinel.BandNames);

        % create ground truth
        TCIHighlighted = HighlightPredictionsOnImage(TCI, TestLabels(configuration.OutputRange, configuration.OutputRange, nidx), []);

        AllImagesCell{n,1} = padarray(TCI, [2 2], 0, 'both');
        AllImagesCell{n,2} = padarray(TCIHighlighted, [2 2], 0, 'both');

        % get the highlighted prediction
        for mm = 1:length(ModelNames)
            P = double(reshape(AllPredictionsCell{nidx,mm}, configuration.ImageSize) >= THRT(mm));
            H = HighlightPredictionsOnImage(TCI, P, []);
            % insert image
            AllImagesCell{n, mm+2} = padarray(H, [2 2], 0, 'both');
        end
    end

    AllImages = cell2mat(AllImagesCell);
    AllImages = padarray(AllImages, [50 0], 1, 'pre');

    % add text on image
    ModelNamesExtended = ['TCI', 'Ground Truth', ModelNames];
    ImageTotalWidth = length(configuration.OutputRange) + 4;
    for mm = 1:length(ModelNamesExtended)
        x = 0.5*ImageTotalWidth + (mm-1) * ImageTotalWidth;
        AllImages = insertText(AllImages,[x 25],ModelNamesExtended{mm},'FontSize',18, 'AnchorPoint','Center', 'BoxColor', 'white');
    end

    figure,imshow(AllImages);
    imwrite(AllImages, fullfile(configuration.AssetsDirectory, sprintf('results_%s_%d_%d_%d.png', EvalOn, RandomPatches)));

end