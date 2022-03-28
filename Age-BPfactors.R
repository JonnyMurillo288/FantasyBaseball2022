# This file holds the functions for aging curves and ball park factors

# ==================== Aging Curve =======================
age.batter <- function(age,alpha, beta_1 = -.00017, beta_2 = .00961) {
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
    if (stat == "BA_alphas") {
      tm <- team[["H"]]
    }
    res[i] <- ((tm/2) * res[i]/2) + (res[i] / 2)
  }
  return(res)
}
