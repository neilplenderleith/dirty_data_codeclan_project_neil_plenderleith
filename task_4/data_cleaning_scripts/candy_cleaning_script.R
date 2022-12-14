
# Libraries ---------------------------------------------------------------

library(tidyverse)
library(readxl)
library(here)
library(janitor)

# Load in Raw Data --------------------------------------------------------

candy_2015 <- read_excel(here("raw_data/boing-boing-candy-2015.xlsx"))
candy_2016 <- read_excel(here("raw_data/boing-boing-candy-2016.xlsx"))
candy_2017 <- read_excel(here("raw_data/boing-boing-candy-2017.xlsx"))


# Clean Column Names ------------------------------------------------------

# lets pass through clean_names to get rid of punctuation and bad column names
candy_2015_clean <- candy_2015 %>% 
  clean_names()
candy_2016_clean <- candy_2016 %>% 
  clean_names()
candy_2017_clean <- candy_2017 %>% 
  clean_names()

# First Look at Data  -----------------------------------------------------

# used glimpse(), summary(), view(), skimr::skim() on each to get an idea

# lets also have a look at column names
names(candy_2015_clean)
names(candy_2016_clean)
names(candy_2017_clean)

# Order of Operations:
# Get large pivot data the same for all 3 datasets
# perform pivot on all three
# then investigate other columns

# let first start with all the columns between "100_grand_bar" and 
# "york peppermint butter" these are out pivot to longer columns
candy_2015_clean <- candy_2015_clean %>% 
  rename("100_grand_bar" = "x100_grand_bar") %>% 
  relocate(butterfinger, .after = bubble_gum) %>% 
  relocate(necco_wafers, .after = minibags_of_chips)
           
           
candy_2016_clean <- candy_2016_clean %>% 
  rename("100_grand_bar" = "x100_grand_bar")

# 2017 data required a q1_, q2_ etc removed from the column names
candy_2017_clean <- candy_2017_clean %>% 
  rename_with( ~ str_remove(., pattern = "q[0-90-9]+_"))


# pivot longer on all three datasets for the candy and rating columns

candy_2015_long <- candy_2015_clean %>% 
  pivot_longer(`100_grand_bar`:york_peppermint_patties, 
               names_to = "candy_type", 
               values_to = "candy_rating")

candy_2016_long <- candy_2016_clean %>% 
  pivot_longer(`100_grand_bar`:york_peppermint_patties, 
               names_to = "candy_type", 
               values_to = "candy_rating")

candy_2017_long <- candy_2017_clean %>% 
  pivot_longer(`100_grand_bar`:york_peppermint_patties, 
               names_to = "candy_type", 
               values_to = "candy_rating")


# Ok pivots look good lets look through each dataset and see which columns are 
# required and which can go. In this decision I am thinking of the upcoming join
# of the three data frames. It looks like this will have to be a bind_rows function 
# I will hope to keep each column that's in at least 2 of the 3 data frames.

# 2015 Table


# lets work out how many NA's are across all columns and sort by highest
NA_2015 <- candy_2015_long %>%
  summarise(across(.fns = ~ sum(is.na(.x)))) %>% 
  pivot_longer(cols = everything(), 
               names_to = "old_column_name", 
               values_to = "count_of_NA") %>% 
  arrange(desc(count_of_NA))

# lets drop these 9 full NA columns - no use to us
candy_2015_long <- candy_2015_long %>% 
  select(-fill_in_the_blank_taylor_swift_is_a_force_for, 
         -starts_with("please_estimate_the_degrees_of_"))

# 2016

# lets work out how many NA's are across all columns and sort by highest
NA_2016 <- candy_2016_long %>%
  summarise(across(.fns = ~ sum(is.na(.x)))) %>% 
  pivot_longer(cols = everything(), 
               names_to = "old_column_name", 
               values_to = "count_of_NA") %>% 
  arrange(desc(count_of_NA))

