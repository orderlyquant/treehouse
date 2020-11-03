#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  mod_first_module_server("first_module_ui_01")
  
  mod_other_module_server("other_module_ui_1")
  
  observeEvent(input$alert,{
    golem::invoke_js("alert", "Yeah!")
  })
  
}
