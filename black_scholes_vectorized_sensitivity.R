# chart of sensitivities of Black and Scholes to Price, Underlying, Interest
# rates, and Volatility


black_scholes <- function(S, X, r, T, sigma) {
  d1 <- (log(S/X)+(r+sigma^2/2)*T)/(sigma*sqrt(T))
  d2 <- d1 - sigma * sqrt(T)
  Call <- S*pnorm(d1) - X*exp(-r*T)*pnorm(d2)
  Put <- X*exp(-r*T) * pnorm(-d2) - S*pnorm(-d1)

  return(list(call_option=round(Call,2), put_option=round(Put,2)))
}

S <- 60
S_i <- 60:80
X <- 65 
X_i <- 65:85
r <-0.08 
r_i <- seq(0, 0.1, by=0.01)
T <- 0.25 
T_i <- 1:40
sigma <- 0.3
sigma_i <- seq(0,0.4, by=0.001)

output <- black_scholes(S=S, X=X, r=r, T=T, sigma=sigma)
output_S <- black_scholes(S=S_i, X=X, r=r, T=T, sigma=sigma)
output_X <- black_scholes(S=S, X=X_i, r=r, T=T, sigma=sigma)
output_r <- black_scholes(S=S, X=X, r=r_i, T=T, sigma=sigma)
output_T <- black_scholes(S=S, X=X, r=r, T=T_i, sigma=sigma)
output_sigma <- black_scholes(S=S, X=X, r=r, T=T, sigma=sigma_i)

par(mfrow=c(2, 3))

plot(S_i, output_S$call_option, type = "l", xlab="Stock Prices", 
     ylab="Call Option Price", main="Stock Prices Progression")
grid(6,6, col="lightgray")

plot(X_i, output_X$call_option, type = "l", xlab="Strike Prices", 
     ylab="Call Option Price", main="Strike Prices Progression")
grid(6,6, col="lightgray")

plot(r_i, output_r$call_option, type = "l", xlab="Interest Rates", 
     ylab="Call Option Price", main="Interest Rates Progression")
grid(6,6, col="lightgray")

plot(T_i, output_T$call_option, type = "l", xlab="Time", 
     ylab="Call Option Price", main="Time Progression")
grid(6,6, col="lightgray")

plot(sigma_i, output_sigma$call_option, type = "l", xlab="Volatilities", 
     ylab="Call Option Price", main="Vol Progression")
grid(6,6, col="lightgray")

plot(S_i, output_S$call_option, type = "l", xlab="Stock Prices", 
     ylab="Call Option Price", main="Call & Put Prices")
lines(S_i, output_S$put_option, type="l", col="red" )
grid(6,6, col="lightgray")