# lets drop this full NA column - no use to us
candy_2016_long <- candy_2016_long %>% 
  select(-york_peppermint_patties_ignore)

#2017

# lets work out how many NA's are across all columns and sort by highest
NA_2017 <- candy_2017_long %>%
  summarise(across(.fns = ~ sum(is.na(.x)))) %>% 
  pivot_longer(cols = everything(), 
               names_to = "old_column_name", 
               values_to = "count_of_NA") %>% 
  arrange(desc(count_of_NA))

# lets drop columns x114 which is ambigous and very nearly empty as well as the
# media columns - these are also nearly empty and are not in the other datasets
candy_2017_long <- candy_2017_long %>% 
  select(-x114, 
         -starts_with("media"))


# Ok lets recap. We have removed the easy columns so far - the full NA's and 
# columns with very little data. Candy_2017_long has fewer columns than the 
# others - lets use this as a template for the other data frame columns and try to 
# get our column names matching to prepare data for a future join

names(candy_2015_long)
names(candy_2016_long)
names(candy_2017_long)

# lets get 2016 into shape - change col names to agree with 2017
candy_2016_long <- candy_2016_long %>% 
   rename(
  id = timestamp,
         going_out = are_you_going_actually_going_trick_or_treating_yourself,
         gender = your_gender,
         age = how_old_are_you,
         country = which_country_do_you_live_in,
         state_province_county_etc = which_state_province_county_do_you_live_in,
         joy_other = please_list_any_items_not_included_above_that_give_you_joy,
         despair_other = please_list_any_items_not_included_above_that_give_you_despair,
         other_comments = please_leave_any_witty_snarky_or_thoughtful_remarks_or_comments_regarding_your_choices,
         day = which_day_do_you_prefer_friday_or_sunday,
         dress = that_dress_that_went_viral_a_few_years_back_when_i_first_saw_it_it_was,
         guess_mints = guess_the_number_of_mints_in_my_hand,
         favourite_font = what_is_your_favourite_font) 

candy_2016_long <- candy_2016_long %>% 
  rename_with( ~ str_replace(., pattern = "please_.*celebrities_", replacement = "separation_"))
 

# reorder to agree more with 2017
candy_2016_long <- candy_2016_long %>%
relocate(dress, day, candy_type, candy_rating, .after = other_comments)

# drop columns which dont appear elsewhere, have little values - i have
# detailed this in the assumptions 
candy_2016_long <- candy_2016_long %>%
  select(-(23:24))

names(candy_2016_long) # looks good

# lets tweak 2017 in line with 2016 above

candy_2017_long <- candy_2017_long %>% 
  rename(id = internal_id) %>% 
  select(-click_coordinates_x_y) %>% # only in this 1 data frame
  mutate(guess_mints = NA, betty_or_veronica = NA, favourite_font = NA,
         separation_jk_rowling = NA, separation_jj_abrams = NA, separation_beyonce = NA, separation_bieber = NA,            separation_kevin_bacon = NA, separation_francis_bacon_1561_1626 = NA) # add in columns that are in other 2

names(candy_2016_long) == names(candy_2017_long) # columns all match!

# OK time for 2015 to match the other two years
candy_2015_long <- candy_2015_long %>% 
  rename(
         id = timestamp,
         age = how_old_are_you,
         going_out = are_you_going_actually_going_trick_or_treating_yourself,
         other_comments = please_leave_any_remarks_or_comments_regarding_your_choices,
         joy_other = please_list_any_items_not_included_above_that_give_you_joy,
         despair_other = please_list_any_items_not_included_above_that_give_you_despair,
         guess_mints = guess_the_number_of_mints_in_my_hand,
         favourite_font = what_is_your_favourite_font,
         day = which_day_do_you_prefer_friday_or_sunday,
         dress = that_dress_that_went_viral_early_this_year_when_i_first_saw_it_it_was)

