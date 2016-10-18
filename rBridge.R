library(stringr)

fileName <- 'sample-graql-output.txt'
fullOutput <- readChar(fileName, file.info(fileName)$size)
### REMEMBER TO SET THE PATH TO THE MINDMAPS BIN FOLDER BEFORE USING THIS SCRIPT
graqlPath <- 'PATHNOTSET'

# break a string pattern into its component parts for loading into the data frame
decomposePattern <- function(line) {
  #return(str_match(line,'\\$([a-zA-Z0-9_-]+) (id|value) (.*) isa'))
  colourRegExp <- '\033\\[[\\d;]*m'
  varRegExp <- '\\$([a-zA-Z0-9_-]+)'
  return(str_match(line,paste(varRegExp,colourRegExp,' (id|value) ',colourRegExp,'(.*)',colourRegExp,' isa',sep='')))
}


# process the string output of the graql terminal
processGraqlOutput <- function(listOfLines) {
  # decompose the output by splitting the line into patterns
  listOfPatterns <- strsplit(listOfLines,'; ',TRUE)


  # create headers for data frame
  nCols <- length(listOfPatterns[[1]])
  nRows <- length(listOfPatterns)
  columns = vector("list",nCols)

  # process the patterns in order and load into a data frame
  for (line in listOfPatterns) {
    for (i in 1:length(line)) {
      columns[[i]] <- c(columns[[i]],castToCorrectType(decomposePattern(line[i])[4]))
    }
  }

  # prepare data frame with correct headers
  dataFrame <- data.frame(columns, stringsAsFactors = FALSE)
  names(dataFrame) <- prepareDataFrameHeaders(listOfPatterns)
  return(dataFrame)
}

executeQuery <- function(query) {
  graqlPrefix <- paste(graqlPath,'graql.sh',sep='')
  return(system2(graqlPrefix,paste('-e "',gsub('\\$','\\\\$',query),'"',sep=''),stdout=TRUE))
}

prepareDataFrameHeaders <- function(listOfPatterns) {
  headers <- character()
  for (pattern in listOfPatterns[[1]]) {
    parts <- decomposePattern(pattern)
    headers <- c(headers, parts[2])
  }
  return(headers)
}

castToCorrectType <- function(value) {
  potentialNumber <- as.numeric(value)
  if (is.na(potentialNumber)) {
    return(value)
  } else {
    return(potentialNumber)
  }
}

processGraqlQuery <- function(query) {
  if (graqlPath == 'PATHNOTSET') {
    return('The path to Graql Bin folder has not been set in the script file')
  }
  return(processGraqlOutput(executeQuery(query)))
}
