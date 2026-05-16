# Sticky Price Inflation Forecasting

## Project Overview

This project analyzes and forecasts U.S. sticky-price inflation excluding food and energy using time series econometric models in R. The analysis uses monthly macroeconomic data from the Federal Reserve Economic Data (FRED) database spanning January 1990 through December 2019.

The objective was to model inflation persistence, evaluate forecast performance across multiple ARMA specifications, and extend the analysis using GARCH volatility modeling to capture time-varying inflation uncertainty.

---

## Research Objective

The project investigates whether sticky-price inflation exhibits persistent autoregressive behavior and whether low-order ARMA models can effectively forecast future inflation dynamics.

The analysis specifically evaluates:

- Inflation persistence and mean reversion
- Optimal ARMA model selection
- Forecast accuracy across competing specifications
- Residual autocorrelation and volatility clustering
- Conditional heteroskedasticity using GARCH models

---

## Data

- Source: Federal Reserve Economic Data (FRED)
- Variable: U.S. Sticky-Price CPI Inflation Excluding Food & Energy
- Frequency: Monthly
- Sample Period: January 1990 – December 2019
- Observations: 360

The series was seasonally adjusted and linearly detrended prior to modeling. An Augmented Dickey-Fuller (ADF) test confirmed stationarity with a p-value of 0.01. :contentReference[oaicite:0]{index=0}

---

## Methodology

### Time Series Modeling
The project estimated multiple ARMA(p,q) specifications ranging from p,q = 0–4 using Akaike Information Criterion (AIC) minimization and Ljung–Box residual diagnostics for model selection. :contentReference[oaicite:1]{index=1}

### Forecast Evaluation
A rolling-window forecasting framework was implemented using 120-month rolling windows to compute 1-step-ahead Mean Squared Forecast Errors (MSFE) across competing models. :contentReference[oaicite:2]{index=2}

### Residual Diagnostics
Residual autocorrelation and conditional heteroskedasticity were analyzed using:
- ACF/PACF diagnostics
- Ljung–Box Q-tests
- ARCH LM tests

### Volatility Modeling
Because strong ARCH effects were detected in the ARMA residuals, a GARCH(1,1) model was estimated to capture time-varying inflation volatility. :contentReference[oaicite:3]{index=3}

---

## Key Findings

### Optimal Forecasting Model
The ARMA(2,1) model was selected as the preferred specification based on:
- Lowest forecast MSFE
- Strong statistical significance of coefficients
- Superior out-of-sample performance

The model achieved:
- AIC = –651.73
- MSFE = 0.0079
- R² = 0.9795 :contentReference[oaicite:4]{index=4}

### Inflation Persistence
Results indicate strong autoregressive persistence and mean-reverting dynamics in sticky-price inflation. Both AR coefficients and the MA coefficient were highly statistically significant (p < 0.001). :contentReference[oaicite:5]{index=5}

### Volatility Clustering
ARCH LM tests detected significant conditional heteroskedasticity, indicating that inflation volatility clusters over time. :contentReference[oaicite:6]{index=6}

The estimated GARCH(1,1) model produced:
- α₁ + β₁ ≈ 0.92
- High volatility persistence
- Stable long-run variance dynamics :contentReference[oaicite:7]{index=7}

### Forecast Results
The ARMA-GARCH forecasts predicted a gradual decline in sticky-price inflation over the subsequent 12 months, while confidence intervals widened over longer horizons due to volatility persistence. :contentReference[oaicite:8]{index=8}

---

## Technologies Used

- R
- RStudio
- forecast
- tseries
- ggplot2
- Econometric time series modeling

---

## Repository Structure

- `sticky_price_inflation_forecasting.R` → primary forecasting and modeling code
- `*.pdf` → diagnostic plots, forecast visualizations, and volatility analysis
- `CORESTICKM159SFRBATL.csv` → inflation dataset
- `Sticky_Price_Inflation_Report.pdf` → full research write-up

---

## Forecasting & Diagnostic Outputs

This repository includes:
- Seasonal adjustment and detrending analysis
- ARMA residual diagnostics
- ACF/PACF residual plots
- Multi-step inflation forecasts
- Recursive forecasting evaluation
- GARCH conditional volatility estimation
- Forecast confidence interval analysis

---

## Conclusion

The analysis demonstrates that sticky-price inflation exhibits strong persistence and significant volatility clustering. While ARMA models effectively capture the mean dynamics of inflation, incorporating GARCH volatility structures substantially improves variance estimation and forecasting uncertainty.

The final ARMA-GARCH framework provides a robust approach for modeling both inflation persistence and time-varying macroeconomic volatility.
