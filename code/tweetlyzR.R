######
# filename: Watson-TweetlyzR/tweetlyzR.R
# created: 2016-09-21 by Rudy Martin (realrudymartin@gmail.com)
# This script extracts social media commentary from Twitter
# This file helps a Shiny web application that plots personality data.
# It takes a persona's tweets and performs a lexical analysis using the 
# IBM's Watson Personality Insights API.
#
# IMPORTANT : 
# THIS FILE WAS BUILT TO BE RUN MANUALLY FOR CREATING PROFILE FILES
# Path for files is set to responses and read/write access required to run
# Application will not work until there are valid data files in response folder
#
# For more information about this visit github.com/RudyMartin/Watson-TweetlyzR
# THIS IS EXPERIMENTAL CODE SO USE AT YOUR OWN RISK AND POST ISSUES ON GITHUB
######

    pkgs <-c('data.table','jsonlite','Hmisc','radarchart')
    for(p in pkgs) if(p %in% rownames(installed.packages()) == FALSE) {install.packages(p)}
    for(p in pkgs) suppressPackageStartupMessages(library(p, quietly=TRUE, character.only=TRUE))
    
    # load libraries and authenticate Twitter
    source("credentials-twitterAuth.R")
    
    ######
    # LOAD AND SCRUB TWEETS 
    ######
    
    
    setTwitterHandle <- function(p1=NULL) {
        if(is.null(p1)) {
            handle <- "realrudymartin"
        } else {
            handle <- p1
        }
        handle
    }
    handle <- setTwitterHandle("realrudymartin") # change name here - then run file.
    
    
    tweets_raw <- userTimeline(handle,n=200)
    # str(memberTimeline)
    # is.list(memberTimeline)
    
    tweetsData <- 
        ldply(tweets_raw, function(x) {
            data_frame(id = x$id,
                       date = as.Date(x$created),
                       day = weekdays(date),
                       favorites = x$favoriteCount,
                       retweets = x$retweetCount,
                       title = x$text
            )
        })
    
    tweetsData$title
    
    #favText <- twitteR::as.data.frame(memberTimeline.text)
    
    favText = rbindlist(lapply(tweetsData$title,as.data.frame))
    
    # rm(tweets_raw)  # being extremely memory conscious
    
    scrubString <- function(y){
        # remove links
        y <- gsub('http\\S+\\s*',"", y)
        # remove backslash
        y <- gsub("\\\\","", y)
        # remove html tags
        y <- gsub("<(.|\n)*?>","", y)
        # remove line breaks
        y <- gsub("[\r\n]", " ", y)
        # remove line breaks
        y <- gsub("[\n]", " ", y)
        # remove digits
        y <- gsub("[[:digit:]]", "", y)
        # remove dots
        #string <- gsub("[.]{2}", ".", string)
        y <- gsub("[.]+", ".", y)
        # remove non-alphanumerics or spaces
        y <- gsub("[^[:alnum:][:space:]'\"]", "", y)
        # remove double spaces
        y <- gsub("[[:space:]]{2}"," ", y)
        # remove trailing spaces
        y <- gsub("[[:space:]]*$","", y)
        
        return(y)
        
    }
    
    cleanText <-lapply(favText,function(i) scrubString(i))
    
    cleanDoc <- as.character(as.list(toString(cleanText)))
    
    ######
    # SET PERSONALITY INSIGHTS API credentials (Personality Insights-s5)
    ###### 
    
    source("credentials-personality-insights.R")
    
    ###### 
    # FUNCTIONS - ANalyze text with Personality Insights service 
    ###### 
    
    watson.personality_insights.analyze <- function(TEXT)
    {
        return(POST(url=pi_url,
                    authenticate(username,password),
                    add_headers("Content-Type"="text/plain","charset"="utf-8" ),
                    body = TEXT
        ))
    }
    
    # requires library(Hmisc)
    tidyResponse <- function(data) 
    {
        data <- jsonlite::fromJSON(PI_text)
        data <- as.data.frame(strsplit(as.character(data),"\"id\":\""))
        data <- data[-c(1:5), ] # remove dud first row
        data <- data.frame(matrix(data)) 
        data[,1]  <- gsub("\"","",data[,1] ) 
        data <- data.frame(do.call('rbind', strsplit(as.character(data$matrix.data),',',fixed=TRUE)))
        data <- data[!grepl('name:',data$X5),]
        data <- data[!grepl('children:',data$X5),]
        data <- data[!grepl('NA',data$X5),]
        data <- data[,-c(2,6), ] # remove columns we dont need - duplicates or dont care for SAMPLING ERROR (now) but mght later
        rownames(data) <- NULL # resets row names to remove 'gaps'
        data$row <- as.numeric(rownames(data))
        data <- data[,c(5,2,1,3,4)] # reorder columns
        setnames(data,c("row","category","trait","percentage","sampling_error"))
        data$category <- gsub("category:","",data$category)
        data$category <- capitalize(data$category)
        data$percentage <- gsub("percentage:","",data$percentage)
        data$sampling_error <- gsub("sampling_error:","",data$sampling_error) 
        data$sampling_error <- gsub("}","",data$sampling_error) # crude but effective
        data$sampling_error <- gsub("]","",data$sampling_error) # crude but effective
        data$percentage <- round((as.numeric(data$percentage)),4)*100 # if you prefer % format like this
        data$sampling_error <- round((as.numeric(data$sampling_error)),4) # if you prefer % format like this
        return(data)
    } # warning - this code seems to work but has not been verified - please be careful
    
    responseItem <- watson.personality_insights.analyze(cleanDoc)
    # responseItem$status_code 
    # This should be a status 200 if it went well - if not, check your authentication  or look at content(response,"text")
    # str(responseItem)
    
    ###### 
    # SCRUB RESPONSE DATA 
    ###### 
    
    PI_text <- toJSON(content(responseItem,"text"))
    # PI_text
    MyData <- tidyResponse(PI_text)
    flare <- MyData[,c(1,2,3,4)]
    #flare
    MyData$userID <- handle
    MyData$createDate <- Sys.Date()
    # MyData
    myExport <- MyData[,c(6,7,1,2,3,4,5)]
    # write.csv(myExport,"myexport.csv")
    
    ###### 
    # SAVE AND LOAD PROFILES 
    ######  
    
    # LOCAL CSV FILES VERSION - NOT SUITABLE FOR PRODUCTION ENVIRONMENTS
    
    saveProfile <- function(data) {
        #data <- t(data)
        # Create a unique file name using anonymous naming to preserve confidentiality
        fileName <- sprintf("%s_%s.csv", as.integer(Sys.time()), digest::digest(data))
        # Write the file to the local system
        write.table(
            x = data,
            file = file.path(outputDir, fileName), 
            row.names = FALSE, quote = TRUE,
            sep=",",  col.names=TRUE
        )
    }
    
    loadProfile <- function() {
        # Read all the files into a list
        files <- list.files(outputDir, full.names = TRUE)
        data <- lapply(files, read.csv, stringsAsFactors = FALSE) 
        # Concatenate all data together into one data.frame
        data <- do.call(rbind, data)
        data
    }
    
    outputDir <- "responses"
    mainDir <- getwd()
    
    if (!file.exists(outputDir)){
        dir.create(file.path(mainDir, outputDir), showWarnings = FALSE)
    } else {
        profileScores <<- loadProfile()
    }
    
    if (!handle %in% profileScores$userID){
        saveProfile(myExport)
        profileScores <<- loadProfile()
    }
    
