# CodeBook.md

The run_analysis.R scipt contained in the repo completes the required processing.  This document outlines the data, key variables and transformations carried out on the data to obtain the desired tidy dataset result.

## Data

The Data used in this analysis were obtained from the following url: <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

The following url contains additional background information relating to how the data were obtained: <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

The data were smartphone accelerometer and gyroscope metrics from subjects wearing Samsung Galaxy 5 smartphones while carrying out various activities.

The instructions for the assignment specified selection of mean and standard deviation data only.  I grepped for 'std' and 'mean' in the variable names to select these.

## Variables

The %>% operator was used where possible to reduce the number of (intermediate) variables used.

1. *activitytest* and *activitytrain* contains the *Y_test.txt* and *Y_train.txt* activityid information respectively.
2. *activitylabels* contains the *activity_labels.txt* data.
3. *features* contains the *features.txt* data.
4. *selectedfeatures* contains just those features required in the analysis relating to mean or standard deviation.
5. *subjecttest* and *subjecttrain* contains the *subject_test.txt* and *subject_train.txt* subjectid information respectively.
6. *testtable* and *traintable* are tibbles containing the merged activity, features, and subject information for the test and training data respectively.
7. *finaltable* is a dataframe containing the merged results of the test and training data.
8. *tidytable* is a dataframe containing the tidied and summarised results showing the mean variable value of each distinct feature, activity and subject combination.

## Transformations

The following steps are taken in the run_analysis.R script:

1.  Loads the dplyr and tidyr libraries.
2.  Reads in the features.txt dataset, creates an index of variables containing the word mean or std, and then uses this index to select only thoses features from the features.txt dataset.
3.  Reads in the test and training subjects datasests (subject_test and subject_train respectively) and renames the variables to make them clearer.  These dataframes are then turned into tibbles.
4.  The training and test data are then read into tibbles.
5.  The subject data is appended as an additional column to the above two tables.
6.  The test and training data are tidyed and merged with the features and and activity labels.
7.  The test and training data are then merged.
8.  This final table is grouped and summarised to find the mean for each distinct variable, activity and subject.
9.  lastly this is written out to a csv file for further analysis.
