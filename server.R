source("dependencies.R")

shinyServer(function(input, output, session) {

  # Reactive variable to check if a CSV file is uploaded
  output$isCSV <- reactive({
    req(input$fileUpload)
    ext <- tools::file_ext(input$fileUpload$datapath)
    return(ext == "csv")
  })

  # Reactive variable to store the text data
  textData <- reactive({
    # From direct input
    if (!is.null(input$directText)) {
      return(data.frame(text = input$directText))
    }
    # From file upload
    if (!is.null(input$fileUpload)) {
      ext <- tools::file_ext(input$fileUpload$datapath)
      if (ext == "txt") {
        lines <- readLines(input$fileUpload$datapath, warn = FALSE)
        return(data.frame(text = paste(lines, collapse = "\n")))
      } else if (ext == "csv") {
        df <- read.csv(input$fileUpload$datapath)
        updateSelectInput(session, "textColumn", choices = names(df))
        return(df)
      }
    }
    return(NULL)
  })

  # Reactive variable to extract the text column
  extractedText <- reactive({
    data <- textData()
    if (is.data.frame(data)) {
      if (!is.null(input$textColumn) && input$textColumn %in% names(data)) {
        return(data[[input$textColumn]])
      } else if (ncol(data) == 1) {
        return(data[[1]])
      } else if ("text" %in% names(data)) {
        return(data$text)
      } else {
        return(NULL)
      }
    }
    return(NULL)
  })

  # Calculate corpus summary
  corpusSummary <- reactive({
    text_vector <- extractedText()
    req(text_vector) # Ensure text_vector is not NULL

    # Number of documents (rows in the input)
    num_documents <- length(text_vector)

    # Combine all text into a single string for sentence and word counting
    full_text <- paste(text_vector, collapse = "\n")

    # Count sentences (using stringr for boundary detection)
    num_sentences <- str_count(full_text, boundary("sentence"))

    # Count words using tidytext
    words_df <- tibble(text = full_text) %>%
      unnest_tokens(word, text)
    num_words <- nrow(words_df)

    paste0("Corpus Length:\n",
           "  Number of Documents: ", num_documents, "\n",
           "  Number of Sentences: ", num_sentences, "\n",
           "  Number of Words: ", num_words)
  })

  # Render the summary output
  output$summaryOutput <- renderPrint({
    corpusSummary()
  })
})
