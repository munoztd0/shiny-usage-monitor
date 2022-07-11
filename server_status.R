
library(this.path)
library(pacman)

pacman::p_load(shiny, tidyverse, lubridate, this.path, highcharter)

path <- dirname(this.path())
 # detect directory of the script, thus cannot be run in console normally 
setwd(path) ## Setup work directory; change this.path() to your path if you want to test the code in your console


RData <- "sysLoad.RData"

if (!file.exists(RData)) { 
    Dat <- NULL
} else { load(RData) }

I <- 0
repeat{ 
    system("top -n 1 -b -u shiny > top.log") 
    dat <- readLines("top.log") 
    id <- grep("R *$", dat) 
    Names <- strsplit(gsub("^ +|%|\\+", "", dat[7]), " +")[[1]] 
    if (length(id) > 0) { 
        # 'top' data frame; 
        L <- strsplit(gsub("^ *", "", dat[id]), " +") 
        dat <- data.frame(matrix(unlist(L), ncol = 12, byrow = T)) 
        names(dat) <- Names 
        dat <- data.frame(Time = Sys.time(), dat[, -ncol(dat)], usr = NA, app = NA) 
        dat$CPU <-as.numeric(as.character(dat$CPU)) 
        dat$MEM <-as.numeric(as.character(dat$MEM)) 
        # Check if connection number changed; 
        for (i in 1:length(dat$PID)) { 
            PID <- dat$PID[i] 
            system(paste("sudo netstat -p | grep", PID, "> netstat.log")) 
            system(paste("sudo netstat -p | grep", PID, ">> netstat.log2"))
             system(paste("sudo lsof -p", "535961", "| grep", paste("/srv/shiny-server/", sep=""), "> lsof.log")) 
             netstat <- readLines("netstat.log") 
             lsof <- readLines("lsof.log") 
             dat$usr[i] <- length(grep("ESTABLISHED", netstat) & grep("tcp", netstat)) 
             dat$app[i] <- regmatches(lsof, regexec(paste("/srv/shiny-server/(.*)", sep=""), lsof))[[1]][2]
            } 
         if (!is.null(Dat)) {
             dat.a <- Dat[which(Dat$Time == max(Dat$Time)),] 
             con.a <- dat.a$usr[order(dat.a$app)] 
             con.b <- dat$usr[order(dat$app)] 
             if (paste(con.a, collapse = "") == paste(con.b, collapse = "")) { 
                 changed <- FALSE 
                 } else { changed <- TRUE } 
                 } else { changed <- TRUE } 
             # Keep only the lines containing important information to same storage space; 
        if (any(dat$CPU > 5) | any(dat$MEM > 50) | changed) { 
            Dat <- rbind(Dat, dat) 
            Dat <- Dat[which(Dat$Time > (max(Dat$Time)-30*24*60*60)), ] 
            save(Dat, file = RData) } 
            } 
        Sys.sleep(5) 
        I <- I + 5 
        if (I >= 60) {
            break}
        }