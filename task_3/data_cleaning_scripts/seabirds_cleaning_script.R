
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

na_count <- seabirds %>%
summarise(across(.fns = ~ sum(is.na(.x)))) 
#this counts N/A values across all columns

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
       species_scientific_name = species_scientific_name_taxon_age_sex_plumage_phase,
       bird_count = count) # count is easily confused with the function

# UPDATE - In the end I decided to lose more non essential columns for the tasks
# These can be joined later if more anaylysis is required
# Lose some more non - essential columns
seabirds <- seabirds %>% 
  select(-(nfeed:record_y)) %>% 
  select(-(ew:depth)) %>% 
  select(-(csmeth:longecell), -wanplum)

#Lets tidy up the time column to just display the time and not the (incorrect) date
seabirds <- seabirds %>% 
  mutate(time = str_remove(time, "^[0-9]{4}-[0-9]+-[0-9]+ "))


# look at the bird_count column - there are some huge estimates for bird sightings
# looking at the codes in the data the bird_count column is birds spotted within a 10
# minute window - is 99999 even possible? Its difficult here to decide what to keep in 
# and what to take out? Doing some googling reveals the largest colony of shearwaters 
# is 3 million so 99999 is perhaps understandable. Lets leave these values as they stand
# seabirds %>% 
# count(bird_count) %>% 
# slice_max(bird_count, n = 20)

# Can we use this data now? It has a lot of NAs but i suppose a lot are just
# the way the data is recorded and the way the dataset is setup. Not every
# observation would have all fields completed. If I was just wanting data to 
# answer the tasks I could easily cut many columns



seabirds %>% 
write_csv(here("clean_data/seabirds.csv"))
