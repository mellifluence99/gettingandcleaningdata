## Load the required packages.
library(dplyr)
library(tidyr)

## Read in the y test and train datasets
activitytest <- read.delim("./test/Y_test.txt", sep = "", header = FALSE, colClasses = "character")
activitytrain <- read.delim("./train/Y_train.txt", sep = "", header = FALSE, colClasses = "character")

## Rename the activityid column and convert to numeric for both test and training data.
activitytest <- 
    rename(activitytest, activityid = V1) %>%
    mutate(activityid = as.numeric(activityid))

activitytrain <- 
    rename(activitytrain, activityid = V1) %>%
    mutate(activityid = as.numeric(activityid))

## Read in the activity dataset and rename columns
activitylabels <- read.delim("./activity_labels.txt", sep = "", header = FALSE, colClasses = "character")
activitylabels <- rename(activitylabels, activityid = V1, activityname = V2)

## Read in the features dataset and rename columns
features <- read.delim("./features.txt", sep = "", header = FALSE, colClasses = "character")
features <- rename(features, featureid = V1, featurename = V2)

## Create an index of feature measures relating to mean or standard deviation.
featuresind <- grep("mean|std",features$featurename)

## Use the index to select thoses rows with features relating to the mean and standard deviation.
selectedfeatures <- features[featuresind,]

## Read in the test and training subject datasets
subjecttest <- read.delim("./test/subject_test.txt", sep = "", header = FALSE, colClasses = "numeric")
subjecttrain <- read.delim("./train/subject_train.txt", sep = "", header = FALSE, colClasses = "numeric")

## Rename the attributes to be clearer
subjecttest <- rename(subjecttest, subjectid = V1)
subjecttrain <- rename(subjecttrain, subjectid = V1)

## Read in the x test and train data and convert to tibbles
testtable <- tbl_df(read.delim("./test/X_test.txt", sep = "", header = FALSE, colClasses = "numeric"))
traintable <- tbl_df(read.delim("./train/X_train.txt", sep = "", header = FALSE, colClasses = "numeric"))

## Add the subjectid and activityid data to the tables
testtable <- cbind(testtable, subjecttest, activitytest)
traintable <- cbind(traintable, subjecttrain, activitytrain)

## For both the test and training data do the following:
## 1. Pivot the measurement columns to be rows using gather.
## 2. Cleanse and replace the featureid column.  Merge with the features and cleanse the feature names.
## 3. Merge with the activity labels data.
## 4. Select to exclude the feature and activity id columns
testtable <- testtable %>% 
    gather(featureid, value, V1:V561) %>%
    mutate(featureid = sub("V","",featureid)) %>%
    merge(selectedfeatures, by.x="featureid", by.y="featureid") %>%
    mutate(featurename = gsub("[-\\(\\)]","",featurename)) %>%
    merge(activitylabels, by.x="activityid", by.y="activityid") %>%
    select(subjectid, featurename, activityname, value)

traintable <- traintable %>% 
    gather(featureid, value, V1:V561) %>%
    mutate(featureid = sub("V","",featureid)) %>%
    merge(selectedfeatures, by.x="featureid", by.y="featureid") %>%
    mutate(featurename = gsub("[-\\(\\)]","",featurename)) %>%
    merge(activitylabels, by.x="activityid", by.y="activityid") %>%
    select(subjectid, featurename, activityname, value)

## Concatenate the test and training data together.
finaltable <- rbind(testtable, traintable)

## Perform the following tidying on the concatenated data:
## 1. Convert value to be numeric. 
## 2. Group the data by activity, feature and subject.  
## 3. Summarise the data to get the mean feature value for each distinct subject, activitity and feature.
## 4. Spread to put the featurenames back to column names. 
## 5. Arrange the data by subject and activity.
tidytable <- mutate(finaltable, value = as.numeric(value)) %>%
    group_by(activityname, featurename, subjectid) %>%
    summarise(meanvalue = mean(value)) %>%
    spread(featurename, meanvalue) %>%
    arrange(subjectid, activityname)

## Lastly write out the summarised tidy dataset in txt format.
write.table(tidytable, file="~/tidyhardata.txt", row.names=FALSE)
