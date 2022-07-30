
# Load Libraries ---------------------------------------------------------------

library(readxl)
library(here)
library(tidyverse)
library(janitor)

# Load Data ---------------------------------------------------------------

birds <- read_xls(here("raw_data/seabirds.xls"), 
                  sheet = "Bird data by record ID")
ships <- read_xls(here("raw_data/seabirds.xls"), 
                  sheet = "Ship data by record ID")

# Join Tables -------------------------------------------------------------

seabirds <- left_join(birds, ships, "RECORD ID")

# Investigate Data --------------------------------------------------------

#glimpse(seabirds)
#summary(seabirds)
#skimr::skim(seabirds)
# I've kept these commented in case anyone running the code didn't 
# want all the output!

# Cleaning Data -----------------------------------------------------------

# so from the notes and from the above investigation we can:

# 1 sort column names
# 2 drop 2 columns with only 1, 4 values out of 49019 (4 more cols were 
#   borderline but we will keep these for now)

# lets sort all these uppercase column names
seabirds <- clean_names(seabirds)

# lets drop cols sex and sal. sex only has 1/49019 values, SAL has 3/49017
seabirds <- seabirds %>% 
  select(-sex, -sal)

# Can we use this data now? It has a lot of NAs but i suppose a lot are just
# the way the data is recorded and the way the dataset is setup. Not every
# observation would have all fields completed.

seabirds %>% 
write_csv(here("clean_data/seabirds.csv"))
