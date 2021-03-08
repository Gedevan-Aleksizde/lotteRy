require(jsonlite)
require(shinythemes)
require(shinycssloaders)

nomenklatura <- read.csv("NameList.csv", stringsAsFactors = F)
params <- read_json("params.json")
ui <- fluidPage(
  tags$head(
    tags$title(params$title)
  ),
  includeCSS("www/custom.css"),
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
      withSpinner(uiOutput('selectedTable'), image = "img/waiting.gif")
    )
  ),
  theme = shinytheme(params$shinyTheme)
)
