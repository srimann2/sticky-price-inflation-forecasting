setwd("~/Downloads")

library(ts575unc)
library(tseries)
library(FinTS)
library(rugarch)

data<-read.csv("CORESTICKM159SFRBATL.csv")
names(data) <- c("date", "value")

st_out <- seas.trend(sticky, seas_or_trend = "both", freq = "monthly", trend_type = "linear")

y_sa_dt <- st_out$y_st 
model_info <- st_out$model

plot(sticky, main="Original vs Deseasonalized Inflation", ylab="")
lines(y_sa_dt, col="blue")
legend("topleft", legend=c("Original","Seasonally Adj & Detrended"), col=c("black","blue"), lty=1)

adf.test(y_sa_dt)

save(y_sa_dt, file = "sticky_cleaned.RData")

load("sticky_cleaned.RData")

pmax <- 4
qmax <- 4

out <- arma.pq.select(y_sa_dt, pmax = pmax, qmax = qmax, constant = TRUE, bootN = 1000)

print(out)

p_star <- 2
q_star <- 1
save(y_sa_dt, p_star, q_star, file = "arma_selection_results.RData")


load("arma_selection_results.RData") 


p_star; q_star

fout <- farmax.roll(y_sa_dt, p = p_star, d = 0, q = q_star, w = NULL, constant = TRUE,  x = NULL)

print(fout)
save(fout, file = "farmax_fullsample_results.RData")

 est <- c(1.9064, -0.9137, -0.7579, 0.0291)
 se  <- c(0.0392, 0.0388, 0.0583, 0.1683)
 tvals <- est / se
 tvals

 ehat <- fout$ehat
 Box.test(ehat, lag = 12, type = "Ljung-Box", fitdf = p_star + q_star)

	
R2 <- 1 - (var(ehat) / var(y_sa_dt))
R2

 load("farmax_fullsample_results.RData") 
 load("arma_selection_results.RData") 

ehat <- fout$ehat
Qtest <- Box.test(ehat, lag = 12, type = "Ljung-Box", fitdf = p_star + q_star)

Qtest

ArchTest(ehat, lags = 12)

save(ehat, Qtest, file="arma_residual_tests.RData")

fit21 <- arima(y_sa_dt, order = c(2,0,1), include.mean = TRUE)
summary(fit21)

ehat <- residuals(fit21)

plot(ehat, type="l", main="Residuals from ARMA(2,1)", ylab="")

acf(ehat, main="ACF of Residuals")
pacf(ehat, main="PACF of Residuals")
acf(ehat^2, main="ACF of Squared Residuals (ARCH Check)")

ArchTest(ehat, lags = 12)

Box.test(ehat, lag=1, type="Ljung")
Box.test(ehat, lag=5, type="Ljung")

rolling_msfe_safe <- function(series, p, q, window = 180, min_success = 10, fallback = c(1,0)) {
n <- length(series)
errors <- numeric(0)
success_count <- 0
fail_count <- 0

for (i in (window+1):n) {
train <- series[(i-window):(i-1)]
test_val <- series[i]

# try ML arima first, with increased iter control
fit <- tryCatch(
arima(train, order = c(p,0,q), include.mean = TRUE, method = "ML", optim.control = list(maxit = 2000)),
error = function(e) e,
warning = function(w) w
)

fit2 <- tryCatch(
arima(train, order = c(fallback[1],0,fallback[2]), include.mean = TRUE, method = "ML"),
error = function(e) e,
warning = function(w) w
)
if (inherits(fit2, "error") || inherits(fit2, "warning")) {
fail_count <- fail_count + 1
next # skip this window
} else {
fit <- fit2
}
}

pred <- tryCatch(predict(fit, n.ahead = 1)$pred, error = function(e) NA)
if (is.na(pred)) { fail_count <- fail_count + 1; next }

errors <- c(errors, (test_val - pred))
success_count <- success_count + 1
}

if (length(errors) < min_success) {
warning("Too few successful forecasts. Consider increasing series length or lowering window.")
}
list(MSFE = mean(errors^2), M = length(errors), successes = success_count, fails = fail_count)
}

