library(shiny)

source('scratch.R')

cont_label = list(
  "Transaction Date" = "exec.timestamp",
  "Effective Date" = "effective.date",
  "End Date" = "end.date",
  "Price" = "price.notation",
  "Notional Amount" = "notional.currency.amount.1"
)

size_label = list(
  "Price" = "price.notation",
  "Notional Amount" = "notional.currency.amount.1",
  "Constant" = 1
)

fact_label = list(
  "Currency" = "notional.currency.1",
  "Contract Type" = "contract.type",
  "Tenor" = 'tenor'
)

shinyUI(fluidPage(
  titlePanel("SDR CD Swap Surveillance"),
  sidebarLayout(
    sidebarPanel(
      uiOutput('idri_ts'),
      uiOutput('idri_es'),
      uiOutput('idri_en'),
      uiOutput('isi_nb'),
      uiOutput('isi_pn'),
      uiOutput('isi_t'),
      uiOutput('iaction_t'),
      selectInput("ixaxis", label = h4("X-axis"), 
                  choices = cont_label, 
                  selected = 'exec.timestamp'),
      selectInput("iyaxis", label = h4("Y-axis"), 
                  choices = cont_label, 
                  selected = 'price.notation'),
      selectInput("isize", label = h4("Dot Size"), 
                  choices = size_label, 
                  selected = 'notional.currency.amount.1'),
      selectInput("icolor", label = h4("Color"), 
                  choices = fact_label,
                  selected = 'tenor'),
      uiOutput("ipnt_t"),
      uiOutput('iua')
      
    ),
    mainPanel(
      
      plotOutput(height = '800px', "ichart")
      
    )
  )
  
)

)