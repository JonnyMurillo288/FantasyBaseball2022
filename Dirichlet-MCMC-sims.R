# This file holds the code to run the MCMC processes
# Automatically updates the bref object

library(rjags)
library(DirichletReg)


# ================= MCMC processes ===================

model.string <- "Models/Dirichlet-Batting"

# Create the outs, and singles
bref$X1B <- bref$H - bref$X2B - bref$X3B - bref$HR
bref$Outs <- bref$PA.x - (bref$HR+bref$SO+bref$X2B+bref$X3B+bref$X1B)


# Start with inits
outcomes <- c("HR","BB","X1B","X2B","X3B","SO","Outs","hitter.cluster")
data.for.model <- bref[outcomes]
mu <- matrix(nrow=nclust,ncol=7)
std <- matrix(nrow=nclust,ncol=7)
X <- matrix(nrow=nrow(bref),ncol=7)

for (i in 1:nclust) {
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

data.jags <- list(N=nrow(X),mu=mu,sd=std,hitter.clusters=data.for.model$hitter.cluster,nclust=nclust)
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
