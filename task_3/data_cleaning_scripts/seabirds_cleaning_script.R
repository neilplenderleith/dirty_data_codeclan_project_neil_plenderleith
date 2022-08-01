
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

# na_count <- seabirds %>%
#  summarise(across(.fns = ~ sum(is.na(.x)))) 
# this counts N/A values across all columns

# Cleaning Data -----------------------------------------------------------

# so from the notes and from the above investigation we can:

# 1 sort column names
# 2 drop 3 columns with very few values out of 49019 (4 more cols were 
#   borderline but we will keep these for now)
# 3 change names of 2 long column names

# lets sort all these uppercase column names
seabirds <- clean_names(seabirds)

# lets drop cols sex, sal and plphase very few values
seabirds <- seabirds %>% 
  select(-sex, -sal, -plphase)

# lets change some long column names
seabirds <- seabirds %>% 
rename(species_common_name = species_common_name_taxon_age_sex_plumage_phase,
       species_scientific_name = species_scientific_name_taxon_age_sex_plumage_phase)

# Can we use this data now? It has a lot of NAs but i suppose a lot are just
# the way the data is recorded and the way the dataset is setup. Not every
# observation would have all fields completed.

seabirds %>% 
write_csv(here("clean_data/seabirds.csv"))
