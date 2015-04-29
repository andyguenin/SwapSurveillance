
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(ggplot2)
source('scratch.R')

ir_r <- get_swap_data('ir')
cr_r <- get_swap_data('cr')


shinyServer(function(input, output) {

  output$idri_ts <- renderUI(dateRangeInput(start = min(ir_r$exec.timestamp), end = max(ir_r$exec.timestamp), "iexec.timestamp", label = h4("Transaction Date")))
  output$idri_es <- renderUI(dateRangeInput(start = min(ir_r$effective.date), end = max(ir_r$effective.date), "ieffective.date", label = h4("Effective Date")))
  output$idri_en <- renderUI(dateRangeInput(start = min(ir_r$end.date), end = max(ir_r$end.date), "iend.date", label = h4("End Date")))
  output$isi_nb <- renderUI(sliderInput("inotionalBal",
                                       label = h4("Notional Balance"),
                                       min = min(ir_r$notional.currency.amount.1),
                                       max = max(ir_r$notional.currency.amount.1),
                                       value = c(min(ir_r$notional.currency.amount.1),max(ir_r$notional.currency.amount.1))))
  output$isi_pn <- renderUI(sliderInput("iprice.notation",
                                       label = h4("Fixed Rate"),
                                       min = min(ir_r$price.notation),
                                       max = max(ir_r$price.notation),
                                       value = c(0,max(ir_r$price.notation))))
  output$isi_t <- renderUI(sliderInput("itenor_r",
                                        label = h4("Tenor"),
                                        min = 0,
                                        max = max(ir_r$tenor_r),
                                        step=1,
                                        value = c(min(ir_r$tenor_r), max(ir_r$tenor_r))
                                        ))
  output$iua <- renderUI(checkboxGroupInput("iunderlying.asset.2", 
                                           label = h4("Floating Rate"),
                                           choices = as.character(unique(ir_r$underlying.asset.2)),
                                           selected = c('USD-LIBOR-BBA 3M')))
  
  ir <- reactive({
    ir_r %>% 
           filter(underlying.asset.2 %in% input$iunderlying.asset.2) %>%
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
          filter(tenor_r >= input$itenor_r[1]) 
  })
  
  output$ichart <- renderPlot({ 
    ggplot(data = ir(), aes_string(x=input$ixaxis, y=input$iyaxis, size=input$isize, color=input$icolor)) + geom_point()
  }) 


})
