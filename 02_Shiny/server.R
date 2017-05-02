# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
require(leaflet)
require(plotly)
require(lubridate)

df7 <- read.csv("https://query.data.world/s/9h7clhat19z6qpe4mor0ndtpl",header=T);

shinyServer(function(input, output) {

  ### Begin crosstab ###
  output$distPlot1 <- renderPlot({
    
    KPI_Low = input$KPI1     
    KPI_Medium = input$KPI2
    
    df1 <- eventReactive(input$clicks1, { 
      query(
        data.world(propsfile = "www/.data.world"),
        dataset="mamilloy/s-17-dv-project-5", type="sql",
        query="select Year, State, 
        sum(`2010_Data_Update2 - Sheet1.csv/2010_Data_Update2 - Sheet1`.`In-State_Tuition`) as sum_instate, 
        sum(Total_Undergraduates) as sum_undergraduates, 
        sum(`2010_Data_Update2 - Sheet1.csv/2010_Data_Update2 - Sheet1`.`In-State_Tuition`) / sum(Total_Undergraduates) as ratio,
        
        case
        when sum(`2010_Data_Update2 - Sheet1.csv/2010_Data_Update2 - Sheet1`.`In-State_Tuition`) / sum(Total_Undergraduates) < ? then '03 Low'
        when sum(`2010_Data_Update2 - Sheet1.csv/2010_Data_Update2 - Sheet1`.`In-State_Tuition`) / sum(Total_Undergraduates) < ? then '02 Medium'
        else '01 High'
        end AS kpi 
        
        from Clean_merged_university_data inner join `2010_Data_Update2 - Sheet1`
        on Clean_merged_university_data.State = `2010_Data_Update2 - Sheet1`._State_
        group by Year, State
        order by Year, State",
        queryParameters = list(KPI_Low, KPI_Medium)
      )
    }
      )
    #View(df1())
    plot <- ggplot(df1()) + 
      geom_text(aes(x=Year, y=State, label = sum_undergraduates), size=4) +
      geom_tile(aes(x=Year, y=State, fill=kpi), alpha=0.50)
    plot
    }) 
  
  observeEvent(input$clicks, {
    print(as.numeric(input$clicks))
  })
  ### End crosstab ###
  
  ### Begin barchart ###
  output$barchart <- renderPlot({
    df2 <- query(
      data.world(propsfile = "www/.data.world"),
      dataset="mamilloy/s-17-dv-project-6", type="sql",
      query = "SELECT State_Avg, State_Population, bachelors,
      bachelors / State_Population as Percent_Bachelors_Students
      FROM censusdata
      JOIN acsInfo ON acsInfo.State = censusdata.State_Avg;"
    )
    ggplot(df2, aes(x=State_Avg, y=Percent_Bachelors_Students)) + 
      geom_bar(stat="identity", fill="purple") + 
      geom_hline(aes(yintercept = 0.12603))
  })
  ### End barchart ###
  
  ### Begin histogram ### 
  
  df3 <- query(
    data.world(propsfile = "www/.data.world"),
    dataset="mamilloy/s-17-dv-final-project", type="sql",
    query = "SELECT Clean_merged_university_data.`In-State_Tuition` 
    AS tuition
    FROM Clean_merged_university_data
    WHERE Clean_merged_university_data.`In-State_Tuition` IS NOT NULL;"
  )
  
  output$histogram <- renderPlotly({p <- ggplot(data = df3, aes(x = tuition)) +
    geom_histogram(binwidth = 5000, color = "blue", fill = "lightblue") + 
    geom_vline(aes(xintercept = mean(tuition)), color = "black", size = 0.5)
    theme(axis.text.x=element_text(angle = 90, size = 10, vjust = 0.5))
  ggplotly(p)
  
  })
  ### End histogram ###
  
  ### Begin scatterplot ###
  
  df4 <- query(
    data.world(propsfile = "www/.data.world"),
    dataset = "mamilloy/s-17-dv-project-6", type="sql",
    query = "SELECT O.prcntObese, C.State_Population, O.Abbrv, A.bachelors, A.State FROM adult_obese as O JOIN censusdata as C on 
    O.Abbrv = C.State_Avg JOIN acsInfo as A on A.State = O.Abbrv;"
  )
  
  output$scatterplot <- renderPlotly({
    ggplot(df4, aes(x=prcntObese, y=bachelors/State_Population, color=Abbrv)) +
      geom_point() + geom_smooth(se=FALSE, color="black") + ggtitle("Percent State Obesity and Percent of State with Bachelor's Degree ")+ labs(x="% Obese",y="% College Degree")
  })
  
  ### End scatterplot ###
  
  ### Begin barchart 2 ###
  
  df5 <- query(
    data.world(propsfile = "www/.data.world"),
    dataset="mamilloy/s-17-dv-project-6", type="sql",
    query = "SELECT Year, State, AVG(Percent_White) AS Percent_White, AVG(Percent_Black) AS Percent_Black,
    AVG(Percent_Hispanic) AS Percent_Hispanic, AVG(Percent_Asian) AS Percent_Asian, AVG(Percent_Other) AS Percent_Other
    FROM Clean_merged_university_data
    GROUP BY State"
  )
  
  output$demographics <- renderPlotly({
    p <-
      plot_ly(df5, x = ~State, y = ~Percent_White, type = 'bar', name = 'Percent White') %>%
      add_trace(y = ~Percent_Black, name = 'Percent Black') %>%
      add_trace(y = ~Percent_Hispanic, name = 'Percent Hispanic') %>%
      add_trace(y = ~Percent_Asian, name = 'Percent Asian') %>%
      add_trace(y = ~Percent_Other, name = 'Percent Other') %>%
      layout(yaxis = list(title = 'Count'), barmode = 'stack')
    ggplotly(p)
  })
  ### End barchart 2 ###
  
  ### Begin boxplot ###
  
  df6 <- query(
    data.world(propsfile = "www/.data.world"),
    dataset = "mamilloy/s-17-dv-final-project", type="sql",
    query = "SELECT State, Avg_SAT_Score, Year
    FROM `Clean_merged_university_data.csv/Clean_merged_university_data`
    Where Avg_SAT_Score is not null
    Order by State"
  )
  
  output$boxplot <- renderPlot({
    ggplot(df6, aes(x=State, y=Avg_SAT_Score, colour=Year)) + geom_boxplot()
    
  })
  
  output$summs <- renderPrint({
    summary(df6$State)
  })
  
  ### End boxplot ###
  
  ### Begin scatterplot 2 ###
  
  output$plot1 <- renderPlot({
    ggplot(df7, aes(x=State, y=Avg_SAT_Score, color=State)) + geom_point(size=4, alpha=0.7, position=position_jitter(w=0.1, h=0)) + 
      labs(title = "Average College SAT Scores per State", y = "SAT Scores") +
      stat_summary(fun.y=mean, geom="point", shape=23, color="black", size=4) +         
      geom_point(size=3, alpha=0.7, position=position_jitter(w=0.1, h=0)) +
      stat_summary(fun.y=mean, geom="point", shape=23, color="black", size=4) +         
      stat_summary(fun.ymin=function(x)(mean(x)-sd(x)), 
                   fun.ymax=function(x)(mean(x)+sd(x)),
                   geom="errorbar", width=0.1) +
      theme_bw()
  })
  
  output$plot2 <- renderPlot({
    brush = brushOpts(id="plot_brush", delayType = "throttle", delay = 30)
    bdf=brushedPoints(df7, input$plot_brush)
    if( !is.null(input$plot_brush) ) {
      bdf  %>% ggplot() + geom_point(aes(x=State, y=Avg_SAT_Score, color=State, size=4)) + guides(size=FALSE) +
        labs(title = "Selected Average College SAT Scores", y = "SAT Scores", x = "State")
    } 
  })
  ### End scatterplot 2 ###
})
