#' other_module UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_other_module_ui <- function(id){
  ns <- NS(id)
  tagList(
    h2("Another plot"),
    plotOutput(ns("plot"))
  )
}
    
#' other_module Server Functions
#'
#' @noRd 
mod_other_module_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$plot <- renderPlot({
      plot(airquality)
    })
  })
}
    
## To be copied in the UI
# mod_other_module_ui("other_module_ui_1")
    
## To be copied in the server
# mod_other_module_server("other_module_ui_1")
