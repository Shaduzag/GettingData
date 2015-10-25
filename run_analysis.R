#Set paths
baseDir <- "."
dataSetDir <-  paste (baseDir, "UCI HAR Dataset", sep="/")
list.files(baseDir)
list.files(dataSetDir)

#read the data sets

trainSubjectsPath <- paste (dataSetDir, "train", "subject_train.txt", sep="/")
testSubjectsPath <-  paste (dataSetDir, "test", "subject_test.txt", sep="/")
trainSubjects <- read.table(trainSubjectsPath, header = FALSE) 
testSubjects  <- read.table(testSubjectsPath, header = FALSE)
str(trainSubjects)
str(testSubjects)
table(trainSubjects)
table(testSubjects)


trainLabelsPath <- paste (dataSetDir, "train", "y_train.txt", sep="/")
testLabelsPath <-  paste (dataSetDir, "test", "y_test.txt", sep="/")
trainLabels <- read.table(trainLabelsPath, header = FALSE) 
testLabels  <- read.table(testLabelsPath, header = FALSE)
str(trainLabels)
str(testLabels)
table(trainLabels)
table(testLabels)


trainSetPath <- paste (dataSetDir, "train", "X_train.txt", sep="/")
testSetPath <-  paste (dataSetDir, "test", "X_test.txt", sep="/")
trainSet <- read.table(trainSetPath, header = FALSE) 
testSet  <- read.table(testSetPath, header = FALSE)
dim(trainSet)
dim(testSet)

# merge datasets

mergedSubjects <- rbind(trainSubjects,testSubjects)
dim(mergedSubjects)
str(mergedSubjects)

mergedLabels <- rbind(trainLabels,testLabels)
dim(mergedLabels)
str(mergedLabels)

mergedSet <- rbind(trainSet,testSet)
dim(mergedSet)
str(mergedSet)

# read labels of features and activity 

featuresPath <-  paste (dataSetDir, "features.txt", sep="/")
activitiesPath <-  paste (dataSetDir, "activity_labels.txt", sep="/")
features <- read.table(featuresPath, header = FALSE) 
activities  <- read.table(activitiesPath, header = FALSE)

colnames(features) <- c("Feature_code","Feature_str")
colnames(activities) <- c("Activity_code","Activity_str")
str(features)
str(activities)
activities

# Renames columns of the merged measurement with feature labels
colnames(mergedSet) <- features$Feature_str
names(mergedSet)

# filter the merged dataset to keep names with mean() or std()

mean_std <- names(mergedSet)[grep("mean\\(\\)|std\\(\\)", names(mergedSet))]
mean_std

# subset 
mergedSet <- mergedSet[,mean_std]
dim(mergedSet)

colnames(mergedSet) <- sub("\\(\\)", "", names(mergedSet))
colnames(mergedSet)

#add Subject and Activity columns in front
mergedSet = cbind(Subject = mergedSubjects[,1], Activity = mergedLabels[,1], mergedSet)
str(mergedSet$Subject)
str(mergedSet$Activity)
dim(mergedSet)
table(mergedSet$Subject)
table(mergedSet$Activity)
colnames(mergedSet)

#add activity labels to the merged dataset

str(mergedSet$Activity)
mergedSet$Activity <- apply (mergedSet["Activity"],1,function(x) activities[x,2])
table(mergedSet$Activity)
str(mergedSet$Activity)
dim(mergedSet)  

# calculate the mean by subject and activity
tidy <- aggregate(. ~ Subject + Activity, data=mergedSet, mean)
dim(tidy)
names(tidy)

# save tidy dataset
tidyPath <- paste(dataSetDir, "tidy.txt", sep="/")
write.table(tidy, tidyPath, sep="\t", col.names=T, row.names = T, quote=T)

# verify data
v <- read.table(tidyPath, sep="\t")
dim(v)