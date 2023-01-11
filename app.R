library(pacman)

suppressPackageStartupMessages(pacman::p_load(flowbankanalytics, dplyr, tidyr, shiny, DT))

con_hub <- flowbankanalytics::connect_data_hub()




ui <- fluidPage(dataTableOutput("table"))

server <- function(input,output,session){
  values <- reactiveValues()
  pollData <- reactivePoll(10000, session,
                           checkFunc=function(){
                             Sys.time()
                           },
                           valueFunc=function(){ 
                             
                             time <- Sys.time() -50
                            
                             tbl(con_hub, "vwTrade") %>% 
                               filter(TradeTime >= time) %>% 
                               arrange(desc(TradeTime)) %>%
                               select(TradeTime, TradeId, TradedVolume) %>%
                               collect()
                             
                      
                             
                           })
  
  output$table <- renderDataTable({ pollData()})
  
  observe({
    values$selected <- pollData()$TradeTime[input$table_rows_selected]
  })
  
  proxy = dataTableProxy('table')
  observeEvent(pollData(),{
    selectRows(proxy, which(pollData()$TradeTime %in% values$selected))
  })
}

shinyApp(ui,server)