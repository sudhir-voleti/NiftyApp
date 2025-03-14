# server.R
library(shiny)
library(readr)
library(dplyr)
library(stringr)

function(input, output, session) {

  # Reactive value to store the text data
  text_data <- reactive({
    # From raw text input
    if (!is.null(input$raw_text) && input$raw_text != "") {
      return(data.frame(text = input$raw_text))
    }

    # From file upload
    if (!is.null(input$file_upload)) {
      ext <- tools::file_ext(input$file_upload$datapath)
      if (ext == "txt") {
        return(read_lines(input$file_upload$datapath) %>% as.data.frame(text = .))
      } else if (ext == "csv") {
        df <- read_csv(input$file_upload$datapath)
        updateSelectInput(session, "text_column", choices = names(df))
        return(df)
      }
    }
    return(NULL)
  })

  # Reactive boolean to check if a CSV file is uploaded
  output$is_csv_upload <- reactive({
    if (!is.null(input$file_upload)) {
      return(tools::file_ext(input$file_upload$datapath) == "csv")
    }
    return(FALSE)
  })
  outputOptions(output, "is_csv_upload", suspendWhenHidden = FALSE)

  # Extract text column if CSV is uploaded and selected
  processed_text <- reactive({
    data <- text_data()
    if (!is.null(data)) {
      if (!is.null(input$file_upload) && tools::file_ext(input$file_upload$datapath) == "csv" && !is.null(input$text_column)) {
        return(data[[input$text_column]])
      } else if (!is.null(data$text)) {
        return(data$text)
      }
    }
    return(NULL)
  })

  # Calculate corpus summary
  corpus_summary_data <- reactive({
    text <- processed_text()
    if (!is.null(text)) {
      num_documents <- length(text)
      num_sentences <- sum(str_count(text, "[.?!]"))
      num_words <- sum(str_count(text, "\\s+")) + num_documents # Add num_documents for cases with no trailing space

      return(list(
        num_documents = num_documents,
        num_sentences = num_sentences,
        num_words = num_words
      ))
    } else {
      return(NULL)
    }
  })

  # Render the corpus summary
  output$corpus_summary <- renderPrint({
    summary_data <- corpus_summary_data()
    if (!is.null(summary_data)) {
      cat("Corpus Length:\n")
      cat("  Number of Documents/Paragraphs:", summary_data$num_documents, "\n")
      cat("  Number of Sentences:", summary_data$num_sentences, "\n")
      cat("  Number of Words:", summary_data$num_words, "\n")
    } else {
      cat("No text input provided yet.\n")
    }
  })
}
