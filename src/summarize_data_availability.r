# Summarize data availability

# check and install required libraries
if(!require(tidyverse)){install.package("tidyverse")}
if(!require(readxl)){install.package("readxl")}
if(!require(ggplot2)){install.package("ggplot2")}
if(!require(ggthemes)){install.package("ggthemes")}

# load libraries
library(tidyverse)
library(readxl)
library(ggplot2)
library(ggthemes)

# ugly path
path = "./data/climate_data_availability/"

# list all files in the path above
files = list.files(path,"*", full.names = TRUE)
files = files[grepl("[0-9]_data.xlsx",files)][-1]

# read and combine the data in a tidy dataframe
# do this manually as check on the columns
data = do.call("rbind",lapply(files, function(file){
  df = try(readxl::read_xlsx(file))
  if(inherits(df, "try-error") | nrow(df) == 0 ){
    warning("error")
    return(NULL)
  } else {
    output = data.frame(inventory_nr = df$`inventory nr`,
                        name = df$name,
                        month = df$month,
                        year = df$year,
                        temp_min = df$temp_min,
                        temp_max = df$temp_max,
                        precip = df$precip,
                        humidity = df$relative_humidity)
    
  return(output)
  }
}))

# quick summary and barplot
site_years <- data %>%
  summarise("temperature (min)" = sum(temp_min, na.rm = TRUE)/12,
            "temperature (max)" = sum(temp_max, na.rm = TRUE)/12,
            "precipitation" = sum(precip, na.rm = TRUE)/12,
            "relative humidity" = sum(humidity, na.rm = TRUE)/12)

# wide to long
site_years <- gather(site_years)

p <- ggplot(site_years, aes(x = key, y = value)) +
  geom_bar(stat = "identity", fill="steelblue") +
  geom_text(aes(label=round(value)), vjust=1.6, color="white", size=3.5) +
  xlab("") +
  ylab("Frequency") +
  labs(title = "COBECORE Data Coverage",
       subtitle = "# of site years - Equateur Province") +
  theme_minimal() + 
  theme(text = element_text(size=18))

plot(p)

ggsave("output/cobecore_data_coverage.pdf")