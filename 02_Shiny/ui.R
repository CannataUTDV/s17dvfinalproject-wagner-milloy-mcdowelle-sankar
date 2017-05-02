#ui.R

require(shiny)
require(shinydashboard)
require(plotly)

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Crosstab", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Barchart", tabName = "barchart", icon = icon("dashboard")),
      menuItem("Barchart 2", tabName = "demographics", icon = icon("dashboard")),
      menuItem("Histogram", tabName = "histogram", icon = icon("dashboard")),
      menuItem("Scatterplot", tabName = "scatterplot", icon = icon("dashboard")),
      menuItem("Scatterplot 2", tabName = "scatterplot 2", icon = icon("dashboard")),
      menuItem("Boxplot", tabName = "boxplot", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    tabItems(
      # Crosstab tab content
      tabItem(tabName = "crosstab",
              sliderInput("KPI1", "KPI_Low:", 
                          min = 0, max = 8,  value = .1),
              sliderInput("KPI2", "KPI_Medium:", 
                          min = 9, max = 16,  value = .2),
              actionButton(inputId = "clicks1",  label = "To start, click here"),
              plotOutput("distPlot1", height = "1000px", width = "1400px")
      ),
      # Barchart tab content
      tabItem(tabName = "barchart",
        plotOutput("barchart")),
      # Barchart 2 tab content
      tabItem(tabName = "demographics",
        plotlyOutput("demographics")),
      # Histogram tab content
      tabItem(tabName = "histogram",
        plotlyOutput("histogram")),
      # Scatterplot tab content
      tabItem(tabName = "scatterplot",
        plotlyOutput("scatterplot")),
      # Scatterplot 2 tab content
      tabItem(tabName = "scatterplot 2",
        plotOutput("plot1",
                         click = "plot_click",
                         dblclick = "plot_dblclick",
                         hover = "plot_hover",
                         brush = "plot_brush"),
        plotOutput("plot2")),
      # Boxplot tab content
      tabItem(tabName = "boxplot",
        plotOutput("boxplot"))
    )
  )
)


  
