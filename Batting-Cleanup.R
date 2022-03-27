
library(dplyr)
library(tidyr)
library(data.table)



pitching.files <- list.files("./Batting-Stats")[1:12]
sc <- read.csv("./Batting-Stats/Statcast.csv")
sc <- sc %>% 
  mutate(Name=paste(sc$first_name,sc$last_name,sep=' '))
sc$Name <- trimws(sc$Name,which="left")

# Advanced
df1 <- read.csv(paste("./Batting-Stats/",pitching.files[1],sep=""))
df2 <- read.csv(paste("./Batting-Stats/",pitching.files[2],sep=""))
df3 <- read.csv(paste("./Batting-Stats/",pitching.files[3],sep=""))
df4 <- read.csv(paste("./Batting-Stats/",pitching.files[4],sep=""))
df5 <- read.csv(paste("./Batting-Stats/",pitching.files[5],sep=""))
if (args != "predict") {
  df6 <- read.csv(paste("./Batting-Stats/",pitching.files[6],sep=""))
  df6$Year <- 2021
} 

# Standard
df7 <- read.csv(paste("./Batting-Stats/",pitching.files[7],sep=""))
df8 <- read.csv(paste("./Batting-Stats/",pitching.files[8],sep=""))
df9 <- read.csv(paste("./Batting-Stats/",pitching.files[9],sep=""))
df10 <- read.csv(paste("./Batting-Stats/",pitching.files[10],sep=""))
df11 <- read.csv(paste("./Batting-Stats/",pitching.files[11],sep=""))
if (args != "predict") {
  df12 <- read.csv(paste("./Batting-Stats/",pitching.files[12],sep=""))
  df12$Year <- 2021
} 
df1$Year <- 2015
df2$Year <- 2016
df3$Year <- 2017
df4$Year <- 2018
df5$Year <- 2019
df7$Year <- 2015
df8$Year <- 2016
df9$Year <- 2017
df10$Year <- 2018
df11$Year <- 2019

std <- merge(df1,df7,by=c("Name","Tm"))
std2 <- merge(df2,df8,by=c('Name',"Tm"))
std3 <- merge(df3,df9,by=c("Name","Tm"))
std4 <- merge(df4,df10,by=c("Name","Tm"))
std5 <- merge(df5,df11,by=c("Name","Tm"))
bref <- rbind(std,std2)
bref <- rbind(bref,std3,std4,std5)
if (args != "predict") {
  std6 <- merge(df6,df12,by=c("Name","Tm"))
  bref <- rbind(bref,std6)
}

bref$year <- bref$Year.x

bref <- bref %>%
  separate(Name,c("Name","Extra"),sep="(?:(?!\\.)[[:punct:]])+",extra='drop') %>%
  drop_na(Age.x) 

#bref <- merge(bref,sc,by=c("Name","year"))

bref <- bref %>%
  select(-c(Rk.y,Rk.x,Age.y,Year.y,)) %>%
  group_by(Name,Year.x) %>%
  mutate(Mult = ifelse(row_number() > 1 , 1,0),
         Flag = ifelse(Tm != "TOT" & Mult == 1,1,0)) %>%
  filter(Flag == 0) %>%
  select(-c(Flag)) %>%
  distinct(Name,year,Tm,.keep_all = T) %>%
  ungroup()

bref$GB. <- as.numeric(gsub("[\\%,]", "", bref$GB.))
bref$FB. <- as.numeric(gsub("[\\%,]", "", bref$FB.))
bref$HR. <- as.numeric(gsub("[\\%,]", "", bref$HR.))
bref$SO. <- as.numeric(gsub("[\\%,]", "", bref$SO.))
bref$BB. <- as.numeric(gsub("[\\%,]", "", bref$BB.))
bref$LD. <- as.numeric(gsub("[\\%,]", "", bref$LD.))
bref$HardH. <- as.numeric(gsub("[\\%,]", "", bref$HardH.))
bref$Cent. <- as.numeric(gsub("[\\%,]", "", bref$Cent.))
bref$Pull. <- as.numeric(gsub("[\\%,]", "", bref$Pull.))
bref$Oppo. <- as.numeric(gsub("[\\%,]", "", bref$Oppo.))
bref$RS. <- as.numeric(gsub("[\\%,]", "", bref$RS.))
bref$SB. <- as.numeric(gsub("[\\%,]", "", bref$SB.))