# rename large column names
candy_2015_long <- candy_2015_long %>% 
  rename_with( ~ str_replace(., pattern = "please_.*celebrities_", replacement = "separation_"))

# reorder to agree more with others
candy_2015_long <- candy_2015_long %>%
  relocate(dress, day, candy_type, candy_rating, .after = other_comments)

# delete columns not in other datasets
candy_2015_long <- candy_2015_long %>%
  select(-if_you_squint_really_hard_the_words_intelligent_design_would_look_like,
         - fill_in_the_blank_imitation_is_a_form_of,
         - sea_salt_flavored_stuff_probably_chocolate_since_this_is_the_it_flavor_of_the_year,
         -check_all_that_apply_i_cried_tears_of_sadness_at_the_end_of)

# add in columns in line with others - these will need to be NA as theres no data
# only alternative would be to lose all data from other tables 
candy_2015_long <- candy_2015_long %>%
  mutate(gender = NA, country = NA, state_province_county_etc = NA)

# final reorder to agree more with others
candy_2015_long <- candy_2015_long %>%
  relocate(going_out, gender, .after = id) %>% 
relocate(country, state_province_county_etc, joy_other, despair_other, 
         other_comments, .after = age)

names(candy_2015_long) == names(candy_2016_long)

# So we now have 3 datasets ready to be bound together
# Then we can look at the columns like country that need cleaned up

candy_2015_long <- candy_2015_long %>%
  mutate(id = as.character(id))
candy_2016_long <- candy_2016_long %>%
  mutate(id = as.character(id))
candy_2017_long <- candy_2017_long %>%
  mutate(id = as.character(id))


## Performance related data cleanse ----------------------------------------

# Going to delete all columns not strictly needed for the tasks
# This is purely for performance as my PC is running so slow

candy_2015_long <- candy_2015_long %>%
select(-(state_province_county_etc:day)) %>%
  select(-(guess_mints:separation_francis_bacon_1561_1626))
candy_2016_long <- candy_2016_long %>%
  select(-(state_province_county_etc:day)) %>%
  select(-(guess_mints:separation_francis_bacon_1561_1626))
candy_2017_long <- candy_2017_long %>%
  select(-(state_province_county_etc:day)) %>%
  select(-(guess_mints:separation_francis_bacon_1561_1626))


# Joining the three tables ------------------------------------------------

# Lets join the 3 sets together
candy_combined <- bind_rows(candy_2015_long, 
                            candy_2016_long, 
                            candy_2017_long, 
                            .id = "year") 
# last line adds a column to let us know original table data is from


# Cleaning the column data ------------------------------------------------

# We have our tables combined! Yay! But wait - they are extremely dirty
# Lets go through column by column and have a look


## Cleaning candy_type column ----------------------------------------------

table(candy_combined["candy_type"])

# OK so there are a few obvious duplicates with slightly different names
# There are some slightly the same but ambiguous - these will be left

candy_combined <- candy_combined %>% 
  mutate(candy_type = recode(candy_type,
  "anonymous_brown_globs_that_come_in_black_and_orange_wrappers_a_k_a_mary_janes" = "mary_janes"),
  candy_type = recode(candy_type,"bonkers_the_candy" = "bonkers"),
  candy_type = recode(candy_type,"boxo_raisins" = "box_o_raisins"),
  candy_type = recode(candy_type,"licorice_yes_black" = "licorice"),
  candy_type = recode(candy_type,"sweetums_a_friend_to_diabetes" = "sweetums"))


## Cleaning country column -------------------------------------------------

# count(candy_combined, country)
# table(candy_combined["country"]) # look at dirty column 'country' eek

