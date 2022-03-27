# Run the dirichlet for all outcomes to view how a batter will do with all types of 
# outcomes, based on the paper https://madison.byu.edu/papers/final.pdf
# For more information look at noetbook page 69

# 1. Cluster batters through K-means, minimizing WSS 
# 2. Create Aging curve for each stat (use historical data from rbaseball)
# 3. Find BP factors from year to year ****
# 4. MCMC sample the alphas ~ N(theta,sig2) for final dirichlet through LA effects within groups
# 5. Sample theta and sig2 from within group means and SD
# 6. y-hat_i ~ Dir((alpha+X_hr)_HR,(alpha+X_bb)_BB,...(alpha+X_out)_Out)

library(rjags)
library(DirichletReg)

# =================== Clustering =======================

bref$TTO <- bref$HR. + bref$BB. + bref$SO.
bref <- drop_na(bref[bref$TTO>0,])
clst.dta <- bref[c("EV","TTO","Pull.","LD.")]
bref$hitter.cluster<- kmeans(scale(drop_na(clst.dta[clst.dta$TTO>0,])),3,nstart=35)$cluster

# ==================== Aging Curve =======================
age.hr <- function(age,alpha, beta_1 = -.00017, beta_2 = .00961) {
  y = alpha + beta_1*age^2 + beta_2*age
  return(y)
}
#plot(seq(20,45,1),age.hr(seq(20,45,1),.05))
#abline(v=29)

# ================= BP factors =======================
bp.factors <- read.csv("bp_factors.csv")
bp.adj <- function(x,adj.df,stat) { # Input x = df with stat to adjust and team, adj.df is adjustment df, stat = stat to adjust
  res <- x[[stat]]
  teams.for.x <- x$Tm
  for (i in 1:nrow(x)) {
    team <- adj.df[adj.df$Team == as.character(teams.for.x[i]),] # Needs adjustment fro actual variable names
    tm <- team[[strsplit(stat,"_")[[1]][1]]]
    res[i] <- ((tm/2) * res[i]/2) + (res[i] / 2)
  }
  return(res)
}



# ================= MCMC processes ===================

model.string <- "Models/Dirichlet-Batting"

# Create the outs, and singles
bref$X1B <- bref$H - bref$X2B - bref$X3B - bref$HR
bref$Outs <- bref$PA.x - (bref$HR+bref$SO+bref$X2B+bref$X3B+bref$X1B)


# Start with inits
outcomes <- c("HR","BB","X1B","X2B","X3B","SO","Outs","hitter.cluster")
data.for.model <- bref[outcomes]
mu <- matrix(nrow=3,ncol=7)
std <- matrix(nrow=3,ncol=7)
X <- matrix(nrow=nrow(bref),ncol=7)

for (i in 1:3) {
  for (j in 1:7) {
    v <- as.numeric(lapply(data.for.model[data.for.model$hitter.cluster==i,j],sd))
    mu[i,j] <- sum(data.for.model[data.for.model$hitter.cluster==i,j],na.rm=T)/nrow(data.for.model)
    std[i,j] <- v
    
  }
}
for (i in 1:nrow(data.for.model)) {
  res <- data.for.model[i,]/sum(data.for.model[i,])
  for (j in 1:7) {
    X[i,j] <- as.numeric(res[j])
  }
}

data.jags <- list(N=nrow(X),mu=mu,sd=std,hitter.clusters=data.for.model$hitter.cluster)
mod <- jags.model(model.string,data=data.jags,n.chains = 1)
update(mod,1e3)

set.seed(as.numeric(Sys.time()))

params <- c("mu","sd","theta","sig","alpha")

mod_sim = jags.samples(model=mod,variable.names = params,n.iter = 3e3)
res <- summary(mod_sim$alpha,mean)
res_alphas <- res$stat
for (i in 1:7) {
  bref[,paste(outcomes[i], "_alphas",sep="")] <-res_alphas[,i]
}

alphas_outcomes <- c(paste(outcomes[1:7], "_alphas",sep=""))

for (i in 1:nrow(bref)) {
  obs <- bref[i,outcomes[1:7]]
  bref[i,alphas_outcomes] <- as.list(colMeans(rdirichlet(5000,as.numeric(res_alphas[i,]+obs))))
}


#write.csv(bref,"Batter-Dirichlet.csv")

# RUN THE ADJUSTMENTS FOR AGE AND BALLPARK FACTORS
orig <- bref$HR_alphas
bref$HR_alphas <- age.hr(bref$Age.x,bref$HR_alphas)
adj.df <- bp.factors[c("Team","HR")]
bref$HR_alphas <- bp.adj(bref[c("Tm","HR_alphas")],adj.df,"HR_alphas")
mean(abs(bref$HR_alphas - orig))

