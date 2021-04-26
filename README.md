The data was read into R, merged into a large temporary dataset, observations and variables were filtered to include only relevant information, and variables were renamed to be descriptive. 
Finally, the tidy data set was saved as TidyAverage_data.txt

unzip the file from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
The data has 2 variables Data X showing sensor signals and Data Y showing activity type


load the data.table, plyr and dplyr packages (make sure you load plyr before dplyr):
library("data.table")
library(plyr)
library(dplyr)

All raw data files were read into R and dimensions were analyzed, and the columns were renamed:
features <- fread("UCI HAR Dataset/features.txt", col.names = c("n_f", "functions"))

Some of Raw data table columns were binded in particular orders to create two new temporary data sets:
test_data <- cbind(y_test , sub_test, X_test)

These temporary data sets were then merged by combining rows:
merged_data <- rbind(test_data, train_data)

Regular Expressions were used to aquire information on the mean standard deviation:
filtered_data$Activity <- factor(filtered_data$Activity, levels=1:6, labels= activity_labels$activities)

Replace factor levels with their labels:
filtered_data$Activity <- factor(filtered_data$Activity, levels=1:6, labels= activity_labels$activities)

Use various functions to edit the variable names to make them more descriptive:
names(filtered_data) <- gsub("([[:lower:]])([[:upper:]])", "\\1 \\2", names(filtered_data))

Eliminate excessive observations by averaging each variable for each activity and each subject using ddply:
avg_data <- ddply(filtered_data, .(activity, subject), 
                  function(x) colMeans(x[,3:88]))
                  
Write the average data in a text file:                  
write.table(avg_data, "TidyAverage_data.txt", row.names = FALSE)                  
                  
