#setwd("/Users/findlee/Desktop/Master's Degree 2018:2019/Summer 2019/ALY6040 90650 Data Mining Applications/final") 
#crime <- read.csv("crime.csv", stringsAsFactors = FALSE)
df <- read.csv(file.choose(), stringsAsFactors = FALSE)
head(df, n=2)
#####EDA

#Select necessary variables
df <- subset(df, select = c(OFFENSE_CODE_GROUP,OCCURRED_ON_DATE,
                            DISTRICT, 
                            YEAR,MONTH,DAY_OF_WEEK,HOUR,
                            UCR_PART, STREET))
head(df,n=2)
str(df)
nrow(df)
ncol(df)
#check the missing values
any(is.na(df))

install.packages("dplyr")
library(dplyr)
df <- filter(df, UCR_PART != "") #remove blank in UCR_PART


#Removing duplicates
data <- unique(df)

nrow(df)

summary(df$UCR_PART)


########################################################
#EDA
install.packages("ggplot2")
library(ggplot2)

#histogram of crime categories
ggplot(data = filter(data, UCR_PART == "Part One")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Histogram of Part 1 - Highly Serious Crimes")+
  coord_flip()

ggplot(data = filter(data, UCR_PART == "Part Two")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Histogram of Part 2 - Serious Crimes")+
  coord_flip()

ggplot(data = filter(data, UCR_PART == "Part Three")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Histogram of Part 3 - Less Serious Crimes")+
  coord_flip()

ggplot(data = filter(data, UCR_PART == "Other")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Histogram of Other Crimes")+
  coord_flip()


########################################################
#######CLUSTRING 
data1<- data[,c("DISTRICT","DAY_OF_WEEK")]
install.packages("klaR")
library(klaR)

result <- kmodes(data1, modes = 4)
attributes(result)
result$size
table(data$UCR_PART ,result$cluster)
table(data1$STREET,result$cluster)
df2 <- cbind(data,result$cluster)
head(df2)

plot(df2$DAY_OF_WEEK ~ df2$DISTRICT, labels= df2$`result$cluster`)

ggplot(data = filter(df2, result$cluster == "1")) +
  geom_bar(mapping = aes(x = df2$DISTRICT)) +
  facet_wrap(~ df2$DAY_OF_WEEK, nrow = 1) +
  coord_flip() +
  xlab("") +
  ylab("Count")

ggplot(data = filter(df2, result$cluster == "1")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Bar plot of Crimes in cluster 1")+
  coord_flip()

ggplot(data = filter(df2, result$cluster == "2")) +
  geom_bar(mapping = aes(x = UCR_PART)) +
  xlab("")+
  ggtitle("Histogram of Crimes in cluster 2")+
  coord_flip()
ggplot(data = filter(df2, result$cluster == "3")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Histogram of Crimes in cluster 3")+
  coord_flip()
ggplot(data = filter(df2, result$cluster == "4")) +
  geom_bar(mapping = aes(x = OFFENSE_CODE_GROUP)) +
  xlab("")+
  ggtitle("Histogram of Crimes in cluster 4")+
  coord_flip()

########################################################
##### TIME SERIES
tb<-table(data$OFFENSE_CODE_GROUP)
tb
tdf<-as.data.frame(tb)
tdf
tdf$Var1
tdf$Var1 <- NULL

offensedata <- ts(tdf,start=c(100))

summary(offensedata)

plot(offensedata,main="offense count",xlab="",ylab="frequency")

ggplot(data) +
  geom_freqpoly( mapping = aes(x = OCCURRED_ON_DATE)) +
  xlab("Date") +
  ylab("Number of Crimes")
#time series forecasting
install.packages("forecast")
library(forecast)

abc <- aggregate(offensedata, FUN=mean) # mean
model <- auto.arima(abc,ic='aic',trace = TRUE,seasonal = FALSE)

plot.ts(model$residuals,main="auto arima model")
Acf(ts(model$residuals))
Pacf(ts(model$residuals))

#testing the model
Box.test(model$residuals,lag = 3, type = 'Ljung-Box')

Box.test(model$residuals,lag = 14, type = 'Ljung-Box')

offense_forecast <- forecast(abc)
autoplot(offense_forecast)
accuracy(offense_forecast)





