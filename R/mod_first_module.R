#' first_module UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_first_module_ui <- function(id){
  ns <- NS(id)
  tagList(
    h2("A plot"),
    plotOutput(ns("plot"))
  )
}
    
#' first_module Server Functions
#'
#' @noRd 
mod_first_module_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$plot <- renderPlot({
      x <- random_num()
      plot(iris[, x])
    })
  })
}
    
## To be copied in the UI
# mod_first_module_ui("first_module_ui_1")
    
## To be copied in the server
# mod_first_module_server("first_module_ui_1")
