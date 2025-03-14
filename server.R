# Define server logic for the Shiny app
server <- function(input, output, session) {
  
  # Reactive expression to read and process input data
  inputData <- eventReactive(input$analyze, {
    if (!is.null(input$fileUpload)) {
      # Read uploaded file
      fileExt <- tools::file_ext(input$fileUpload$name)
      if (fileExt == "txt") {
        # For .txt files, read as raw text
        return(list(text = readLines(input$fileUpload$datapath, warn = FALSE), source = "file"))
      } else if (fileExt == "csv") {
        # For .csv files, read as a data frame and extract selected column
        data <- read_csv(input$fileUpdate
