######
# filename: Watson-TweetlyzR/ui.R 
# created: 2016-09-21 by Rudy Martin (realrudymartin@gmail.com)
# This is the UI file for a Shiny web application that plots personality data.
# It takes a persona's tweets and performs a lexical analysis using the 
# IBM's Watson Personality Insights API.
# For more information about this visit github.com/RudyMartin/Watson-TweetlyzR
# THIS IS EXPERIMENTAL CODE SO USE AT YOUR OWN RISK AND POST ISSUES ON GITHUB
######
devtools::install_github("MangoTheCat/radarchart")


    library(radarchart) # used for radar chart
    library(shinydashboard) # used for front-end theme
    # This local file contains functions used in this session.
    # Use this to add Create/Read/Update/Delete (CRUD) actions here.
    source("helpers.R", local=TRUE)
    ReadData()
    
    dashboardPage(
        dashboardHeader(title = "Watson-TweetlyzR:"),
        dashboardSidebar(
            
            # Custom CSS to hide the default logout panel
            tags$head(tags$style(HTML('.shiny-server-account { display: none; }'))),
            
            # The dynamically-generated user panel
            uiOutput("userpanel"),
            
            checkboxGroupInput('selectedPersonas', 'Select Twitter Profile(s):', 
                               personas, selected="realrudymartin"),
            
            radioButtons('selectedFeatures', 'Select Features:', 
                         labs, selected="Values"),
             sidebarMenu(
                menuItem("Source code and data", icon = icon("file-code-o"), 
                    href = "https://github.com/RudyMartin/Watson-TweetlyzR/"),
                menuItem("IBM Watson API Access", icon = icon("database"), 
                         href = "https://www.ibm.com/watson/developercloud/personality-insights.html"),
                menuItem("Created by: Rudy Martin", icon = icon("twitter-square"), 
                    href = "https://twitter.com/realrudymartin")
            #     menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            #     menuItem("UI.R", tabName = "ui", icon = icon("file")),
            #     menuItem("Server.R", tabName = "server", icon = icon("file"))
            #     
             )
        ),
        dashboardBody(
            
            fluidRow(
                
                box( height = "100%",
                    title = "View Twitter Persona", status = "success", solidHeader = TRUE,
                    collapsible = FALSE,
                    chartJSRadarOutput("radar", width = "200", height = "200"), width = 6
                ),
                
                box(height = "100%",
                    title = "Add Twitter Users / Change Groups", status = "warning", solidHeader = TRUE,
                    collapsible = TRUE,
                    "These features not enabled in this demo for performance reasons.", br(), "View source code to manually create profiles from Twitter or other sources.",
                    textInput("text", "Enter Twitter user name without @"),
                    selectInput("groupName", "Group name:",
                                c("Leaders" = "leaders",
                                  "Entertainment" = "entertainment",
                                  "My Friends" = "myfriends"))
                ),
                
                box(height = "100%",
                    title = "Control Outputs", status = "info", solidHeader = TRUE,
                    collapsible = TRUE,
                    "Box content here", br(), "More box content",
                    
                    numericInput("maxScale", "maxScale - 0 for NULL (default)", value = 100, min = 0,
                                 max = NA, step = 1),
                    
                    numericInput("scaleStepWidth", "scaleStepWidth - 0 for NULL (default)", 
                                 value = 10, min = 0, max = NA, step = 1),
                    
                    numericInput("scaleStartValue", "scaleStartValue - 0 is the default", 
                                 value = 0, min = NA, max = NA, step = 1),
                    
                    numericInput("labelSize", "labelSize", value = 18, min = 1, max = NA, step = 1),
                    
                    numericInput("lineAlpha", "lineAlpha", value = 0.8, min = 0, max = 1, step = 0.05),
                    
                    numericInput("polyAlpha", "polyAlpha", value = 0.2, min = 0, max = 1, step = 0.05),
                    
                    checkboxInput("addDots", "addDots", value = TRUE),
                    
                    checkboxInput("showToolTipLabel", "showToolTipLabel", value = FALSE),
                    
                    checkboxInput("responsive", "responsive", value = TRUE),
                    
                    radioButtons("colMat", "colMatrix", choices=c("Matrix", "Named"), 
                                 selected = "Named", inline = TRUE),
                    
                    uiOutput("colMatText"),
                    actionButton("colButton", "Update")
                )
            )
            
            
            # IMPORTANT: radarchart does not work in tabs 
            # tabItems(
            #     tabItem("dashboard",
            #     tags$head(
            #         tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
            #     ),
            #    
            #     )
            #     ,
            # 
            #     tabItem("ui",
            #             numericInput("maxrows", "Rows to show", 25),
            #             verbatimTextOutput("rawtable"),
            #             downloadButton("downloadUI", "Download as CSV")
            #     ),
            # 
            #     tabItem("server",
            #             numericInput("maxrows", "Rows to show", 25),
            #             verbatimTextOutput("rawtable"),
            #             downloadButton("downloadServer", "Download as CSV")
            #     )
            #     
            # )
        )
    )
    
