# CodeBook.md

The run_analysis.R scipt contained in the repo completes the following steps in order to produce a tidy summarised output.

1.  Loads the dplyr and tidyr libraries.
2.  Reads in the features.txt dataset, creates an index of variables containing the word mean or std, and then uses this index to select only thoses features from the features.txt dataset.
3.  Reads in the test and training subjects datasests (subject_test and subject_train respectively) and renames the varibles to make it clearer.
4.  
