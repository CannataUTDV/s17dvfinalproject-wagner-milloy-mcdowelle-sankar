require("jsonlite")
require("RCurl")

# Access dirty data
df <- read.csv("https://query.data.world/s/1oql7850pfb3ep6u5cnkgi313",header=T);

summary(df)