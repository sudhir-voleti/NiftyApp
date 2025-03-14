# ui.R
library(shiny)

ui <- fluidPage(
  titlePanel("Text Analysis App"),
  sidebarLayout(
    sidebarPanel(
      textAreaInput("raw_text", "Paste Raw Text Here:", rows = 5),
      actionButton("run_analysis", "Run Analysis")
    ),
    mainPanel(
      h4("Corpus Summary:"),
      verbatimTextOutput("corpus_summary"),
      h4("Sentence Sentiment Analysis:"),
      DT::dataTableOutput("sentiment_table")
    )
  )
)