# get a few easy ones with regex
candy_combined <- candy_combined %>% 
  mutate(country = if_else(grepl("(?i)usa+", country),"USA",country)) %>% 
  mutate(country = if_else(grepl("(?i)united s+", country),"USA",country)) %>% 
  mutate(country = if_else(grepl("(?i)amer", country),"USA",country)) %>% 
  mutate(country = if_else(grepl("(?i)stat", country),"USA",country)) %>% 
  mutate(country = if_else(grepl("(?i)subscribe+.*", country),NA_character_,country)) 

#make vectors of USA outliers and some to change to NA values
usa_outliers = c("Alaska", "California", "EUA", "Merica", "Murica", "murrika",
                 "New Jersey", "New York", "North Carolina", "Pittsburgh", 
                 "The Yoo Ess of Aaayyyyyy", "Trumpistan", "U S", "u s a", "u.s.",
                 "U.s.", "U.S.", "u.s.a.", "U.S.A.", "UD", "us", "Us", "US", "US of A",
                 "USSA", "'merica")
change_to_NA = c(1, 30.0, 32, 35, 44.0, 45, 45.0, 46, 47.0, 51.0, 54.0)
change_to_NA2 = c("30.0", "44.0", "45.0", "47.0", "51.0", "54.0")
silly_values = c(
  "A tropical island south of the equator", "A", "Atlantis",
  "Canae", "cascadia ", "Cascadia", "Denial", "Earth", "Fear and Loathing", 
  "god's country", "I don't know anymore", "insanity lately", 
  "there isn't one for old men", "soviet canuckistan", "Narnia", "Neverland",
  "one of the best ones", "See above", "Somewhere", 
  "Subscribe To Dm4uz3 On Youtube", "The republic of Cascadia", "this one", 
  "Europe", " Cascadia", "Cascadia ")

# use the vectors above 
candy_combined <- candy_combined %>%
mutate(country = if_else(country %in% usa_outliers ,
                         "USA", country)) 

candy_combined <- candy_combined %>%
  mutate(country = if_else(country %in% silly_values|
                             country %in% change_to_NA|
                             country %in% change_to_NA2, 
                           NA_character_, country)) %>% 
  mutate(country = str_to_title(country)) # change to title case to help

# recode anything else
candy_combined <- candy_combined %>%
mutate(country = recode(country, "The Netherlands" = "Netherlands"),
       country = recode(country, "Can" = "Canada"),
       country = recode(country, "Canada`" = "Canada"),
       country = recode(country, "Endland" = "United Kingdom"),
       country = recode(country, "England" = "United Kingdom"),
       country = recode(country, "England" = "United Kingdom"),
       country = recode(country, "Scotland" = "United Kingdom"),
       country = recode(country, "Espa??a" = "Spain"),
       country = recode(country, "U.k." = "United Kingdom"),
       country = recode(country, "Uk" = "United Kingdom"),
       country = recode(country, "United Kindom" = "United Kingdom"))

table(candy_combined["country"]) # much better!


## Cleaning age column -----------------------------------------------------

# oldest person ever was 122. lets take out everything above that as NA
# lets keep in the 0 values - technically this could be babies in a pram?

# change the column from a character to numeric
candy_combined <- candy_combined %>%
  mutate(age = as.numeric(age))
# clean out values bigger than 122 - oldest ever person
candy_combined <- candy_combined %>%
  mutate(age = ifelse(age>122, NA, age))

table(candy_combined["age"])


## Cleaning year column ----------------------------------------------------

# change the id value brought over from the bind rows to an actual year
# alter the column to be numeric rather than character
candy_combined <- candy_combined %>%
  mutate(year = recode(year, "1" = "2015"),
         year = recode(year, "2" = "2016"),
         year = recode(year, "3" = "2017"),
         year = as.numeric(year))

# ID Column ---------------------------------------------------------------

# Ive retained the ID column as a character column. Its as good a unique id as 
# any and the tables dont agree on it so its fine as is. 

# Write our data to candy_clean.csv ---------------------------------------

candy_combined %>%
write_csv(here("clean_data/candy_clean.csv"))
