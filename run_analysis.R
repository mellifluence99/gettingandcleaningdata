library(dplyr)
library(tidyr)

## Read in the features dataset
features <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/features.txt", sep = "", header = FALSE, colClasses = "character")

## Create an index of measures relating to mean or standard deviation.
featuresind <- grep("mean|std",features$V2)

## Use the index to select thoses rows with features relating to the mean and standard deviatino.
selectedfeatures <- features[featuresind,]

## Rename the selected features to clarify their meaning
selectedfeatures <- rename(selectedfeatures, featureid = V1, featurename = V2)

## Read in the test and training subject datasets
subject_test <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/test/subject_test.txt", sep = "", header = FALSE, colClasses = "character")
subject_train <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/train/subject_train.txt", sep = "", header = FALSE, colClasses = "character")

## Rename the attributes to be clearer
subject_test <- rename(subject_test, subjectid = V1)
subject_train <- rename(subject_train, subjectid = V1)
 
## Read in the x test data
xtest <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE, colClasses = "character")
xtrain <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE, colClasses = "character")

## Turn the tables into tibbles
testtable <- tbl_df(xtest)
traintable <- tbl_df(xtrain)
 
## Add the subject data to the tables
testtable <- cbind(testtable, subject_test)
traintable <- cbind(traintable, subject_train)
 
## Pivot the measurement columns to be rows using gather
testtable2 <- testtable %>% gather(featureid, value, V1:V561)
traintable2 <- traintable %>% gather(featureid, value, V1:V561)
 
## Extract the activityids from both sets of data
testtable3 <- mutate(testtable2, activityid = substr(value,nchar(value)-2,nchar(value)), value = substr(value,1,nchar(value)-4))
traintable3 <- mutate(traintable2, activityid = substr(value,nchar(value)-2,nchar(value)), value = substr(value,1,nchar(value)-4))

## Read in the y test and train datasets
ytest <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/test/Y_test.txt", sep = "", header = FALSE, colClasses = "character")
ytrain <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/train/Y_train.txt", sep = "", header = FALSE, colClasses = "character")
 
## Read in the activity dataset and cleanse
activity_labels <- read.delim("/Users/tobysalway/data/Getting and Cleaning Data/UCI HAR Dataset/activity_labels.txt", sep = "", header = FALSE, colClasses = "character")
activity_labels <- rename(activity_labels, activityid = V1, activityname = V2)
 
testtable4 <- mutate(testtable3, featureid = sub("V","",testtable3$featureid))
traintable4 <- mutate(traintable3, featureid = sub("V","",traintable3$featureid))
 
mergedtesttable <- merge(testtable4, selectedfeatures, by.x="featureid", by.y="featureid")
mergedtraintable <- merge(traintable4, selectedfeatures, by.x="featureid", by.y="featureid")
 
## Make the activityid numeric
mergedtesttable <- mutate(mergedtesttable, activityid = as.numeric(activityid))
mergedtraintable <- mutate(mergedtraintable, activityid = as.numeric(activityid))
 
## Merge the activity information with the training table data
mergedtesttable2 <- merge(mergedtesttable, activity_labels, by.x="activityid", by.y="activityid")
mergedtraintable2 <- merge(mergedtraintable, activity_labels, by.x="activityid", by.y="activityid")
 
## Concatenate the data together.
finaltable <- rbind(mergedtesttable2, mergedtraintable2)

## Change the activity measurements to be numeric
finaltable2 <- mutate(finaltable, value = as.numeric(value))

## Group the data by activity, feature and subject.
grouping <- group_by(finaltable2, activityname, featurename, subjectid)

## Create a final dataset
summarizing <- summarise(grouping, meanvalue = mean(value))

## Arrange the data.
summarizing <- arrange(summarizing, subjectid, activityname, featurename)

tidytable <- select(summarizing, subjectid, featurename, activityname, meanvalue)

## Lastly write out the summarised dataset in csv format.
write.csv(tidytable,file="./tidydata.csv", row.names=FALSE)


     
 