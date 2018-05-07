# This data loads and pre-processes
# all data in the data folder. Run this
# file before all other code.

# check and install required libraries
if(!require(tidyverse)){install.package("tidyverse")}
if(!require(readxl)){install.package("readxl")}
if(!require(ggplot2)){install.package("ggplot2")}

# load libraries
library(tidyverse)
library(readxl)
library(ggplot2)

# ugly path
path = "./data/climate_data_availability/"

# list all files in the path above
files = list.files(path,"*", full.names = TRUE)
files = files[grepl("[0-9]_data.xlsx",files)][-1]

# read and combine the data in a tidy dataframe
data = do.call("rbind",lapply(files, function(file){
  df = try(readxl::read_xlsx(file))
  if(inherits(df, "try-error")){
    return(NULL)
  } else {
  return(data.frame(inventory_nr = df$`inventory nr`,
                    name = df$name,
                    month = df$month,
                    year = df$year,
                    temp_min = df$temp_min,
                    temp_max = df$temp_max,
                    precip = df$precip))
  }
}))

# quick summary and barplot
site_years = data %>%
  summarise(temp_min = sum(temp_min, na.rm = TRUE)/12,
            temp_max = sum(temp_max, na.rm = TRUE)/12,
            precip = sum(precip, na.rm = TRUE)/12)
barplot(unlist(site_years))
