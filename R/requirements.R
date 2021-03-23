packages = scan("requirements.txt", what = "character")

## install & load required packages
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

fileURL = "https://raw.githubusercontent.com/iobis/mregions/master/R/mr_gazetteer.R"
destfile='mr_gazetteer.R'
if(!file.exists(destfile)){
  res <- tryCatch(download.file(fileURL,
                                destfile=destfile,
                                method="auto"),
                  error=function(e) 1)
  if(dat!=1) source("mr_gazetteer.R") 
}
source("mr_gazetteer.R")
