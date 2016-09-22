######
# filename: Watson-TweetlyzR/server.R
# created: 2016-09-21 by Rudy Martin (realrudymartin@gmail.com)
# This is the server file for a Shiny web application that plots personality data.
# It takes a persona's tweets and performs a lexical analysis using the 
# IBM's Watson Personality Insights API.
# For more information about this visit github.com/RudyMartin/Watson-TweetlyzR
# THIS IS EXPERIMENTAL CODE SO USE AT YOUR OWN RISK AND POST ISSUES ON GITHUB
######
devtools::install_github("MangoTheCat/radarchart")



    library(radarchart) # used for radar charts
    library(dplyr) # used to create a dynamic query
    library(reshape2) # used to dcast
    # This local file contains functions used in this session.
    # Use this to add Create/Read/Update/Delete (CRUD) actions here.
    source("helpers.R", local=TRUE)
    
    shinyServer(function(input, output) {
        
        v <- reactiveValues( cmText = col2rgb(c("red", "forestgreen", "navyblue")))
        
        observeEvent(input$colButton, {
            if(!is.null(input$colMatValue)) {
                v$cmText <- eval(parse(text=input$colMatValue))
            } else {
                v$cmText <- NULL
            }
        })
        
        output$colMatText <- renderUI({
            cmValue <- reactive({
                if (input$colMat == "Named") {
                    'col2rgb(c("red", "forestgreen", "navyblue"))'
                } else {
                    "matrix(c(255, 0, 0, 34, 139, 34, 0, 0, 128), nrow = 3)"
                }
            })
            textInput("colMatValue", "Code: ", value=cmValue())
        })    
            
      output$downloadUI <- downloadHandler(
            filename = "realrudymartin.csv",
            content = function(file) {
                write.csv(pkgData(), file)
            },
            contentType = "text/csv"
      )
      
      output$downloadServer <- downloadHandler(
          filename = "realrudymartin.csv",
          content = function(file) {
              write.csv(pkgData(), file)
          },
          contentType = "text/csv"
      )   
        
      output$rawtable <- renderPrint({
          orig <- options(width = 1000)
          print(tail(pkgData(), input$maxrows))
          options(orig)
      }
      )
      
      output$radarCall <- reactive({
          
          sk <- paste0("skills2",paste0(paste0('"', input$selectedFeatures, '"'), collapse=", "), ")]",
                       collapse="")
          
          ms <- paste0("maxScale = ", ifelse(input$maxScale>0, input$maxScale, "NULL"))
          
          sw <- paste0("scaleStepWidth = ", 
                       ifelse(input$scaleStepWidth>0, input$scaleStepWidth, "NULL"))
          sv <- paste0("scaleStartValue = ", input$scaleStartValue)
          
          ls <- paste0("labelSize = ", input$labelSize)
          
          ad <- paste0("addDots = ", as.character(input$addDots))
          
          tt <- paste0("showToolTipLabel = ", as.character(input$showToolTipLabel))
          
          la <- paste0("lineAlpha = ", input$lineAlpha)
          
          pa <- paste0("polyAlpha = ", input$polyAlpha)
          
          rs <- paste0("responsive = ", as.character(input$responsive))
          
          cm <- paste0("colMatrix = ", input$colMatValue)
          
          arguments <- c(sk, ms, sw, sv, rs, ls, ad, la, pa, tt, cm)
          
          arguments[1] <- paste0("chartJSRadar(", arguments[1])
          arguments[length(arguments)] <- paste0(arguments[length(arguments)], ")")
          
          paste(arguments, sep="", collapse=", ")
          
      })
      
      output$radar <- renderChartJSRadar({
          
          # Convert zero to a NULL
          maxScaleR <- reactive({
              if (input$maxScale>0)
                  input$maxScale
              else
                  NULL
          })
          # Convert zero to a NULL
          scaleStepWidthR <- reactive({
              if (input$scaleStepWidth>0)
                  input$scaleStepWidth
              else
                  NULL
          })
          
          
          ReadData()
          skills2 <- filter(skills2, grepl(paste(input$selectedFeatures,collapse="|"), 
                                            skills2$category))
          demos2d <- dcast(skills2, formula = userID ~ trait) 
          df_2 <- as.data.frame(
              do.call(rbind, lapply(demos2d[-1], function(x) unlist(x))),
              stringsAsFactors = TRUE)
          colnames(df_2) <- unlist(demos2d[1], use.names=FALSE)
          df_2$Label <- as.factor(rownames(df_2))
          rownames(df_2) <- NULL
          scores <- df_2 %>% select (Label, everything())
          
          # use scoresTest to be sure this is working and your data is in correct format.
          # scoresTest <- data.frame("Label"=c("Communicator", "Data Wangler", "Programmer",
          #                                "Technologist",  "Modeller", "Visualizer"),
          #                      "realrudymartin" = c(.9, .7, .4, .5, .3, .7),
          #                      "ladygaga" = c(.7, .6, .6, .2, .6, .9),
          #                      "kanyewest" = c(.6, .5, .8, .4, .7, .6))
         
          # chartJSRadar(scoresTest[, c("Label", input$selectedPersonas)], 
          #              maxScale = 100,
          #              scaleStepWidth = NULL, 
          #              scaleStartValue = 0,
          #              responsive = TRUE, 
          #              labelSize = 16, 
          #              addDots = TRUE, 
          #              lineAlpha = 0.8,
          #              polyAlpha = 0.2, 
          #              showToolTipLabel = TRUE, 
          # colMatrix = col2rgb(c("red", "forestgreen", "navyblue"))
          
          chartJSRadar(scores[, c("Label", input$selectedPersonas)], 
                       maxScale = maxScaleR(),
                       scaleStepWidth = scaleStepWidthR(),
                       scaleStartValue = input$scaleStartValue,
                       responsive = input$responsive,
                       labelSize = input$labelSize,
                       addDots = input$addDots,
                       lineAlpha = input$lineAlpha,
                       polyAlpha = input$polyAlpha,
                       showToolTipLabel=input$showToolTipLabel,
                       colMatrix = v$cmText)
          
        })
    
    
      output$radarCall <- reactive({
          
          sk <- paste0("skills2",paste0(paste0('"', input$selectedFeatures, '"'), collapse=", "), ")]",
                       collapse="")
          
          ms <- paste0("maxScale = ", ifelse(input$maxScale>0, input$maxScale, "NULL"))
          
          sw <- paste0("scaleStepWidth = ", 
                       ifelse(input$scaleStepWidth>0, input$scaleStepWidth, "NULL"))
          sv <- paste0("scaleStartValue = ", input$scaleStartValue)
          
          ls <- paste0("labelSize = ", input$labelSize)
          
          ad <- paste0("addDots = ", as.character(input$addDots))
          
          tt <- paste0("showToolTipLabel = ", as.character(input$showToolTipLabel))
          
          la <- paste0("lineAlpha = ", input$lineAlpha)
          
          pa <- paste0("polyAlpha = ", input$polyAlpha)
          
          rs <- paste0("responsive = ", as.character(input$responsive))
          
          cm <- paste0("colMatrix = ", input$colMatValue)
          
          arguments <- c(sk, ms, sw, sv, rs, ls, ad, la, pa, tt, cm)
          
          arguments[1] <- paste0("chartJSRadar(", arguments[1])
          arguments[length(arguments)] <- paste0(arguments[length(arguments)], ")")
          
          paste(arguments, sep="", collapse=", ")
          
      })
      
    })