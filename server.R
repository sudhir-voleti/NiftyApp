# server.R
library(shiny)
library(tidytext)
library(dplyr)
library(stringr)
library(textdata)
library(DT)

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
        summarise(sentiment_score = sum(value), .groups = "drop")

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

    } else {
      output$corpus_summary <- renderPrint("Please paste text into the input field.")
      output$sentiment_table <- DT::renderDataTable(NULL)
    }
  })
}
