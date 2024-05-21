# Life Expectancy Analysis_MLR

* The goal of the project is to predict Life Expectancy using various factors and to determine the relationship that exists between them.
* Life expectancy: the number of years that an average person can be expected to live.
* To build a MLR model, interpret the results , perform residual analysis and evaluate model performance.
* Identify key factors affecting life expectancy.


##  Multiple Linear Regression

* In practical problems, involving historical data, there is a large pool of possible independent variables which is often referred to as the variable selection problem.
* Our aim is to build a model with high R-square and less √MSE
* We use selection-type procedures to tackle the variable selection problem.
* The goal here is to determine the independent variables/regressors which have a significant impact on our target variable (Life Expectancy).
* We have applied the forward selection, backward elimination and stepwise regression procedures with the different values of 𝛼 (0.05, 0.10).

## Residual Analysis

* While building up the MLR model to predict, we have made some assumptions where the model is expected to perform well if all the assumptions are correct. Else its performance can be extremely bad.
* We check the following assumptions with help of Residual Analysis.
    * relationship between the response y and the regressors is linear.
    * The errors are normally distributed with mean 0 and constant variance. 
    * The errors are uncorrelated.

## Cross Validation

* Overall, the cross-validated linear regression model appears to perform reasonably well.
* These metrics provide insights into the performance of the linear regression model.
* An RMSE of 5.75 suggests that, on average, the model's predictions are off by approximately 5.75 units.
* An R-squared of 0.692 indicates that around 69.2% of the variance in the dependent variable is explained by the independent variables in the model.
* And an MAE of 3.57 suggests that, on average, the model's predictions are off by approximately 3.57 units.

## Final Model

* Final Model without thinness variable:

   Life.expectancy =  57.03 -  1.748e-02 * Adult.Mortality + 1.214e-01 * infant.deaths
                     	+ 4.154e-01 *Alcohol - 9.336e-03 * Hepatitis.B + 5.072e-02 *BMI 
                  -  9.207e-02 * under.five.deaths 
                  + 3.570e-02 *Polio +  4.034e-02 *Diphtheria - 5.319e-01 * HIV.AIDS 
                  + 6.870e-05 * GDP + 6.563e+00 * Income.composition.of.resources 
                  + 1.989e-01 *Schooling + Error 

* The Income Composition of Resources (Human Development Index in terms of income composition of resources (index ranging from 0 to 1) ) has more impact whereas GDP has less impact on the life expectancy.


