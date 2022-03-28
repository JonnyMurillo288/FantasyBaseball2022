## Overview

This modeling is inspired by ![(Herrlin 2015)](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Fantasy-Baseball-Models-Paper.pdf) to come up with predictions for fantasy baseball based on historical data. 

## Models

#### Home Runs
### ![yhat](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/main_yhat.jpg)

### ![beta](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/beta.jpg)

\alpha_i = prior distribution of means for clusters
### ![X](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/X-i.jpg) 
observation from previous year
Clusters come from a kmeans cluster by taking into account the batters Pull%, Three-True-Outcome% (K%+BB%+HR%), Average Exit Velocity, and Line Drive %  
### ![cluster](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/k_means_cluster.jpg)


delta_i = aging curve take from ![(Herrlin 2015)](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Fantasy-Baseball-Models-Paper.pdf)
### ![delta](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/delta_formula.jpg)

\theta_i = park factors from fangraphs OPS adjustments

EX: Coors field gets 15% reduction in y_hat_i since it is a hitter friendly park, but since Rockies players only play half their games in Coors it is adjusted accordingly, the other half has the assumption that the other parks played in average out to around league average

### ![theta](https://github.com/JonnyMurillo288/FantasyBaseball2022/blob/main/Formulas/theta.jpg)


