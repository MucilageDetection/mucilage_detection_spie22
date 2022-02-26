
## Setting up variables
- Open `CreateConfigurationFile.m` and change the `SentinelDataFolder` to the local sentinel folder 
- Run  `CreateConfigurationFile.m` to create configuration.mat file which will be shared between multiple source files
- Run `CreateCroppedDataset.m` to generate image patches from the labeled data
- Run `CreateImageSets.m` to generate Train, Validation and Test set images for all algorithms
- Run `CreatePixelSampleDataset.m` to create randomly sampled mucilage and water pixel data

## Train UNet
- Run `TrainUNetModel.m` file to create UNet network and train it. 