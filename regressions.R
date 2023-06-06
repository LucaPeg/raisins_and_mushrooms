library(dplyr)
library(tidyverse)
library(tidymodels)
library(glmnet)
library(estimatr)
library(stats)
library(tree)
library(maxLik)

# load the dataset
# Class = 1 if raisin is of Kecimen type, 0 if it is Besni
raisins = read.csv(
  "https://raw.githubusercontent.com/LeonardoAcquaroli/raisins_and_mushrooms/main/datasets/Raisin_Dataset.csv",
  sep = ";"
)
# remove the column of the literal class
#raisins = raisins %>% select(-Class_literal) # don't know why it doesn't work
raisins = raisins[,-8]
raisins$Class = as.factor(raisins$Class)
#raisins$Area = raisins$Area/1000 # scale Area by 1000 for better interpretability. Recall Area is the n. of pixel inside the boundaries of the raisin

# mse function
mse = function(model,data,y){
  residuals = (fitted(model) - (data[c(y)]))
  mse = (1/nrow(data))*sum((residuals^2))
  return(mse)
}

# 1. ols
ols = lm("Class ~ .", data = raisins)
summary(ols)
hist(fitted(ols)) #fitted(ols) == predict.lm(ols)
ols_predictions = fitted(ols)
coef(ols)
mse(ols, raisins,"Class")

# 2. robust ols
ols_robust = lm_robust(Class ~ ., data = raisins, se_type = "HC1")
summary(ols_robust)
## Robust ols with rlm by MASS
#summary(rlm(Class ~ ., raisins))
mse(ols_robust, raisins,"Class")

# 3. Logistic
logistic = glm(Class ~ ., data = raisins, family = binomial(link = 'logit'))
logistic_params = coef(logistic)
tidy(logistic)
hist(predict.glm(logistic, type = "response"))
hist(fitted(logistic))
#logistic by hand
ols_fitted2 = (logistic_params[1]*rep(1,nrow(raisins)) + logistic_params[2]*raisins[,1] + logistic_params[3]*raisins[,2] + logistic_params[4]*raisins[,3] + logistic_params[5]*raisins[,4] + logistic_params[6]*raisins[,5] + logistic_params[7]*raisins[,6] + logistic_params[8]*raisins[,7])
hist(logistic3)
mse(logistic, raisins,"Class")

# 4. Ridge
# 5. Lasso
# 6. Tree
plot(tree(Class ~ ., data = raisins))
text(tree(Class ~ ., data = raisins))