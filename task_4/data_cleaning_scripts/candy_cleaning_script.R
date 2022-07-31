library(tidyverse)
library(readxl)
library(here)

candy_2015 <- read_excel(here("raw_data/boing-boing-candy-2015.xlsx"))
candy_2016 <- read_excel(here("raw_data/boing-boing-candy-2016.xlsx"))
candy_2017 <- read_excel(here("raw_data/boing-boing-candy-2017.xlsx"))

candy_2017 %>% 
  count("Q4: COUNTRY")

table(candy_2017["Q4: COUNTRY"])
