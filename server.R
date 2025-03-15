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
        sentences$sentiment_score <- round(sentiments$sentiment, 2) # Round sentiment score
        sentence_data <- bind_rows(sentence_data, sentences)
      }
      doc_index <- doc_index + 1
    }

    # Calculate document level sentiment
    document_sentiment <- sentence_data %>%
      group_by(doc_index) %>%
      summarise(document_sentiment = sum(sentiment_score, na.rm = TRUE), .groups = 'drop')

    # Calculate summary statistics
    num_documents <- length(documents)
    num_sentences <- nrow(sentence_data)
    num_words <- sum(str_count(cleaned_text, "\\w+"))

    list(
      summary = paste(
        "Number of Documents:", num_documents, "<br/>",
        "Number of Sentences:", num_sentences, "<br/>",
        "Number of Words:", num_words
      ),
      sentiment_table = sentence_data %>%
        select(doc_index, sentence, sentiment_score),
      document_sentiment = document_sentiment,
      sentence_sentiment_scores = sentence_data$sentiment_score
    )
  })

  output$summary_output <- renderText({
    processed_data()$summary
  })

  output$sentiment_table <- renderDT({
    processed_data()$sentiment_table
  })

  output$sentiment_plot <- renderPlotly({
    doc_sentiment_data <- processed_data()$document_sentiment
    if (nrow(doc_sentiment_data) > 0) {
      plot_ly(data = doc_sentiment_data, x = ~doc_index, y = ~document_sentiment,
              type = 'scatter', mode = 'lines+markers',
              hovertemplate = paste('Document: %{x}<br>Sentiment: %{y:.2f}<extra></extra>')) %>%
        layout(title = "Document Level Sentiment Over Documents",
               xaxis = list(title = "Document Index"),
               yaxis = list(title = "Document Sentiment Score"))
    } else {
      plotly_empty(type = "scatter", mode = "lines+markers") %>%
        layout(title = "No Document Sentiment Data Available")
    }
  })

  output$sentiment_histogram <- renderPlot({
    sentence_scores <- processed_data()$sentence_sentiment_scores
    if (length(sentence_scores) > 0) {
      # Define sentiment buckets
      breaks <- seq(min(sentence_scores, na.rm = TRUE), max(sentence_scores, na.rm = TRUE), length.out = 5) # 5 buckets
      # or fixed buckets like: breaks <- c(-Inf, -0.2, 0.2, Inf) for negative, neutral, positive

      ggplot(data.frame(sentiment = sentence_scores), aes(x = sentiment)) +
        geom_histogram(breaks = breaks, fill = "steelblue", color = "black") +
        labs(title = "Distribution of Sentence Sentiment Scores",
             x = "Sentiment Score",
             y = "Number of Sentences") +
        theme_minimal() +
        theme(
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.background = element_rect(fill = "white"),
          axis.line = element_line(color = "black"),
          plot.title = element_text(hjust = 0.5)
        )
    } else {
      ggplot() +
        annotate("text", x = 0, y = 0, label = "No Sentence Sentiment Data Available", size = 5) +
        theme_void()
    }
  })
})
