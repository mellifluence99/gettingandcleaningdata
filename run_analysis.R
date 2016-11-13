## Load the required packages.
library(dplyr)
library(tidyr)

## Set the working directory
setwd("~/data/Getting and Cleaning Data/UCI HAR Dataset")

## Read in the y test and train datasets
ytest <- read.delim("./test/Y_test.txt", sep = "", header = FALSE, colClasses = "character")
ytrain <- read.delim("./train/Y_train.txt", sep = "", header = FALSE, colClasses = "character")

## Read in the activity dataset and rename columns
activity_labels <- read.delim("./activity_labels.txt", sep = "", header = FALSE, colClasses = "character")
activity_labels <- rename(activity_labels, activityid = V1, activityname = V2)

## Read in the features dataset and rename columns
features <- read.delim("./features.txt", sep = "", header = FALSE, colClasses = "character")
features <- rename(features, featureid = V1, featurename = V2)

## Create an index of feature measures relating to mean or standard deviation.
featuresind <- grep("mean|std",features$featurename)

## Use the index to select thoses rows with features relating to the mean and standard deviation.
selectedfeatures <- features[featuresind,]

## Read in the test and training subject datasets
subject_test <- read.delim("./test/subject_test.txt", sep = "", header = FALSE, colClasses = "character")
subject_train <- read.delim("./train/subject_train.txt", sep = "", header = FALSE, colClasses = "character")

## Rename the attributes to be clearer
subject_test <- rename(subject_test, subjectid = V1)
subject_train <- rename(subject_train, subjectid = V1)

## Read in the x test and train data and convert to tibbles
testtable <- tbl_df(read.delim("./test/X_test.txt", sep = "", header = FALSE, colClasses = "character"))
traintable <- tbl_df(read.delim("./train/X_train.txt", sep = "", header = FALSE, colClasses = "character"))

## Add the subject data to the tables
testtable <- cbind(testtable, subject_test)
traintable <- cbind(traintable, subject_train)

## For both the test and training data do the following:
## 1. Pivot the measurement columns to be rows using gather.
## 2. Cleanse and replace the activityid and featureid columns.
## 3. Merge with the features and activity labels data.
testtable2 <- testtable %>% 
    gather(featureid, value, V1:V561) %>%
    mutate(activityid = as.numeric(substr(value,nchar(value)-2,nchar(value))), value = substr(value,1,nchar(value)-4), featureid = sub("V","",featureid)) %>%
    merge(selectedfeatures, by.x="featureid", by.y="featureid") %>%
    merge(activity_labels, by.x="activityid", by.y="activityid")

traintable2 <- traintable %>% 
    gather(featureid, value, V1:V561) %>%
    mutate(activityid = as.numeric(substr(value,nchar(value)-2,nchar(value))), value = substr(value,1,nchar(value)-4), featureid = sub("V","",featureid)) %>%
    merge(selectedfeatures, by.x="featureid", by.y="featureid") %>%
    merge(activity_labels, by.x="activityid", by.y="activityid")

## Concatenate the test and training data together.
finaltable <- rbind(testtable2, traintable2)

## Perform the following tidying on the concatanted data:
## 1. Convert value to be numeric. 
## 2. Group the data by activity, feature and subject.  
## 3. Summarise the data to get the mean values.
## 4. Arrange the data by subject, activity and features
tidytable <- mutate(finaltable, value = as.numeric(value)) %>%
    group_by(activityname, featurename, subjectid) %>%
    summarise(meanvalue = mean(value)) %>%
    arrange(subjectid, activityname, featurename) %>%
    select(subjectid, featurename, activityname, meanvalue)

## Lastly write out the summarised tidy dataset in csv format.
write.csv(tidytable,file="~/git/gettingandcleaningdata/tidydata2.csv", row.names=FALSE)
