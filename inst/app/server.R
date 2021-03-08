require(jsonlite)
require(DTedit)
params <- read_json("params.json")
nomenklatura <- read.csv("NameList.csv", stringsAsFactors = F)
server <- function(input, output) {
  drafting <- function(data){
    n <- NROW(data)
    data[sample(1:n, size = n),]
  }

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
      delete_callback <- function(data, row){
        data <- data[-row, ]
        return(data)
      }
      DTedit::dtedit(
        input, output, name = 'selectedTable', thedata = result,
        modal.size = "s",
        label.delete = "選択した行を除外", title.delete = "除外",
        show.update = F, show.insert = F, show.copy = F,
        callback.delete = delete_callback,
        datatable.options = list(
          ordering = F, pageLength = input$n, searching = F, dom = "t",
          columnDefs = list(list(className = 'dt-left', targets = "_all"))
          )
      )
      values$showSampling <- NULL
    })
}
