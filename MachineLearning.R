ML <- function() {
  
  set.seed(123)
  
  library(caret)
  
  ## Download data files
  training_fl_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
  training_fl_nm <- "training.csv"
  test_fl_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
  test_fl_nm <- "test.csv"
  if(!file.exists(training_fl_nm)) {download.file(training_fl_url,training_fl_nm)}
  if(!file.exists(test_fl_nm)) {download.file(test_fl_url,test_fl_nm)}
  
  ## Read the data
  training <- read.csv(training_fl_nm)
  training_sub <- training[,grep("^roll|^pitch|^yaw|^total_accel|^classe",names(training))]
  
  test <- read.csv(test_fl_nm)
  test_sub <- test[,grep("^roll|^pitch|^yaw|^total_accel",names(test))]
  
  inTrain <- createDataPartition(training_sub$classe, p = 1/2)[[1]]
  training_new <- training_sub[inTrain,]
  validation_new <- training_sub[-inTrain,]
  
  mdlctrl <- trainControl(method = "cv", number = 10, savePredictions = "all")
  
  mdlfit <- train(classe ~ ., method="rf", data = training_new, trControl = mdlctrl)
  
  confusionMatrix(validation_new$classe,predict(mdlfit,validation_new))
  out_of_smpl_err <- 1- confusionMatrix(validation_new$classe,predict(mdlfit,validation_new))$overall[1]
  
  predTest <- predict(mdlfit, test_sub)
}