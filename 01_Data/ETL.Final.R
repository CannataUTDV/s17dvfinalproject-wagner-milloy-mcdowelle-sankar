# First set working directory to the "00_Doc" folder
# Next save a copy of the data to be cleaned up to the "01_Data" folder, and rename the file "PreETL_merged_univeristy_data.csv"
file_path = "../01_Data/PreETL_merged_university_data.csv"
df <- readr::read_csv(file_path)

# Rename columns
df <- plyr::rename(df, c("UNITID"="Unit_ID", "F1SYSNAM"="System_Name", "INSTNM"="Institution_Name", "CITY"="City", "STABBR"="State", "ZIP"="Zip_Code", "ACTCMMID"="Avg_ACT_Score", "NUMBRANCH"="Number_of_Branches", "ADM_RATE_ALL"="Admissions_Rate", "UGDS"="Total_Undergraduates", "UGDS_WHITE"="Percent_White", "SAT_AVG_ALL"="Avg_SAT_Score", "main"="Main", "UGDS_HISP"="Percent_Hispanic", "UGDS_ASIAN"="Percent_Asian", "UGDS_OTHER"="Percent_Other", "UGDS_BLACK"="Percent_Black", "TUITIONFEE_IN"="In-State_Tuition", "TUITIONFEE_OUT"="Out-State_Tuition"))

# Replace instances of "NULL" with NA
for (n in names(df)) {
  df[n] <- data.frame(lapply(df[n], gsub, pattern="NULL",replacement= NA))  
}

# Remove extra digits from zip codes
df$Zip_Code <- substr(df$Zip_Code, 1, 5)

# Save new .csv file
write.csv(df, gsub("PreETL_", "Clean_", file_path), row.names=FALSE, na = "")
