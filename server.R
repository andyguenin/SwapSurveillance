
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(ggplot2)
source('scratch.R')

cr_r <- get_swap_data('cr')


shinyServer(function(input, output) {

  output$idri_ts <- renderUI(dateRangeInput(start = min(cr_r$exec.timestamp), end = max(cr_r$exec.timestamp), "iexec.timestamp", label = h4("Transaction Date")))
  output$idri_es <- renderUI(dateRangeInput(start = min(cr_r$effective.date), end = max(cr_r$effective.date), "ieffective.date", label = h4("Effective Date")))
  output$idri_en <- renderUI(dateRangeInput(start = min(cr_r$end.date), end = max(cr_r$end.date), "iend.date", label = h4("End Date")))
  output$isi_nb <- renderUI(sliderInput("inotionalBal",
                                       label = h4("Notional Balance"),
                                       min = min(cr_r$notional.currency.amount.1),
                                       max = max(cr_r$notional.currency.amount.1),
                                       value = c(min(cr_r$notional.currency.amount.1),max(cr_r$notional.currency.amount.1))))
  output$isi_pn <- renderUI(sliderInput("iprice.notation",
                                       label = h4("Price"),
                                       min = min(cr_r$price.notation),
                                       max = max(cr_r$price.notation),
                                       value = c(0,max(cr_r$price.notation))))
  output$isi_t <- renderUI(sliderInput("itenor_r",
                                        label = h4("Tenor"),
                                        min = 0,
                                        max = max(cr_r$tenor_r),
                                        step=1,
                                        value = c(min(cr_r$tenor_r), max(cr_r$tenor_r))
                                        ))
  output$iua <- renderUI(checkboxGroupInput("iunderlying.asset.1", 
                                           label = h4("Underlying"),
                                           choices = as.character(unique(cr_r$underlying.asset.1)),
                                           selected = as.character(unique(cr_r$underlying.asset.1))))
  
  output$iaction_t <- renderUI(checkboxGroupInput('iaction', 
                                                  label = h4('Action'),
                                                  choices = c('New','Cancel','Correct'),
                                                  selected = c('New','Cancel','Correct')))
  
  output$ipnt_t <- renderUI(checkboxGroupInput('ipnt', 
                                               label = h4("Price Notation Type"),
                                               choices = list("Price"="Price", "Traded Spread"="TradedSpread"),
                                               selected = c("Price", "TradedSpread")))
  
  
  cr <- reactive({
    cr_r %>% 
           filter(underlying.asset.1 %in% input$iunderlying.asset.1) %>%
           filter(as.Date(exec.timestamp) >= input$iexec.timestamp[1]) %>%
           filter(as.Date(exec.timestamp) <= input$iexec.timestamp[2]) %>%
           filter(as.Date(effective.date) >= input$ieffective.date[1]) %>%
           filter(as.Date(effective.date) <= input$ieffective.date[2]) %>%
           filter(as.Date(end.date) >= input$iend.date[1]) %>%
           filter(as.Date(end.date) <= input$iend.date[2]) %>%
          filter(price.notation >= input$iprice.notation[1]) %>%
          filter(price.notation <= input$iprice.notation[2]) %>%
          filter(notional.currency.amount.1 >= input$inotionalBal[1]) %>%
          filter(notional.currency.amount.1 <= input$inotionalBal[2]) %>%
          filter(tenor_r <= input$itenor_r[2]) %>%
          filter(tenor_r >= input$itenor_r[1]) %>%
           filter(action %in% input$iaction) %>%
           filter(price.notation.type %in% input$ipnt)
  })
  
  output$ichart <- renderPlot({ 
    ggplot(data = cr(), aes_string(x=input$ixaxis, y=input$iyaxis, size=input$isize, color=input$icolor)) + geom_point()
  }) 
  


})
