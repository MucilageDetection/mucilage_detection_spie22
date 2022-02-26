function NetworkOptions = GetOptions()

    NetworkOptions.Resolution = 20;
    patchSize = 300;
    patchOverlap = 116;
    batchSize = 16;
    patchCount = 200;
    numEpochs = 0;
    loadAllAtOnce = 1;
    dataAugmentationTypes = ['original','hflip','vflip'];
    nband = 9;
    if resolution == 10
      nband = 10;
    end
    imageSize = [300 300 nband];
    numClasses = 2;
    encoderDepth = 4;


end