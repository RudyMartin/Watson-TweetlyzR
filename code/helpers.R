######
# filename: Watson-TweetlyzR/helpers_local.R
# created: 2016-09-21 by Rudy Martin (realrudymartin@gmail.com)
# This file helps a Shiny web application that plots personality data.
# It takes a persona's tweets and performs a lexical analysis using the 
# IBM's Watson Personality Insights API.
# For more information about this visit github.com/RudyMartin/Watson-TweetlyzR
# THIS IS EXPERIMENTAL CODE SO USE AT YOUR OWN RISK AND POST ISSUES ON GITHUB
######

    ReadData <- function() {
        
        loadProfile <- function() {
            
            # Read all the files into a list
            files <- list.files(outputDir, full.names = TRUE)
            data <- lapply(files, read.csv, stringsAsFactors = FALSE) 
            # Concatenate all data together into one data.frame
            data <- do.call(rbind, data)
            data
        }
        outputDir <<- "responses" 
        mainDir <<- getwd()
        # IMPORTANT:
        # The response directory MUST exist AND have good data files to work!!
        if (!file.exists(outputDir)){
            dir.create(file.path(mainDir, outputDir), showWarnings = FALSE)
        } else {
            profileScores <<- loadProfile()
            # Drop unwanted features from raw data and create lookup sets
            skills2 <<- profileScores[,grep('userID|category|trait|percentage', 
                                            x = names(profileScores) )]
            #skills2$percentage <<- as.numeric(round((skills2$percentage*100),1))
            #colnames(skills2)[4] <- "value"
            personas <<- unique(skills2$userID)
            labs <<- c("Needs","Personality","Values")
        } 
    }