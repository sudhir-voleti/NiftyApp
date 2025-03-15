# ui.R

source("dependencies.R")

shinyUI(fluidPage(
  titlePanel("Text Analysis App"),

  sidebarLayout(
    sidebarPanel(
      textAreaInput("raw_text", "Paste Raw Text Here:", rows = 10),
      actionButton("run_analysis", "Run Analysis")
    ),

    mainPanel(
      h4("Summary Statistics"),
      verbatimTextOutput("summary_output"),

      h4("Sentence Sentiment Analysis"),
      DTOutput("sentiment_table")
    )
  )
))
