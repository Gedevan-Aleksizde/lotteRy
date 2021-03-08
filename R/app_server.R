#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  params <- jsonlite::read_json(
    if(file.exists("params.json")) "params.json" else getShinyOption("lottery.params.path", app_sys("app/params.json"))
    )
  nomenklatura <- read.csv(
    if(file.exists("NameList.csv")) "NameList.csv" else getShinyOption("name.list.path", app_sys("app/NameList.csv")), 
    stringsAsFactors = F)
  values <- reactiveValues(showSampling = NULL)
  observeEvent(
    input$startSampling,
    {
      showModal(
        modalDialog(
          h4("抽選をしますか?"),
          footer = tagList(actionButton("confirmStartSampling", "抽選開始!"), modalButton("キャンセル")),
          easyClose = T, size = "s")
      )
    }
  )
  observeEvent(
    input$confirmStartSampling,
    {
      removeModal()
      Sys.sleep(params$waitSec)
      values$showSampling <- T
    }
  )
  observeEvent(
    values$showSampling,
    {
      if(!is.na(input$seed)) set.seed(input$seed)
      result <- drafting(nomenklatura)
      write.csv(result, file = "OrderedResult.csv", row.names = F) # for backup
      output$headerTable <- renderUI(h3(paste(rep("🎉", 10), collapse = ""), style = "font-family:apple color emoji,segoe ui emoji,noto color emoji,android emoji,emojisymbols,emojione mozilla,twemoji mozilla,segoe ui symbol;"))
      DTedit::dtedit(
        input, output, name = 'selectedTable', thedata = result,
        modal.size = "s",
        label.delete = "選択した行を除外", title.delete = "除外",
        show.update = F, show.insert = F, show.copy = F,
        callback.delete = delete_callback,
        datatable.options = list(
          ordering = F, pageLength = input$n, searching = F, fillContainer = T,
          columnDefs = list(list(className = 'dt-left', targets = "_all"))
        )
      )
      values$showSampling <- NULL
    })
}

#' @noRd
drafting <- function(data){
  n <- NROW(data)
  data[sample(1:n, size = n),]
}

#' @noRd
delete_callback <- function(data, row){
  data <- data[-row, ]
  return(data)
}
