# Load the libraries required. Please install them before loading the libraries
library(shiny)
library(shinydashboard)
library(quantmod)
library(PerformanceAnalytics)
library(fPortfolio)
library(timeSeries)
library(dplyr)

# Creating a list of the top 100 NSE stock tickers.
nse_top_100 <- c("RELIANCE.NS", "TCS.NS", "HDFCBANK.NS", "INFY.NS", "ICICIBANK.NS",
                 "HINDUNILVR.NS", "SBIN.NS", "KOTAKBANK.NS", "BHARTIARTL.NS", "ITC.NS",
                 "HCLTECH.NS", "ASIANPAINT.NS", "LT.NS", "AXISBANK.NS", "BAJFINANCE.NS",
                 "MARUTI.NS", "HDFCLIFE.NS", "SUNPHARMA.NS", "ULTRACEMCO.NS", "DIVISLAB.NS",
                 "NESTLEIND.NS", "POWERGRID.NS", "JSWSTEEL.NS", "NTPC.NS", "INDUSINDBK.NS",
                 "BAJAJFINSV.NS", "TITAN.NS", "ADANIGREEN.NS", "WIPRO.NS", "BPCL.NS",
                 "ONGC.NS", "ADANIPORTS.NS", "M&M.NS", "HEROMOTOCO.NS", "BAJAJ-AUTO.NS",
                 "COALINDIA.NS", "GRASIM.NS", "HINDALCO.NS", "BRITANNIA.NS", "SHREECEM.NS",
                 "SBILIFE.NS", "TECHM.NS", "DRREDDY.NS", "TATAMOTORS.NS", "EICHERMOT.NS",
                 "CIPLA.NS", "IOC.NS", "VEDL.NS", "TATASTEEL.NS", "UPL.NS",
                 "AMBUJACEM.NS", "GAIL.NS", "DMART.NS", "DABUR.NS", "ADANITRANS.NS",
                 "AUROPHARMA.NS", "PIDILITIND.NS", "LUPIN.NS", "MRF.NS", "ADANIENT.NS",
                 "APOLLOHOSP.NS", "BERGEPAINT.NS", "NAUKRI.NS", "TATACONSUM.NS", "SIEMENS.NS",
                 "HAVELLS.NS", "JINDALSTEL.NS", "ICICIPRULI.NS", "IDFCFIRSTB.NS", "PGHH.NS",
                 "NMDC.NS", "GODREJCP.NS", "BOSCHLTD.NS", "CONCOR.NS",
                 "ACC.NS", "BANKBARODA.NS", "BIOCON.NS", "SRF.NS", "COLPAL.NS",
                 "GLENMARK.NS", "MCDOWELL-N.NS", "PETRONET.NS", "ADANIPOWER.NS", "TORNTPHARM.NS",
                 "BANDHANBNK.NS", "MANAPPURAM.NS", "PNB.NS", "CANBK.NS", "RECLTD.NS",
                 "BEL.NS", "ABB.NS", "MUTHOOTFIN.NS", "MFSL.NS", "BHEL.NS",
                 "EXIDEIND.NS", "IDEA.NS", "DALBHARAT.NS", "TVSMOTOR.NS", "ICICIGI.NS",
                 "RAMCOCEM.NS", "JUBLFOOD.NS", "HINDPETRO.NS", "SRTRANSFIN.NS", "IDBI.NS")

