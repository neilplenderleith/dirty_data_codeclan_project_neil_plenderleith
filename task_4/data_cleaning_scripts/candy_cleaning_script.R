library(tidyverse)
library(readxl)
library(here)
library(janitor)

candy_2015 <- read_excel(here("raw_data/boing-boing-candy-2015.xlsx"))
candy_2016 <- read_excel(here("raw_data/boing-boing-candy-2016.xlsx"))
candy_2017 <- read_excel(here("raw_data/boing-boing-candy-2017.xlsx"))

candy_2017 %>% 
  count("Q4: COUNTRY")

table(candy_2017["Q4: COUNTRY"]) # look at dirty column 'country' eek
names(candy_2015)

# lets pass through clean_names to get rid of punctuation and bad column names
candy_2015_clean <- candy_2015 %>% 
  clean_names()
candy_2016_clean <- candy_2016 %>% 
  clean_names()
candy_2017_clean <- candy_2017 %>% 
  clean_names()

# lets have a look at column names
names(candy_2015_clean)
names(candy_2016_clean)
names(candy_2017_clean)


# Order of Operations:
# Get large pivot data the same for all 3 datasets
# perform pivot on all three
# then investigate other columns

# let first start with all the columns between "100_grand_bar" and 
# "york peppermint butter"
candy_2015_clean <- candy_2015_clean %>% 
  #rename("100_grand_bar" = "x100_grand_bar") %>% 
  relocate(butterfinger, .after = bubble_gum)
           
           
candy_2016_clean <- candy_2016_clean %>% 
  rename("100_grand_bar" = "x100_grand_bar")

# 2017 data required a q1_, q2_ etc removed from the column names
candy_2017_clean <- candy_2017_clean %>% 
  rename_with( ~ str_remove(., pattern = "q[0-90-9]+_"))



# looks like there is a big pivot longer needed on all data
# lets have a look at column numbers for each dataset

# 2015 - x100 grand bar to york peppermint patties

candy_2015_long <- candy_2015_clean %>% 
  pivot_longer(`100_grand_bar`:york_peppermint_patties, names_to = "candy_type", values_to = "candy_rating")

candy_2016_long <- candy_2016_clean %>% 
  pivot_longer(`100_grand_bar`:york_peppermint_patties, names_to = "candy_type", values_to = "candy_rating")

candy_2017_long <- candy_2017_clean %>% 
  pivot_longer(`100_grand_bar`:york_peppermint_patties, names_to = "candy_type", values_to = "candy_rating")


