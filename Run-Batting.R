# Run the dirichlet for all outcomes to view how a batter will do with all types of 
# outcomes, based on the paper https://madison.byu.edu/papers/final.pdf
# For more information look at noetbook page 69

# 1. Cluster batters through K-means, minimizing WSS 
# 2. Create Aging curve for each stat (use historical data from rbaseball)
# 3. Find BP factors from year to year ****
# 4. MCMC sample the alphas ~ N(theta,sig2) for final dirichlet through LA effects within groups
# 5. Sample theta and sig2 from within group means and SD
# 6. y-hat_i ~ Dir((alpha+X_hr)_HR,(alpha+X_bb)_BB,...(alpha+X_out)_Out)

source("./Age-BPfactors.R")


# =================== Clustering HR and adjusting by AGE and BP =======================
nclust <- 5

bref$TTO <- bref$HR. + bref$BB. + bref$SO.
bref <- bref[bref$TTO!=0,]
bref <- drop_na(bref,c("EV","TTO","Pull.","LD.","ISO"))
bref <- bref[bref$PA.x >100, ] # Drop players with under 100 PA
clst.dta <- bref[c("EV","TTO","Pull.","LD.","ISO")]

bref$hitter.cluster<- kmeans(scale(clst.dta),nclust,nstart=35)$cluster

source("./Dirichlet-MCMC-sims.R")

# RUN THE ADJUSTMENTS FOR AGE AND BALLPARK FACTORS
orig <- bref$HR_alphas
bref$HR_alphas <- age.batter(bref$Age.x,bref$HR_alphas)
adj.df <- bp.factors[c("Team","HR")]
bref$HR_alphas <- bp.adj(bref[c("Tm","HR_alphas")],adj.df,"HR_alphas")

bref$BA_alphas <- 1 - (bref$SO_alphas+bref$Outs_alphas)
bref$BA_alphas <- age.batter(bref$Age.x,bref$BA_alphas)
adj.df <- bp.factors[c("Team","H")]
bref$BA_alphas <- bp.adj(bref[c("Tm","BA_alphas")],adj.df,"BA_alphas")

bref$X2B_alphas <- age.batter(bref$Age.x,bref$X2B_alphas)
adj.df <- bp.factors[c("Team","X2B")]
bref$X2b_alphas <- bp.adj(bref[c("Tm","X2B_alphas")],adj.df,"X2B_alphas")

bref$X3B_alphas <- age.batter(bref$Age.x,bref$X3B_alphas)
adj.df <- bp.factors[c("Team","X3B")]
bref$X2B_alphas <- bp.adj(bref[c("Tm","X3B_alphas")],adj.df,"X3B_alphas")

bref$BB_alphas <- age.batter(bref$Age.x,bref$BB_alphas)
adj.df <- bp.factors[c("Team","BB")]
bref$BB_alphas <- bp.adj(bref[c("Tm","BB_alphas")],adj.df,"BB_alphas")




write.csv(bref,"Batter-Dirichlet.csv")


