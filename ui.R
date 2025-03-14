# Define UI for the Shiny app
ui <- fluidPage(
  titlePanel("Text Corpus Analysis App"),
  
  sidebarLayout(
    sidebarPanel(
      # File upload field
      fileInput("fileUpload", "Upload a Text File",
                accept = c(".txt", ".csv"),
                multiple = FALSE),
      
      # Dropdown to select text column (for CSV files)
      conditionalPanel(
        condition = "input.fileUpload != null",
        selectInput("textColumn", "Select Text Column for Analysis", choices = NULL)
      ),
      
      # Text input field
      textAreaInput("textInput", "Or Paste Raw Text Here", 
                    placeholder = "Enter your text here...", 
                    rows = 10),
      
      # Action button to trigger analysis
      actionButton("analyze", "Run Analysis")
    ),
    
    mainPanel(
      h3("Corpus Summary"),
      verbatimTextOutput("corpusSummary")
    )
  )
)