msfe_21_safe <- rolling_msfe_safe(y_sa_dt, 2, 1, window = 180)
msfe_11_safe <- rolling_msfe_safe(y_sa_dt, 1, 1, window = 180)
msfe_20_safe <- rolling_msfe_safe(y_sa_dt, 2, 0, window = 180)
msfe_31_safe <- rolling_msfe_safe(y_sa_dt, 3, 1, window = 180)

msfe_21_safe; msfe_11_safe; msfe_20_safe; msfe_31_safe

y <- y_sa_dt
H <- 12
n <- length(y)

train <- window(y, end = c(1990 + (n-H-1)/12))
true_values <- window(y, start = c(1990 + (n-H)/12))

fit_21 <- Arima(train, order = c(2,0,1), include.mean = TRUE)

fc <- forecast(fit_21, h = H)


plot(fc, main="Forecasts vs True Values (ARMA(2,1))",
ylab="Inflation", xlab="Time")

lines(true_values, col="black", lwd=2)
legend("topleft",
legend=c("Forecast", "True Values"),
col=c("blue", "black"),
lty=1, lwd=2)

y <- y_sa_dt
fit_21 <- Arima(y, order = c(2,0,1), include.mean = TRUE)
fc_12 <- forecast(fit_21, h = 12)
plot(fc_12, main = "12-Month Ahead Forecasts (ARMA(2,1))", ylab = "Inflation", xlab = "Time")

y <- y_sa_dt


H <- 12

n <- length(y)
train <- y[1:(n - H)] # all data before last 12 months
true_vals <- y[(n - H + 1):n] # actual observed last 12 months


fit_21 <- Arima(train, order = c(2,0,1), include.mean = TRUE)


fc_vals <- rep(NA, H)

for (i in 1:H) {

fit <- Arima(y[1:(n - H + i - 1)], order = c(2,0,1), include.mean = TRUE)
fc_vals[i] <- forecast(fit, h = 1)$mean
}


plot(true_vals, type="l", lwd=2, col="black",
main="1-Step Ahead Forecasts vs True Values",
ylab="Inflation", xlab="Prediction Month")
lines(fc_vals, col="blue", lwd=2)
legend("topleft",
legend=c("True Values","Forecasts"),
col=c("black","blue"),
lty=1, lwd=2)

y_std <- scale(y_sa_dt)



spec <- ugarchspec(
variance.model = list(model = "sGARCH",
garchOrder = c(1,1)),
mean.model = list(armaOrder = c(2,1),
include.mean = TRUE),
distribution.model = "norm"
)

fit_garch <- ugarchfit(
  spec = spec,
  data = y_std,
  solver = "hybrid",
  solver.control = list(trace = 0)
)


show(fit_garch)

coef(fit_garch)
infocriteria(fit_garch) # AIC, BIC
sigma(fit_garch) # conditional variance
residuals(fit_garch)

plot(sigma(fit_garch), main="Estimated Conditional Volatility (GARCH(1,1))")

garch_forecast <- ugarchforecast(fit_garch, n.ahead = 12)


garch_mu <- as.numeric(fitted(garch_forecast))


garch_sd <- as.numeric(sigma(garch_forecast))


upper_95 <- garch_mu + 1.96 * garch_sd
lower_95 <- garch_mu - 1.96 * garch_sd


garch_table <- data.frame(
MonthAhead = 1:12,
Forecast = garch_mu,
Lower95 = lower_95,
Upper95 = upper_95
)

print(garch_table)

t0 <- length(y_sa_dt)
future_index <- (t0+1):(t0+12)


plot(y_sa_dt[(t0-60):t0], type="l", col="black", lwd=2,
main="12-Step Ahead Forecasts (ARMA-GARCH)",
ylab="Inflation", xlab="Time")


lines(future_index, garch_mu, type="l", col="blue", lwd=2)


lines(future_index, upper_95, col="gray40", lty=2, lwd=1.5)
lines(future_index, lower_95, col="gray40", lty=2, lwd=1.5)


polygon(
c(future_index, rev(future_index)),
c(upper_95, rev(lower_95)),
col=adjustcolor("gray80", alpha.f=0.4), border=NA
)

legend("topleft",
legend=c("True Data", "GARCH Forecast", "95% CI"),
col=c("black","blue","gray40"),
lty=c(1,1,2), lwd=2, bty="n")




