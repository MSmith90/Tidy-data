#Set working directory
#Unzip file
unzip("getdata_projectfiles_UCI HAR Dataset.zip")

#Load packages
library("data.table")
library(plyr)
library(dplyr)

#Read files into R; label the variables in each data set
features <- fread("UCI HAR Dataset/features.txt", col.names = c("n_f", "functions"))
activity_labels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("n_a", "activities"))
                                           
sub_test <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
sub_train <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
X_test <- fread("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
X_train <- fread("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_test <- fread("UCI HAR Dataset/test/y_test.txt", col.names = "Activity")
y_train <- fread("UCI HAR Dataset/train/y_train.txt", col.names = "Activity")
# Header = FALSE doesn't need to be used as we are replacing the column names anyway

#Bind the columns to make the test/train data sets
#Put the variables in this particular order for the best data set
test_data <- cbind(y_test , sub_test, X_test)
train_data <- cbind(y_train, sub_train, X_train)

#Test if the binding has worked. There should be more than 2 columns
dim(test_data); dim(train_data)


#1. Merge the training and the test sets to create one data set.
merged_data <- rbind(test_data, train_data)

#Check it worked
View(merged_data)



#2. Extract only the measurements on the mean and standard deviation for each measurement.
#Use grep to subset the merged dataset for the mean and standard deviation, while keeping the 'Activity' and 'Subject' columns
filtered_data <- subset(merged_data, select = grep("(.*[Mm]ean|std.*)|Activity|Subject", names(merged_data)))
View(filtered_data)



#3. Use descriptive activity names to name the activities in the data set
#Replace 'Activity' column with factor labels
filtered_data$Activity <- factor(filtered_data$Activity, levels=1:6, labels= activity_labels$activities)



#4. Appropriately label the data set with descriptive variable names.

#Add spaces before uppercase letters
names(filtered_data) <- gsub("([[:lower:]])([[:upper:]])", "\\1 \\2", names(filtered_data))

#Make all column names lowercase
names(filtered_data) <- tolower(names(filtered_data)) 

#Replace all unnecessary parts of the names with a single space
names(filtered_data) <- gsub("-", " ", names(filtered_data))
names(filtered_data) <- gsub("\\()", "", names(filtered_data))
names(filtered_data) <- gsub("  "," ", names(filtered_data))
names(filtered_data) <- sub(" $", "", names(filtered_data))

#Make some parts of the variable names more descriptive
names(filtered_data) <- sub("freq", "frequency", names(filtered_data))
names(filtered_data) <- sub("^f", "frequency", names(filtered_data))
names(filtered_data) <- sub("^t|t ", "time ", names(filtered_data))
names(filtered_data) <- gsub("acc", "acceleration", names(filtered_data))
names(filtered_data) <- gsub("gyro", "angular velocity", names(filtered_data)) 
names(filtered_data) <- sub("std", "standard deviation", names(filtered_data))
names(filtered_data) <- sub("mag", "magnitude", names(filtered_data))

View(filtered_data)



#5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject
#Since there's multiple rows to use colMeans on, use the plyr package instead of dplyr
avg_data <- ddply(filtered_data, .(activity, subject), 
                  function(x) colMeans(x[,3:88]))
View(avg_data)

#Save your data
write.table(avg_data, "TidyAverage_data.txt", row.names = FALSE)
