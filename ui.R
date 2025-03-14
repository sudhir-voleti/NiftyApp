# ui.R
library(shiny)

fluidPage(
  titlePanel("Corpus Attribute Summary"),

  sidebarLayout(
    sidebarPanel(
      h4("Input Options"),
      # Option 1: Paste raw text
      textAreaInput("raw_text", "Paste Text Here:", rows = 5),
      tags$hr(),

      # Option 2: Upload text file
      fileInput("file_upload", "Upload Text File (.txt or .csv):",
                accept = c("text/plain",
                           "text/csv",
                           "application/vnd.ms-excel")),

      # Conditional panel for CSV column selection
      conditionalPanel(
        condition = "output.is_csv_upload",
        selectInput("text_column", "Select Text Column:", choices = NULL)
      )
    ),

    mainPanel(
      h4("Corpus Summary"),
      verbatimTextOutput("corpus_summary")
    )
  )
)
