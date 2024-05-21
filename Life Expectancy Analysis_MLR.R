setwd('~/Desktop/RegressionAndTimeSeries/Project')
rm(list = ls())
library(openxlsx)
library(dplyr)
dt = read.csv("Life Expectancy Data.csv")
# dt
# View(dt)
model = lm(Life.expectancy ~ ., data = dt)
summary(model)

dt_1 <- dt[-3:-2]

mean_values <- list()

# Loop through each column in the dataset
# Group by 'Country' and calculate mean for each column
for (col in names(dt_1[-1])) {
  mean_values[[col]] <- 
    dt_1 %>%
    group_by(Country) %>%
    summarise(mean_value = mean(.data[[col]], na.rm = TRUE))
}

#View(mean_values)

dt_2 <- dt_1

for (col_name in names(mean_values)) {
  for (i in 1:nrow(dt_2)) {
    if (is.na(dt_2[i, col_name])) {
      country <- dt_2[i, "Country"]
      mean_val <- mean_values[[col_name]]
      mean_country <- mean_val[mean_val$Country == country, "mean_value"]
      dt_2[i, col_name] <- ifelse(is.na(mean_country), 0, mean_country)
    }
  }
}



# View(dt_2)
sum(is.na(dt_2))
null_counts <- colSums(is.na(dt_2))
# Display the null counts for each column
print(null_counts)

# library(ggplot2)
library(mixlm)
full = lm(Life.expectancy ~ Adult.Mortality  +              
            infant.deaths  + Alcohol  + percentage.expenditure
          + Hepatitis.B +Measles +  BMI  + under.five.deaths + Polio 
          + Total.expenditure  + Diphtheria+HIV.AIDS + GDP  
          + Population  + thinness..1.19.years + thinness.5.9.years 
          + Income.composition.of.resources + Schooling , data = dt_2)
full
summary(full)
null=lm(Life.expectancy ~1, data=dt_2)
null

# f#

forward(full, alpha = 0.05, full = TRUE)
backward(full, alpha = 0.05, full = TRUE, hierarchy = TRUE)
stepWise(full, alpha.enter = 0.05, alpha.remove = 0.05, full = TRUE)

# null=lm(MORT~1, data=dtb15)
# null

# Forward Model - MLR #
mdl_fwd = lm(Life.expectancy ~ Adult.Mortality + Income.composition.of.resources + 
               HIV.AIDS + Alcohol + Diphtheria + BMI + GDP + Polio + under.five.deaths + 
               infant.deaths + Schooling + Hepatitis.B, data = dt_2)
summary(mdl_fwd)


qf(0.05,12,2925, lower.tail = FALSE) 
# F-statistic: 488.2 on 12 and 2925 DF
# [1] 0.4351476

qf(1 - 0.05,12,2925)
# [1] 1.755477

# forward(full, alpha = 0.10, full = TRUE)
backward(full, alpha = 0.10, full = TRUE, hierarchy = TRUE)
# stepWise(full, alpha.enter = 0.10, alpha.remove = 0.10, full = TRUE)

mdl_bck_010 = lm(Life.expectancy ~ Adult.Mortality + infant.deaths + 
                   Alcohol + Hepatitis.B + BMI + under.five.deaths + Polio + 
                   Diphtheria + HIV.AIDS + GDP + thinness..1.19.years + Income.composition.of.resources + 
                   Schooling, data = dt_2)
summary(mdl_bck_010)

# forward(full, alpha = 0.15, full = TRUE)
# backward(full, alpha = 0.15, full = TRUE, hierarchy = TRUE)
# stepWise(full, alpha.enter = 0.15, alpha.remove = 0.15, full = TRUE)

mdl_final = lm(Life.expectancy ~ Adult.Mortality + infant.deaths + 
                 Alcohol + Hepatitis.B + BMI + under.five.deaths + Polio + 
                 Diphtheria + HIV.AIDS + GDP + Income.composition.of.resources + 
                 Schooling, data=dt_2)

summary(mdl_final)

root.mse=summary(mdl_final)$sigma
y1=dt_2$Life.expectancy[1]
y1.hat=mdl_final$fitted.values[1]
X=model.matrix(mdl_final)
H=X%*%(solve(t(X)%*%X)%*%t(X)) # Hat Matrix
h11=H[1,1]

press.stat = function(model1){
  e.1=(pr <- resid(model1)/(1 - lm.influence(model1)$hat))
  return(e.1)
}

#All standardized Residuals
table.residuals=data.frame(row(dt_2)[,1],dt_2$Life.expectancy,mdl_final$fitted.values,residuals(mdl_final),diag(H),rstandard(mdl_final),press.stat(mdl_final),rstudent(mdl_final),cooks.distance(mdl_final),dffits(mdl_final))
colnames(table.residuals)=c("Observations","Y","YHAT","Residual","Leverage","STUD_RES","PRESS","R_STUDENT","COOKD","DFFITS")
# View(table.residuals)

