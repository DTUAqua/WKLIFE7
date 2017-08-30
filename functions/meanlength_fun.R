######### Yield per recruit functions
# Get the yield per recruit as a function of F
get_YPR <- function(F_mort, Linf, K, Lc, M, wla, wlb) {
  Z <- F_mort + M
  Winf <- wla * Linf ^ wlb
  biomass <- (Winf/K) * beta(wlb+1, Z/K) * (1 - pbeta(Lc/Linf, wlb+1, Z/K)) * 
    (1 - Lc/Linf)^(Z/K)
  return(F_mort * biomass)
}

# Calculate the derivative of the YPR with respect to F, i.e. dY/dF
get_deriv <- function(F_mort, Linf, K, Lc, M, wla, wlb) {
  numDeriv::grad(get_YPR, x = F_mort, Linf = Linf, K = K, Lc = Lc, M = M, 
                 wla = wla, wlb = wlb)
}

F01_rootfinder <- function(F_mort, Linf, K, Lc, M, wla, wlb) {
  slope.origin <- get_deriv(F_mort = 0, Linf = Linf, K = K, Lc = Lc, M = M, 
                            wla = wla, wlb = wlb)
  slope.F <- get_deriv(F_mort = F_mort, Linf = Linf, K = K, Lc = Lc, M = M, 
                       wla = wla, wlb = wlb)
  slope.F - 0.1 * slope.origin
}

get_F01 <- function(Linf, K, Lc, M, wla, wlb, maxF = 3) {
  uniroot(F01_rootfinder, interval = c(1e-3, maxF), Linf = Linf, K = K, Lc = Lc, M = M, 
          wla = wla, wlb = wlb)$root
}

# Loops through 0 - 3 changes in mortality
model_select_GH <- function(mlen, ss = rep(1, length(mlen)), K, Linf, Lc) {
  mlen[mlen <= 0 | is.na(mlen)] <- -99
  ss[mlen == -99] <- 0
  
  stpar <- 0.5
  res0 <- try(optim(stpar, GHeq_LL, method = "BFGS", 
                    Lbar = mlen, ss = ss,
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res0, 'try-error')) aic0 <- NA
  else aic0 <- 2 * (res0$value + 2)
  
  stpar <- c(0.5, length(mlen)/2)
  res1 <- try(optim(stpar, DLMtool:::bhnoneq_LL, method = "BFGS", 
                    year = 1:length(mlen), Lbar = mlen, ss = ss, nbreaks = 1, 
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res1, 'try-error')) aic1 <- NA
  else aic1 <- 2 * (res1$value + 4)
  
  stpar <- c(rep(0.5, 2), c(1, 2) * length(mlen)/3)
  res2 <- try(optim(stpar, DLMtool:::bhnoneq_LL, method = "BFGS", 
                    year = 1:length(mlen), Lbar = mlen, ss = ss, nbreaks = 2, 
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res2, 'try-error')) aic2 <- NA
  else aic2 <- 2 * (res2$value + 6)
  
  stpar <- c(rep(0.5, 3), c(1, 2, 3) * length(mlen)/4)
  res3 <- try(optim(stpar, DLMtool:::bhnoneq_LL, method = "BFGS", 
                    year = 1:length(mlen), Lbar = mlen, ss = ss, nbreaks = 3, 
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res3, 'try-error')) aic3 <- NA
  else aic3 <- 2 * (res3$value + 8)
  
  testvec <- c(aic0, aic1, aic2, aic3)
  if(all(is.na(testvec))) Z.ans <- NA
  else {
    index.best.nbreak <- which.min(testvec)
    best.model <- get(paste0('res', index.best.nbreak - 1))
    Z.ans <- best.model$par[index.best.nbreak]
  }
  return(Z.ans)
}

model_select_GH <- function(mlen, ss = rep(1, length(mlen)), K, Linf, Lc) {
  mlen[mlen <= 0 | is.na(mlen)] <- -99
  ss[mlen == -99] <- 0
  
  stpar <- 0.5
  res0 <- try(optim(stpar, GHeq_LL, method = "BFGS", 
                    Lbar = mlen, ss = ss,
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res0, 'try-error')) aic0 <- NA
  else aic0 <- 2 * (res0$value + 2)
  
  stpar <- c(0.5, length(mlen)/2)
  res1 <- try(optim(stpar, DLMtool:::bhnoneq_LL, method = "BFGS", 
                    year = 1:length(mlen), Lbar = mlen, ss = ss, nbreaks = 1, 
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res1, 'try-error')) aic1 <- NA
  else aic1 <- 2 * (res1$value + 4)
  
  stpar <- c(rep(0.5, 2), c(1, 2) * length(mlen)/3)
  res2 <- try(optim(stpar, DLMtool:::bhnoneq_LL, method = "BFGS", 
                    year = 1:length(mlen), Lbar = mlen, ss = ss, nbreaks = 2, 
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res2, 'try-error')) aic2 <- NA
  else aic2 <- 2 * (res2$value + 6)
  
  stpar <- c(rep(0.5, 3), c(1, 2, 3) * length(mlen)/4)
  res3 <- try(optim(stpar, DLMtool:::bhnoneq_LL, method = "BFGS", 
                    year = 1:length(mlen), Lbar = mlen, ss = ss, nbreaks = 3, 
                    K = K, Linf = Linf, Lc = Lc, control = list(maxit = 1e+06), 
                    hessian = FALSE), silent = TRUE)
  if(inherits(res3, 'try-error')) aic3 <- NA
  else aic3 <- 2 * (res3$value + 8)
  
  testvec <- c(aic0, aic1, aic2, aic3)
  if(all(is.na(testvec))) Z.ans <- NA
  else {
    index.best.nbreak <- which.min(testvec)
    best.model <- get(paste0('res', index.best.nbreak - 1))
    Z.ans <- best.model$par[index.best.nbreak]
  }
  return(Z.ans)
}
