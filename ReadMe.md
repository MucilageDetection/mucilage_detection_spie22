
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

```
SENTINEL
Model: U-Net, TPR at FPR: 0.878 / 0.050 Threshold: 0.1194
Model: Random Forest, TPR at FPR: 0.843 / 0.050 Threshold: 0.5151
Model: Linear Regression, TPR at FPR: 0.419 / 0.050 Threshold: 0.4912
Model: Vescovi Index, TPR at FPR: 0.185 / 0.050 Threshold: 0.7322

PRISMA
Model: U-Net, TPR at FPR: 0.872 / 0.050 Threshold: 0.5183
Model: Random Forest, TPR at FPR: 0.898 / 0.050 Threshold: 0.6931
Model: Linear Regression, TPR at FPR: 0.821 / 0.050 Threshold: 0.4546
Model: Vescovi Index, TPR at FPR: 0.338 / 0.050 Threshold: 0.6982
```


### Test Model on Image
- Run `TestModelsOnImage.m` file to see the results of all models on selected image.