# Defining the aesthetics required in the Shiny Dashboard
ui <- dashboardPage(
  dashboardHeader(title = "Portfolio Optimization"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Portfolio Setup", tabName = "portfolio", icon = icon("cogs")),
      menuItem("Results", tabName = "results", icon = icon("chart-line"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "portfolio",
        fluidRow(
          box(
            title = "Stock Selection and Inputs", width = 12, status = "primary", solidHeader = TRUE,
            selectInput("stock_selection", "Select 2 or More Stocks:", choices = nse_top_100, multiple = TRUE, selected = nse_top_100[1:2]),
            selectInput("investment_objective", "Investment Objective:", 
                        choices = c("Maximize Returns", "Minimize Risk", "Maximize Sharpe Ratio")),
            sliderInput("risk_free_rate", "Risk-Free Rate (%):", 
                        min = 0, max = 15, value = 7, step = 0.1),
            numericInput("investment_amount", label = "Investment Amount in Indian Rupees:", value = 10000, min = 0, step=100),
            actionButton("calculate", "Calculate amounts to be allocated", icon = icon("calculator"))
          )
        )
      ),
      
      tabItem(
        tabName = "results",
        fluidRow(
          box(
            title = "Portfolio Weights", width = 6, status = "success", solidHeader = TRUE,
            tableOutput("weights_table")
          ),
          box(
            title = "Efficient Frontier", width = 6, status = "warning", solidHeader = TRUE,
            plotOutput("efficient_frontier")
          )
        )
      )
    )
  )
)

# The main part of the code doing all the necessary calculations as per the input selected
server <- function(input, output, session) {
  
  observeEvent(input$calculate, {
    
    #  Need to ensure that at least 2 stocks are selected for creating a portfolio
    if (length(input$stock_selection) < 2) {
      showNotification("Please select at least 2 stocks.", type = "error")
      return(NULL)
    }
    
    # Combining the selected stock tickers
    portfolio_stk <- lapply(input$stock_selection, function(X) { 
      getSymbols(X, from = "2021-07-31", to = "2024-07-31", auto.assign = FALSE)
    })
    
    
    portfolio_stk_df <- do.call(merge, lapply(portfolio_stk, Ad)) # Combine adjusted prices
    portfolio_stk_ts <- as.timeSeries(portfolio_stk_df)
    
    # Calculate returns
    portfolio_stk_return <- Return.calculate(portfolio_stk_ts)
    portfolio_stk_return <- na.omit(portfolio_stk_return)
    
    # Defining the risk-free rate
    risk_free_rate <- input$risk_free_rate / 100 / 252 # Convert annual rate to daily
    
    #  Code required to determine portfolio weights based on the selected investment objective
    portfolio_weights <- NULL
    if (input$investment_objective == "Maximize Returns") {
      # Maximum Return Portfolio (for simplicity, use one stock with the highest past return)
      max_return_stock <- colnames(portfolio_stk_return)[which.max(colMeans(portfolio_stk_return))]
      weights <- ifelse(colnames(portfolio_stk_return) == max_return_stock, 1, 0)
      portfolio_weights <- weights
    } else if (input$investment_objective == "Minimize Risk") {
      # Minimum Variance Portfolio
      min_var_portfolio <- minvariancePortfolio(portfolio_stk_return, portfolioSpec(), constraints = "longOnly")
      portfolio_weights <- getWeights(min_var_portfolio)
    } else if (input$investment_objective == "Maximize Sharpe Ratio") {
      # Maximum Sharpe Ratio Portfolio
      portfolio_spec <- portfolioSpec()
      setRiskFreeRate(portfolio_spec) <- risk_free_rate # Correctly set the risk-free rate here
      Optimum_portfolio <- tangencyPortfolio(portfolio_stk_return, portfolio_spec, constraints = "longOnly")
      portfolio_weights <- getWeights(Optimum_portfolio)
    }
    
    # To generate the portfolio weights in the form of a table in the dashboard
    output$weights_table <- renderTable({
      data.frame(Stock = colnames(portfolio_stk_return), Weights = round(portfolio_weights, 4), Amounts = round(portfolio_weights, 4)*input$investment_amount)
    })
    
    # To plot the efficient frontier in the dashboard
    output$efficient_frontier <- renderPlot({
      portfolio_spec <- portfolioSpec()
      setRiskFreeRate(portfolio_spec) <- risk_free_rate
      efficient_frontier <- portfolioFrontier(portfolio_stk_return, portfolio_spec, constraints = "longOnly")
      plot(efficient_frontier, c(1, 2, 3, 4, 5, 8))
      
    })
  })
}

# Done!!! Run the app
shinyApp(ui = ui, server = server)
