######
# filename: Watson-TweetlyzR/credentials-twitterAuth.R
# created: 2016-09-21 by Rudy Martin (realrudymartin@gmail.com)
# This file logs in to Twitter
# For more information about this visit github.com/RudyMartin/Watson-TweetlyzR
# THIS IS EXPERIMENTAL CODE SO USE AT YOUR OWN RISK AND POST ISSUES ON GITHUB
######
    
    pkgs <-c('twitteR','ROAuth','httr','plyr','dplyr','stringr','ggplot2','plotly')
    for(p in pkgs) if(p %in% rownames(installed.packages()) == FALSE) {install.packages(p)}
    for(p in pkgs) suppressPackageStartupMessages(library(p, quietly=TRUE, character.only=TRUE))
    
    #install.packages("twitteR")
    #install.packages("base64enc")
    # restart RStudio after restart
    
    # REPLACE XXX with your credentials
    # Set API Keys (realrudymartin-tweets)
    options(httr_oauth_cache=T)
    api_key <- "XXXXXXX"
    api_secret <- "XXXXXXX"
    access_token <- "XXXXXXX"
    access_token_secret <- "XXXXXXX"
    
    setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)