n=length(dt_2[[1]])
p=summary(mdl_final)$df[1]

df_m = n-p-1

qt(0.95,df_m) #1.645375

library(dplyr)
table.residuals %>% filter(STUD_RES >3)
table.residuals %>% filter(Leverage >3)

r_thresh <- qt(0.95,summary(mdl_final)$df[2])
r_thresh

r_std_outlier <- table.residuals %>% filter(R_STUDENT > r_thresh)
View(r_std_outlier)

n=length(dt_2[[1]])
p=summary(mdl_final)$df[1]
dffit_thresh = 2*sqrt(p / n) 


dffit_outlier <- table.residuals %>% filter(abs(DFFITS) > dffit_thresh)
View(dffit_outlier)

table.residuals %>% filter(COOKD > 1)

----------------------------------------------------------------------------------------------------------------------------------
residuals <- residuals(mdl_final)

# Compute fitted values from your linear regression model (mdl_final)
fitted_values <- fitted(mdl_final)

# Create the plot
plot(fitted_values, residuals, 
     xlab = "Fitted Values", 
     ylab = "Residuals",
     main = "Residuals vs Fitted Values Plot",
     col = "blue")

# Add a horizontal line at y = 0 for reference
abline(h = 0, col = "red", lty = 2)

# Add gridlines
grid()

# Add legend
legend("topright", legend = "Residuals", col = "blue", pch = 1)

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
# install.packages("caret")
library(caret)

# Define the training control with 10-fold cross-validation
ctrl <- trainControl(method = "cv", number = 10)

# Train the model using 10-fold cross-validation
cv_model <- train(
  Life.expectancy ~ Adult.Mortality + infant.deaths + Alcohol + Hepatitis.B +
    BMI + under.five.deaths + Polio + Diphtheria + HIV.AIDS + GDP +
    Income.composition.of.resources + Schooling,
  data = dt_2,
  method = "lm",  # Specify linear regression as the method
  trControl = ctrl
)

# Print the cross-validation results
print(cv_model)
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

#Model with thinness
    
mdl_final_thinness = lm(Life.expectancy ~ Adult.Mortality + infant.deaths + Alcohol + 
                  Hepatitis.B + BMI + under.five.deaths + Polio + Diphtheria + 
                  HIV.AIDS + GDP + thinness..1.19.years + Income.composition.of.resources + 
                  Schooling, data=dt_2)

summary(mdl_final_thinness)
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
  
library(leaps)

tmp =regsubsets(Life.expectancy ~ Adult.Mortality  +              
                  infant.deaths  + Alcohol  +   percentage.expenditure   + 
                  Hepatitis.B +Measles +  BMI  + under.five.deaths + Polio + Total.expenditure  + Diphtheria
                + HIV.AIDS + GDP  + Population  + thinness..1.19.years + thinness.5.9.years + 
                  Income.composition.of.resources + Schooling  ,data=dt_2, nbest=10,really.big=T, intercept=T)
names(summary(tmp))

(almdl=summary(tmp)[[1]]) # what is this?
(RSQ=summary(tmp)[[2]])
(SSE=summary(tmp)[[3]])
(adjR2=summary(tmp)[[4]])
(Cp=summary(tmp)[[5]])
(BIC=summary(tmp)[[6]])

fnl=cbind(almdl,SSE,RSQ,adjR2,Cp,BIC)
fnl2 = fnl[order(-adjR2),]

View(fnl2)

## The regsubsets using nbest as 15

tmp_15 =regsubsets(Life.expectancy ~ Adult.Mortality  +              
                  infant.deaths  + Alcohol  +   percentage.expenditure   + 
                  Hepatitis.B +Measles +  BMI  + under.five.deaths + Polio + Total.expenditure  + Diphtheria
                + HIV.AIDS + GDP  + Population  + thinness..1.19.years + thinness.5.9.years + 
                  Income.composition.of.resources + Schooling  ,data=dt_2, nbest=15,really.big=T, intercept=T)

names(summary(tmp_15))

(almdl=summary(tmp_15)[[1]]) # what is this?
(RSQ=summary(tmp_15)[[2]])
(SSE=summary(tmp_15)[[3]])
(adjR2=summary(tmp_15)[[4]])
(Cp=summary(tmp_15)[[5]])
(BIC=summary(tmp_15)[[6]])

fnl_15=cbind(almdl,SSE,RSQ,adjR2,Cp,BIC)
fnl2_15 = fnl_15[order(-adjR2),]

View(fnl2_15)



