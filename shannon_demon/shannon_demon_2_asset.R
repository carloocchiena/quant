# ============================
# Shannon's Demon 
# 2 Asset GBM Rebalance
# ============================

set.seed(25102025)

# Parameters
T_years   <- 1
n_days    <- 252 * 1         # years multiplier 
dt        <- T_years / n_days
S0        <- c(100, 100)     # initial values
mu        <- c(0.00, 0.00)   # drift ~ 0 
sigma     <- c(0.20, 0.20)   # assets vol
rho       <- 0.05            # assets correlation
W0        <- 100             # initial wealth
w_target  <- c(0.5, 0.5)     # target weight
do_plot   <- TRUE

# Gaussian shocks generator
# Z ~ N(0, I), Cholesky correlation matrix
Z <- matrix(rnorm(2 * n_days), ncol = 2)
L <- chol(matrix(c(1, rho, rho, 1), 2, 2))
Zc <- Z %*% L

# Geometric Brownian Motion for assets value
S <- matrix(NA, nrow = n_days + 1, ncol = 2)
S[1, ] <- S0
for (t in 1:n_days) {
  for (i in 1:2) {
    S[t + 1, i] <- S[t, i] * exp((mu[i] - 0.5 * sigma[i]^2) * dt +
                                   sigma[i] * sqrt(dt) * Zc[t, i])
  }
}

# Buy & Hold for benchmarking
shares_BH <- (W0 * w_target) / S0
W_BH <- rowSums(S * rep(shares_BH, each = nrow(S)))

# Daily rebalance to w_target value
W_RB <- numeric(n_days + 1)
W_RB[1] <- W0
shares_RB <- (W0 * w_target) / S0

for (t in 1:n_days) {
  
  W_RB[t + 1] <- sum(shares_RB * S[t + 1, ])
  shares_RB <- (W_RB[t + 1] * w_target) / S[t + 1, ]
}

# KPIs
cumret_asset <- S[n_days + 1, ] / S[1, ] - 1
cumret_BH    <- W_BH[n_days + 1] / W_BH[1] - 1
cumret_RB    <- W_RB[n_days + 1] / W_RB[1] - 1

CAGR <- function(v) (tail(v, 1) / head(v, 1))^(1 / T_years) - 1
cagr_BH <- CAGR(W_BH)
cagr_RB <- CAGR(W_RB)

delta_final <- tail(W_RB, 1) - tail(W_BH, 1)
delta_pct   <- delta_final / tail(W_BH, 1) * 100

cat("=== Results (2 asset) ===\n")
cat(sprintf("Asset 1  cum. return: %6.2f%%\n", 100 * cumret_asset[1]))
cat(sprintf("Asset 2  cum. return: %6.2f%%\n", 100 * cumret_asset[2]))
cat(sprintf("Buy&Hold cum. return: %6.2f%%   CAGR: %5.2f%%\n", 100 * cumret_BH, 100 * cagr_BH))
cat(sprintf("Rebalance cum. return: %5.2f%%   CAGR: %5.2f%%\n", 100 * cumret_RB, 100 * cagr_RB))

# Charts
if (do_plot) {
  oldpar <- par(no.readonly = TRUE); on.exit(par(oldpar))
  par(mfrow = c(2, 2), mar = c(4, 4, 2, 1), bg = "white")
  
  # Okabe–Ito colors
  col1 <- "#0072B2"  # blu
  col2 <- "#D55E00"  # arancio
  colBH <- "#E69F00" # giallo scuro
  colRB <- "#009E73" # verde
  colGrid <- "gray85"
  
  # Chart 1) Asset value (2 asset GBM)
  plot(S[,1], type = "l", lwd = 2, col = col1,
       xlab = "Days", ylab = "Price", main = "Assets value (GBM)")
  lines(S[,2], lwd = 2, col = col2)
  grid(col = colGrid, lty = 2); box(col = "gray50")
  legend("topleft", bty = "n", cex = 0.9,
         legend = c("Asset 1","Asset 2"), col = c(col1,col2), lwd = 2)
  
  # Chart 2) Wealth: Buy&Hold vs Rebalance
  rng <- range(c(W_BH, W_RB))
  plot(W_BH, type = "l", lwd = 2, col = colBH,
       xlab = "Days", ylab = "Wealth",
       main = "Wealth: Buy & Hold vs Rebalance", ylim = rng)
  lines(W_RB, lwd = 2, col = colRB)
  grid(col = colGrid, lty = 2); box(col = "gray50")
  legend("topleft", bty = "n", cex = 0.9,
         legend = c("Buy & Hold","Rebalance"), col = c(colBH,colRB), lwd = 2)
  
  # Chart 3: Wealth Delta 
  plot(W_RB - W_BH, type="l", col="#D55E00", lwd=2,
       xlab="Days", ylab="Δ Wealth (RB - BH)",
       main="Δ Rebalance vs Buy&Hold")
  abline(h=0, col="gray60", lty=2) 
  
  # Chart 4: O
  vals <- c(W_BH_end = tail(W_BH, 1),
            W_RB_end = tail(W_RB, 1))
  names(vals) <- c("Buy & Hold", "Rebalance")
  bar_colors <- c("#E69F00", "#009E73")
  
  bar_pos <- barplot(vals,
                     col = bar_colors,
                     border = NA,
                     main = "Wealth comparison",
                     ylab = "Wealth",
                     ylim = c(0, max(vals) * 1.15))
  grid(col = "gray85", lty = 2)
  
  text(bar_pos, vals, labels = round(vals, 2), pos = 3, cex = 0.9)
  
  mtext(sprintf("Δ = %.1f  (%.1f%%)", delta_final, delta_pct),
        side = 3, line = -1, cex = 0.9, col = "gray30")
  
}