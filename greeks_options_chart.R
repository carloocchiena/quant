# ============================================================
# BLACK-SCHOLES OPTION PRICING AND GREEKS
# ============================================================

black_scholes <- function(S, X, r, T, sigma) {
  
  # Black-Scholes parameters
  d1 <- (log(S / X) + (r + sigma^2 / 2) * T) / (sigma * sqrt(T))
  d2 <- d1 - sigma * sqrt(T)
  
  # ----------------------------------------------------------
  # OPTION PRICES
  # ----------------------------------------------------------
  
  Call <- S * pnorm(d1) -
    X * exp(-r * T) * pnorm(d2)
  
  Put <- X * exp(-r * T) * pnorm(-d2) -
    S * pnorm(-d1)
  
  # ----------------------------------------------------------
  # GREEKS - CALL OPTION
  # ----------------------------------------------------------
  
  # Delta: sensitivity to underlying price
  Delta <- pnorm(d1)
  
  # Gamma: sensitivity of Delta to underlying price
  Gamma <- dnorm(d1) / (S * sigma * sqrt(T))
  
  # Vega: sensitivity to volatility
  # Division by 100 -> sensitivity to a 1 percentage point change in volatility
  Vega <- S * dnorm(d1) * sqrt(T) / 100
  
  # Theta: sensitivity to passage of time
  # Annual Theta
  Theta <- -(S * dnorm(d1) * sigma) / (2 * sqrt(T)) -
    r * X * exp(-r * T) * pnorm(d2)
  
  # Rho: sensitivity to interest rate
  # Division by 100 -> sensitivity to a 1 percentage point change in r
  Rho <- X * T * exp(-r * T) * pnorm(d2) / 100
  
  # Return results
  return(list(
    call_option = Call,
    put_option  = Put,
    delta       = Delta,
    gamma       = Gamma,
    vega        = Vega,
    theta       = Theta,
    rho         = Rho
  ))
}


# ============================================================
# INPUT PARAMETERS
# ============================================================

S <- 60
X <- 65
r <- 0.08
T <- 0.25
sigma <- 0.30


# Ranges used for sensitivity analysis

S_i <- seq(30, 100, by = 0.1)

X_i <- seq(40, 90, by = 0.1)

r_i <- seq(0.001, 0.15, by = 0.001)

T_i <- seq(0.01, 2, by = 0.01)

sigma_i <- seq(0.01, 0.60, by = 0.001)


# ============================================================
# BASE CASE
# ============================================================

output <- black_scholes(
  S = S,
  X = X,
  r = r,
  T = T,
  sigma = sigma
)

print(output)


# ============================================================
# SENSITIVITY ANALYSIS
# ============================================================

output_S <- black_scholes(
  S = S_i,
  X = X,
  r = r,
  T = T,
  sigma = sigma
)

output_X <- black_scholes(
  S = S,
  X = X_i,
  r = r,
  T = T,
  sigma = sigma
)

output_r <- black_scholes(
  S = S,
  X = X,
  r = r_i,
  T = T,
  sigma = sigma
)

output_T <- black_scholes(
  S = S,
  X = X,
  r = r,
  T = T_i,
  sigma = sigma
)

output_sigma <- black_scholes(
  S = S,
  X = X,
  r = r,
  T = T,
  sigma = sigma_i
)


# ============================================================
# OPTION PRICE SENSITIVITY CHARTS
# ============================================================

par(mfrow = c(2, 3))

# Call price vs underlying price
plot(
  S_i,
  output_S$call_option,
  type = "l",
  xlab = "Stock Price",
  ylab = "Call Option Price",
  main = "Call Price vs Stock Price"
)
grid()


# Call price vs strike price
plot(
  X_i,
  output_X$call_option,
  type = "l",
  xlab = "Strike Price",
  ylab = "Call Option Price",
  main = "Call Price vs Strike"
)
grid()


# Call price vs interest rate
plot(
  r_i,
  output_r$call_option,
  type = "l",
  xlab = "Interest Rate",
  ylab = "Call Option Price",
  main = "Call Price vs Interest Rate"
)
grid()


# Call price vs time to maturity
plot(
  T_i,
  output_T$call_option,
  type = "l",
  xlab = "Time to Maturity",
  ylab = "Call Option Price",
  main = "Call Price vs Time"
)
grid()


# Call price vs volatility
plot(
  sigma_i,
  output_sigma$call_option,
  type = "l",
  xlab = "Volatility",
  ylab = "Call Option Price",
  main = "Call Price vs Volatility"
)
grid()


# Call and Put prices vs underlying price
plot(
  S_i,
  output_S$call_option,
  type = "l",
  xlab = "Stock Price",
  ylab = "Option Price",
  main = "Call and Put Prices"
)

lines(
  S_i,
  output_S$put_option,
  col = "red"
)

legend(
  "topright",
  legend = c("Call", "Put"),
  col = c("black", "red"),
  lty = 1,
  bty = "n"
)

grid()


# ============================================================
# GREEKS VS UNDERLYING PRICE
# ============================================================

par(mfrow = c(2, 3))


# DELTA
plot(
  S_i,
  output_S$delta,
  type = "l",
  col = "magenta",
  xlab = "Stock Price",
  ylab = "Delta",
  main = "Call Delta"
)

abline(v = X, lty = 2)
grid()


# GAMMA
plot(
  S_i,
  output_S$gamma,
  type = "l",
  col = "magenta",
  xlab = "Stock Price",
  ylab = "Gamma",
  main = "Call Gamma"
)

abline(v = X, lty = 2)
grid()


# VEGA
plot(
  S_i,
  output_S$vega,
  type = "l",
  col = "magenta",
  xlab = "Stock Price",
  ylab = "Vega",
  main = "Call Vega"
)

abline(v = X, lty = 2)
grid()


# THETA
plot(
  S_i,
  output_S$theta,
  type = "l",
  col = "magenta",
  xlab = "Stock Price",
  ylab = "Theta",
  main = "Call Theta"
)

abline(v = X, lty = 2)
grid()


# RHO
plot(
  S_i,
  output_S$rho,
  type = "l",
  col = "magenta",
  xlab = "Stock Price",
  ylab = "Rho",
  main = "Call Rho"
)

abline(v = X, lty = 2)
grid()


# Empty sixth panel
plot.new()

title(
  main = paste(
    "Black-Scholes Greeks\n",
    "K =", X,
    "| T =", T,
    "| sigma =", sigma,
    "| r =", r
  )
)


# ============================================================
# RESET GRAPHICAL PARAMETERS
# ============================================================

par(mfrow = c(1, 1))
