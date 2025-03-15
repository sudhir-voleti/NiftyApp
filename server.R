# server.R

source("dependencies.R")

shinyServer(function(input, output) {

  processed_data <- eventReactive(input$run_analysis, {
    raw_text <- input$raw_text

    # Pre-processing
    # 1. HTML entity decoding
    decoded_text <- raw_text
    try({
      decoded_text <- content(GET(url = paste0("data:text/plain;charset=utf-8,", URLencode(raw_text))), as = "text", encoding = "UTF-8")
    }, silent = TRUE)

    # 2. Deleting junk HTML tags
    cleaned_text <- gsub("<.*?>", "", decoded_text)

    # 3. Replacing special characters (keeping basic letters, numbers, and spaces)
    cleaned_text <- str_replace_all(cleaned_text, "[^[:alnum:][:space:]]", "")

    # Split into documents (paragraphs or lines)
    documents <- unlist(strsplit(cleaned_text, "\n\n+|\n+"))
    documents <- trimws(documents)
    documents <- documents[documents != ""] # Remove empty documents

    # Sentence tokenization and sentiment analysis
    sentence_data <- data.frame()
    doc_index <- 1
    for (doc in documents) {
      sentences <- tibble(text = doc) %>%
        unnest_tokens(sentence, text, token = "sentences") %>%
        mutate(doc_index = doc_index)
      if (nrow(sentences) > 0) {
        sentiments <- sentiment(sentences$sentence)
        sentences$sentiment_score <- sentiments$sentiment
        sentence_data <- bind_rows(sentence_data, sentences)
      }
      doc_index <- doc_index + 1
    }

    # Calculate summary statistics
    num_documents <- length(documents)
    num_sentences <- nrow(sentence_data)
    num_words <- sum(str_count(cleaned_text, "\\w+"))

    list(
      summary = paste(
        "Number of Documents:", num_documents, "\n",
        "Number of Sentences:", num_sentences, "\n",
        "Number of Words:", num_words
      ),
      sentiment_table = sentence_data %>%
        select(doc_index, sentence, sentiment_score)
    )
  })

  output$summary_output <- renderPrint({
    processed_data()$summary
  })

  output$sentiment_table <- renderDT({
    processed_data()$sentiment_table
  })
})
