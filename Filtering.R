- 👋 Hi, I’m @FatemehDehghanNezhad
- 👀 I’m interested in neuroscience
- 🌱 I’m currently learning R
- 📫 f.dehghan.nezhad.d@gmail.com

##Narrowing down list of papers from Scopus using the JCI ranking
# Importing necessary packages
library(bibliometrix)

# Importing datasets
jrank <- read.csv("scimagojr 2021.csv", header = TRUE, sep = ";")
jrank1<-read.csv("JCR-2020-SSCI.csv", header = TRUE, sep = ",")
neuro<-convert2df("scopus.bib", dbsource = "scopus", format = "bibtex")

# Preprocessing column data (lower casing, deleting punctuations and extra spaces)
neuro$SO<-tolower(neuro$SO)
neuro$SO<-gsub("[[:punct:]]", "", neuro$SO)
neuro$SO<-gsub("\\s+", " ", neuro$SO)
jrank$Title<-tolower(jrank$Title)
jrank$Title<-gsub("[[:punct:]]", "", jrank$Title)
jrank$Title<-gsub("\\s+", " ", jrank$Title)
jrank1$Journal.name<-tolower(jrank1$Journal.name)
jrank1$Journal.name<-gsub("[[:punct:]]", "", jrank1$Journal.name)
jrank1$Journal.name<-gsub("\\s+", " ", jrank1$Journal.name)

# Matching elements from the column of respective journals in main bibliography dataframe  
match1= as.data.frame(match(neuro$SO, jrank$Title, nomatch = NA, incomparables = NA))
match2= as.data.frame(match(neuro$SO, jrank1$Journal.name, nomatch = NA, incomparables = NA))

# Changing the decimal point form from comma to dot 
jrank$SJR <- gsub(',', '.', jrank$SJR)
jrank1$X2020.JCI <- gsub(',', '.', jrank1$X2020.JCI)

# Finding the row number of matches and assigning corresponding data to new columns
n = nrow(match1) # Number of rows in the main  bibliography data frame
for (x in 1:n) {
  j = as.integer(match1[x,1]) 
  sjr = jrank[j,'SJR']
  neuro[x,'SJR']=sjr
  Q = jrank[j, "SJR.Best.Quartile"]
  neuro[x,"SJR.Quartile"] = Q
  h = jrank[j, "H.index"]
  neuro[x,"H.Index"] = h
  hindex = jrank[j, "Rank"]
  neuro[x,"H.Index"] = hindex
  k = as.integer(match2[x,1]) 
  jci = jrank1[k,'X2020.JCI']
  neuro[x,'JCI.2020'] = jci
}

# Deleting rows that don't have JCI or SJR ranking and sorting data based on column
neuro <- neuro[!is.na(neuro$JCI.2020),]
neuro <- neuro[!is.na(neuro$SJR.Quartile),]
neuro$JCI.2020 <-sort(neuro$JCI.2020, decreasing = FALSE, na.last = TRUE)

# Exporting the dataframe in csv format
write.csv(neuro,"Final Dataset.csv", row.names = FALSE)
