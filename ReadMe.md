
## Setting up variables
- Open `CreateConfigurationFile.m` and change the `SentinelDataFolder` to the local sentinel folder 
- Run  `CreateConfigurationFile.m` to create configuration.mat file which will be shared between multiple source files
- Run `CreateCroppedDataset.m` to generate image patches from the labeled data
- Run `CreateImageSets.m` to generate Train, Validation and Test set images for all algorithms

## Train Models

### Train Linear Regressor
- Run `TrainLinearRegressor.m` file to create Linear Regressor model and train it. 

### Train Random Forest
- Run `TrainRandomForest.m` file to create Random Forest model and train it. 

### Train UNet
- Run `TrainUNetModel.m` file to create UNet network and train it. 

## Test Model

### Test Model on Test Set
- Run `EvaluateResults.m` file to create ROC curves on the test set.

### Test Model on Image
- Run `TestModelsOnImage.m` file to see the results of all models on selected image.