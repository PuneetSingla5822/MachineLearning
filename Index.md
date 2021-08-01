---
title: "Prediction Assignment"
author: "Puneet Singla"
date: "8/1/2021"
output:
  html_document:
    keep_md: true
---

## Background

One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, our objective will be to determine if participants correctly performed the activity of lifting a dumbell.

Six young health participants were asked to perform one set of 10 repetitions of the Unilateral Dumbbell Biceps Curl in five different fashions: exactly according to the specification (Class A), throwing the elbows to the front (Class B), lifting the dumbbell only halfway (Class C), lowering the dumbbell only halfway (Class D) and throwing the hips to the front (Class E). For our project, we will be using the data from accelerometers on the belt, forearm, arm, and dumbell of these participants.


## Data Processing

In the first step, let's download the data from the provided URL.

Next, we will subset the training data to the relevant fields. For starters, we will remove fields with no values or NAs. Then, we will focus on the four key features - Roll, Pitch, Yaw, and total acceleration for each sensor in Arm, Belt, Dumbell, and Forearm for our Machine Learning model.


```r
library(caret)
```

```
## Loading required package: lattice
```

```
## Loading required package: ggplot2
```

```
## Warning: package 'ggplot2' was built under R version 3.6.3
```

```r
set.seed(123)

## Download data files
training_fl_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
training_fl_nm <- "training.csv"
if(!file.exists(training_fl_nm)) {download.file(training_fl_url,training_fl_nm)}

## Load the data
training <- read.csv(training_fl_nm)

## Subset the data to required fields
training <- training[,grep("^roll|^pitch|^yaw|^total_accel|^classe",names(training))]
dim(training)
```

```
## [1] 19622    17
```

```r
str(training)
```

```
## 'data.frame':	19622 obs. of  17 variables:
##  $ roll_belt           : num  1.41 1.41 1.42 1.48 1.48 1.45 1.42 1.42 1.43 1.45 ...
##  $ pitch_belt          : num  8.07 8.07 8.07 8.05 8.07 8.06 8.09 8.13 8.16 8.17 ...
##  $ yaw_belt            : num  -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 -94.4 ...
##  $ total_accel_belt    : int  3 3 3 3 3 3 3 3 3 3 ...
##  $ roll_arm            : num  -128 -128 -128 -128 -128 -128 -128 -128 -128 -128 ...
##  $ pitch_arm           : num  22.5 22.5 22.5 22.1 22.1 22 21.9 21.8 21.7 21.6 ...
##  $ yaw_arm             : num  -161 -161 -161 -161 -161 -161 -161 -161 -161 -161 ...
##  $ total_accel_arm     : int  34 34 34 34 34 34 34 34 34 34 ...
##  $ roll_dumbbell       : num  13.1 13.1 12.9 13.4 13.4 ...
##  $ pitch_dumbbell      : num  -70.5 -70.6 -70.3 -70.4 -70.4 ...
##  $ yaw_dumbbell        : num  -84.9 -84.7 -85.1 -84.9 -84.9 ...
##  $ total_accel_dumbbell: int  37 37 37 37 37 37 37 37 37 37 ...
##  $ roll_forearm        : num  28.4 28.3 28.3 28.1 28 27.9 27.9 27.8 27.7 27.7 ...
##  $ pitch_forearm       : num  -63.9 -63.9 -63.9 -63.9 -63.9 -63.9 -63.9 -63.8 -63.8 -63.8 ...
##  $ yaw_forearm         : num  -153 -153 -152 -152 -152 -152 -152 -152 -152 -152 ...
##  $ total_accel_forearm : int  36 36 36 36 36 36 36 36 36 36 ...
##  $ classe              : Factor w/ 5 levels "A","B","C","D",..: 1 1 1 1 1 1 1 1 1 1 ...
```

## Build the Model & Cross-validation

Since we only have the training data, we are going to take the following cross-validation approach.

We will divide the training data into two sets:

1. 50% of the data will be used for training the model
2. 50% of the data will be used for validating the model & calculating out of sample error


```r
## Divide the data in Training & Validation set
inTrain <- createDataPartition(training$classe, p = 1/2)[[1]]
training_new <- training[inTrain,]
validation_new <- training[-inTrain,]
```

And we will use the K-fold technique to use our new training set to train our model.

As for the model itself, we will use the Random Forest model to train.


```r
## Use the K-Fold method to train the model on new training set
mdlctrl <- trainControl(method = "cv", number = 10, savePredictions = "all")

mdlfit <- train(classe ~ ., method="rf", data = training_new, trControl = mdlctrl)
```

## Evaluate Model Performance

Let's see how are model performed on the training set.


```r
table(training_new$classe, predict(mdlfit,training_new))
```

```
##    
##        A    B    C    D    E
##   A 2790    0    0    0    0
##   B    0 1899    0    0    0
##   C    0    0 1711    0    0
##   D    0    0    0 1608    0
##   E    0    0    0    0 1804
```

Next, let's see performance of our model on the validation set.


```r
table(validation_new$classe,predict(mdlfit,validation_new))
```

```
##    
##        A    B    C    D    E
##   A 2777    9    1    3    0
##   B   36 1835   25    2    0
##   C    0   21 1681    9    0
##   D    0    0   21 1586    1
##   E    0    4    6    2 1791
```

Lastly, out of sample error rate of this model is estimated to be 1.43%

