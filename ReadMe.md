
## Setting up variables
- Open `CreateConfigurationFile.m` and change the `SentinelDatasetFolder` and `PrismaDatasetFolder` to the local folders 
- Run  `CreateConfigurationFile.m` to create configuration.mat file which will be shared between multiple source files
- Run `CreateMultiSpectralDataset.m` to generate image patches from the labeled data

## Train Models

### Train Linear Regressor
- Run `TrainLinearRegressor.m` file to create Linear Regressor model and train it. 

### Train Random Forest
- Run `TrainRandomForest.m` file to create Random Forest model and train it. 

### Train UNet
- Run `TrainUNetModel.m` file to create UNet network and train it. 

## Test Model

### Find the thresholds values on TrainSet
- Run `FindModelThresholds.m` file to create model wise threshold values for fixed FPR.

### Test Model on Test Set
- Run `EvaluateResults.m` file to create ROC curves on the test set.

### Test Model on Image
- Run `TestModelsOnImage.m` file to see the results of all models on selected image.