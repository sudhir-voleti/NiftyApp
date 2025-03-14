# server.R
library(shiny)
library(tidytext)
library(dplyr)
library(stringr)
library(textdata)
library(DT)
library(ggplot2)
library(plotly)

server <- function(input, output) {

  observeEvent(input$run_analysis, {

    raw_text <- input$raw_text

    if (nchar(raw_text) > 0) {
      # Remove HTML tags
      clean_text <- str_replace_all(raw_text, "<[^>]+>", " ")

      # Split text into paragraphs (or documents)
      paragraphs <- str_split(clean_text, "\\n\\n")[[1]]

      # Sentence tokenization and sentiment analysis
      sentences_df <- tibble(doc_index = rep(1:length(paragraphs), times = sapply(str_split(paragraphs, "(?<=[.!?])\\s+"), length)),
                               sentence = unlist(str_split(paragraphs, "(?<=[.!?])\\s+"))) %>%
        mutate(sentence = str_trim(sentence)) %>%
        filter(nchar(sentence) > 0) %>%
        unnest_tokens(word, sentence, token="words", drop=FALSE) %>%
        inner_join(get_sentiments("afinn"), by = "word") %>%
        group_by(doc_index, sentence) %>%
        summarise(sentiment_score = sum(value), .groups = "drop") %>%
        mutate(sentence_number = row_number())

      # Corpus Summary
      num_docs <- length(paragraphs)
      num_sentences <- nrow(sentences_df)
      num_words <- str_count(clean_text, "\\w+")

      output$corpus_summary <- renderPrint({
        cat(paste("Number of Documents/Paragraphs:", num_docs, "\n",
              "Number of Sentences:", num_sentences, "\n",
              "Number of Words:", num_words))
      })

      # Sentiment Table
      output$sentiment_table <- DT::renderDataTable({
        sentences_df
      })

      # Sentiment Plot
      output$sentiment_plot <- renderPlotly({
        p <- ggplot(sentences_df, aes(x = sentence_number, y = sentiment_score)) +
          geom_line() +
          geom_point() +
          labs(x = "Sentence Number", y = "Sentence Sentiment Score") +
          theme_minimal()
        ggplotly(p)
      })

      # Frequency Distribution Plot
      output$freq_dist_plot <- renderPlotly({
        # Define sentiment buckets
        buckets <- c(-Inf, -1, 1, Inf)
        bucket_labels <- c("Negative", "Neutral", "Positive")

        # Assign sentences to buckets
        sentences_df <- sentences_df %>%
          mutate(sentiment_bucket = cut(sentiment_score, breaks = buckets, labels = bucket_labels))

        # Calculate counts per bucket
        bucket_counts <- sentences_df %>%
          group_by(sentiment_bucket) %>%
          summarise(count = n())

        # Create the bar chart
        p <- ggplot(bucket_counts, aes(x = sentiment_bucket, y = count, fill = sentiment_bucket)) +
          geom_bar(stat = "identity", fill = "green", width = 0.7) + # Set bar color and width
          labs(x = "Sentiment Bucket", y = "Number of Sentences") +
          theme_minimal() +
          theme(legend.position = "none",
                axis.text.x = element_text(size = 12),
                axis.title.y = element_text(size = 14),
                axis.title.x = element_text(size = 14),
                plot.margin = margin(20, 20, 20, 20)) # Add margin for better spacing

        ggplotly(p)
      })

    } else {
      output$corpus_summary <- renderPrint("Please paste text into the input field.")
      output$sentiment_table <- DT::renderDataTable(NULL)
      output$sentiment_plot <- renderPlotly(NULL)
      output$freq_dist_plot <- renderPlotly(NULL)
    }
  })
}
