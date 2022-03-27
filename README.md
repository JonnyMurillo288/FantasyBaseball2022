## Overview

This modeling is inspired by (INSERT PAPERS) to come up with predictions for fantasy baseball based on historical data. 

### Models

##### Home Runs
#![yhat](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/main_yhat.jpg)


$\beta_i = Dirichlet(alpha_i_hr + x_i_hr,...)

alpha_i_hr = prior distribution of means for clusters
x_i_hr = mean observed hr% for the individual observation

delta_i = aging curve take from (INSERT PAPERS) 
delta_i_hr = -.00015 * Age^2 + .00961 * Age + x_i_hr

theta_i = park factors from fangraphs OPS adjustments
EX: Coors field gets 15% reduction in y_hat_i since it is a hitter friendly park, but since Rockies players only play half their games in Coors it is adjusted accordingly, the other half has the assumption that the other parks played in average out to around league average

theta_i = (gamma_i/2) * HR + HR / 2

gamma_i = home park

