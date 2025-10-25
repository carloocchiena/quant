# ============================
# Shannon's Demon 
# 1 Asset GBM + Cash (r_f = 0), Rebalance target 40/60
# ============================

set.seed(25102025)

# Parameters
T_years <- 1 
n_days <- 252 
dt <- T_years / n_days
S0 <- 100             # initial asset value  
mu <- 0.05            # drift
sigma <- 0.25         # vol
rf <- 0.05            # risk free rate                  
W0 <- 100             # initial wealth 
f <- 0.6              # target on risky asset              
do_plot <- TRUE

# Geometric Brownian Motion for asset value
Z <- rnorm(n_days)
S <- numeric(n_days + 1); S[1] <- S0
for (t in 1:n_days) {
  S[t + 1] <- S[t] * exp((mu - 0.5 * sigma^2) * dt + sigma * sqrt(dt) * Z[t])
}

#  Buy & Hold for benchmarking 
cash_BH   <- (1 - f) * W0
shares_BH <- (f * W0) / S0
W_BH <- shares_BH * S + cash_BH * (1 + rf * (0:n_days) * dt)  

# Daily rebalance to f value
W_RB <- numeric(n_days + 1)
W_RB[1] <- W0
cash_RB <- (1 - f) * W0
shares_RB <- (f * W0) / S0

for (t in 1:n_days) {
  
  cash_RB <- cash_RB * (1 + rf * dt)
  W_RB[t + 1] <- shares_RB * S[t + 1] + cash_RB
  
  target_risky_value <- f * W_RB[t + 1]
  shares_RB <- target_risky_value / S[t + 1]
  cash_RB   <- (1 - f) * W_RB[t + 1]
}

# KPIs
cumret_BH <- tail(W_BH,1)/W_BH[1] - 1
cumret_RB <- tail(W_RB,1)/W_RB[1] - 1

CAGR <- function(v) (tail(v,1)/head(v,1))^(1/T_years) - 1
cagr_BH <- CAGR(W_BH); cagr_RB <- CAGR(W_RB)

delta_final <- tail(W_RB, 1) - tail(W_BH, 1)
delta_pct   <- delta_final / tail(W_BH, 1) * 100

cat("=== Results (1 asset + cash) ===\n")
cat(sprintf("Buy&Hold cum. return: %6.2f%%   CAGR: %5.2f%%\n", 100*cumret_BH, 100*cagr_BH))
cat(sprintf("Rebalance cum. return: %6.2f%%   CAGR: %5.2f%%\n", 100*cumret_RB, 100*cagr_RB))

# Charts
if (do_plot) {
  oldpar <- par(no.readonly = TRUE); on.exit(par(oldpar))
  par(mfrow = c(2, 2), mar = c(4, 4, 2, 1), bg = "white")
  
  # Chart 1: Simulated asset value
  plot(S,
       type = "l", lwd = 2, col = "#0072B2",
       xlab = "Days", ylab = "Price",
       main = "Asset value (GBM)")
  grid(col = "gray80")
  box(col = "gray50")
  
  # Chart 2: Buy&Hold vs Rebalance
  plot(W_BH,
       type = "l", lwd = 2, col = "#E69F00",
       xlab = "Days", ylab = "Wealth",
       main = "Wealth: Buy & Hold vs Rebalance",
       ylim = range(c(W_BH, W_RB)))
  lines(W_RB, lwd = 2, col = "#009E73")
  grid(col = "gray80")
  box(col = "gray50")
  
  legend("topleft",
         legend = c("Buy & Hold", "Rebalance"),
         col = c("#E69F00", "#009E73"),
         lwd = 2, bty = "n", cex = 0.9)
  
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