# Define server logic for the Shiny app
server <- function(input, output, session) {
  
  # Reactive expression to read and process input data
  inputData <- eventReactive(input$analyze, {
    if (!is.null(input$fileUpload)) {
      # Determine file type and process accordingly
      fileExt <- tools::file_ext(input$fileUpload$name)
      if (fileExt == "txt") {
        # For .txt files, read as raw text
        return(list(text = readLines(input$fileUpload$datapath, warn = FALSE), source = "file"))
      } else if (fileExt == "csv") {
        # For .csv files, read as a data frame and extract selected column
        data <- read_csv(input$fileUpload$datapath)
        if (!is.null(input$textColumn)) {
          selectedText <- data[[input$textColumn]]
          return(list(text = selectedText, source = "file"))
        } else {
          return(NULL) # No column selected
        }
      }
    } else if (!is.null(input$textInput) && nchar(input$textInput) > 0) {
      # For raw text input, use the text directly
      return(list(text = input$textInput, source = "textInput"))
    } else {
      return(NULL) # No valid input
    }
  })
  
  # Dynamically generate dropdown for text column selection
  output$textColumnSelector <- renderUI({
    req(input$fileUpload) # Ensure a file is uploaded
    fileExt <- tools::file_ext(input$fileUpload$name)
    if (fileExt == "csv") {
      data <- read_csv(input$fileUpload$datapath)
      selectInput("textColumn", "Select Text Column for Analysis", choices = colnames(data))
    }
  })
  
  # Perform corpus summary analysis
  output$corpusSummary <- renderPrint({
    data <- inputData()
    if (is.null(data)) {
      return("Please provide input (upload a file or paste text).")
    }
    
    # Combine all text into a single string
    combinedText <- paste(data$text, collapse = " ")
    
    # Calculate corpus attributes
    numDocuments <- length(data$text) # Number of documents/paragraphs
    sentences <- str_split(combinedText, "[.!?]") %>% unlist() %>% str_trim() # Split by sentence punctuation
    numSentences <- sum(nchar(sentences) > 0) # Count non-empty sentences
    words <- str_split(combinedText, "\\s+") %>% unlist() %>% str_trim() # Split by whitespace
    numWords <- sum(nchar(words) > 0) # Count non-empty words
    
    # Return summary
    list(
      "Number of Documents/Paragraphs" = numDocuments,
      "Number of Sentences" = numSentences,
      "Number of Words" = numWords
    )
  })
}
