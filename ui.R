# ui.R

source("dependencies.R")

shinyUI(navbarPage("Text Analysis App",
  tabPanel("Text Analysis",
    sidebarLayout(
      sidebarPanel(
        textAreaInput("raw_text", "Paste Raw Text Here:", rows = 10),
        actionButton("run_analysis", "Run Analysis")
      ),
      mainPanel(
        h4("Summary Statistics"),
        htmlOutput("summary_output"),
        h4("Sentence Sentiment Analysis"),
        DTOutput("sentiment_table")
      )
    )
  ),
  tabPanel("sentiPlot",
    plotlyOutput("sentiment_plot")
  ),
  tabPanel("Histogram",
    plotOutput("sentiment_histogram")
  )
))
