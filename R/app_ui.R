#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  params <- jsonlite::read_json(
    if(file.exists("params.json")) "params.json" else getShinyOption("lottery.params.path", app_sys("app/params.json"))
  )
  nomenklatura <- read.csv(
    if(file.exists("NameList.csv")) "NameList.csv" else getShinyOption("name.list.path", app_sys("app/NameList.csv")), 
    stringsAsFactors = F)
  tagList(
    golem_add_external_resources(),
    fluidPage(
      tags$head(
        tags$title(params$title)
      ),
      includeCSS(app_sys("custom.css")),
      titlePanel(title = params$title),
      sidebarLayout(
        sidebarPanel(
          sliderInput("n", label = h3("抽選で何名?"), min = 1, max = NROW(nomenklatura), value = 1, step = 1, ticks = F),
          div(style = "text-align: center", actionButton(inputId = "startSampling", "抽選開始")),
          hr(),
          h4("オプション"),
          numericInput(inputId = "seed", label = "乱数シード値", value = NA)
        ),
        mainPanel(
          shinycssloaders::withSpinner(
            uiOutput('selectedTable'),
            image = "www/img/waiting.gif")
        )
      ),
      theme = shinythemes::shinytheme(params$shinyTheme)
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path('www', app_sys('app/www'))

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'lotteRy'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

