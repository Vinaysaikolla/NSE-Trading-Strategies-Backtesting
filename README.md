# NSE-Trading-Strategies-Backtesting
An interactive R-based application that allows users to backtest various technical trading strategies on NSE (National Stock Exchange of India) stocks. The tool features a Shiny dashboard interface for easy strategy comparison and performance analysis.

## Features
- Backtesting capabilities for multiple trading strategies:
  - MACD (Moving Average Convergence Divergence)
  - RSI (Relative Strength Index)
  - SMI (Stochastic Momentum Index)
  - EMA (Exponential Moving Average)
- Interactive date range selection
- Real-time strategy performance visualization
- Comparison with buy-and-hold returns
- Pre-loaded with top 100 NSE stocks
- Performance metrics including:
  - Annualized returns
  - Total period returns
  - Strategy vs Buy & Hold comparison

## Prerequisites
The following R packages are required:
```R
install.packages(c(
  "shiny",
  "shinydashboard",
  "quantmod",
  "PerformanceAnalytics",
  "tidyverse",
  "ggplot2"
))
```

## Installation
1. Clone this repository
2. Install the required packages
3. Run the R script in your preferred R environment
4. The Shiny dashboard will open in your default web browser

## Usage
1. Select a stock from the dropdown menu (Top 100 NSE stocks available)
2. Choose a trading strategy:
   - MACD: Uses standard (12, 26, 9) parameters
   - RSI: Uses 14-period RSI with 30/70 thresholds
   - SMI: Uses (13, 25, 2, 9) parameters
   - EMA: Uses 20-period EMA
3. Set your backtesting date range
4. Click "Analyze" to see results

## Dashboard Components
### Input Parameters
- Stock selector
- Strategy selector
- Date range picker
- Analysis trigger button

### Results Display
- Strategy performance metrics
- Interactive performance comparison plot
- Buy & Hold vs Strategy returns visualization

## Trading Strategies Explained
### MACD Strategy
- Uses crossover of MACD line and signal line
- Buy when MACD crosses the signal line from below
-	Sell when MACD crosses signal line from above


### RSI Strategy
- Uses overbought/oversold levels
- Buy when RSI < 30 (oversold)
- Sell when RSI > 70 (overbought)

### SMI Strategy
- Uses Stochastic Momentum Index crossovers
- Buy when SMI crosses signal line from below
-	Sell when SMI crosses signal line from above


### EMA Strategy
- Uses price and EMA crossovers
- Buy when faster EMA crosses slower EMA from below
-	Sell when faster EMA crosses slower EMA from above


## Important Notes
- All strategies use closing prices for calculations
- Transaction costs are not included in the calculations
- Past performance does not guarantee future results
- This tool is for educational purposes only

## License
[MIT License](LICENSE)

## Disclaimer
This tool is for educational and research purposes only. It should not be considered as financial advice. Always conduct your own research and consult with a qualified financial advisor before making investment decisions.
