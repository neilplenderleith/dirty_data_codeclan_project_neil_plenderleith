library(tidyverse)
library(readr)
library(here)
library(stringr)

rwa <- read_csv("raw_data/rwa.csv")

# firstly lets put an id column in to keep track
rwa <- rwa %>% 
rowid_to_column(var = "Id")


# Lets alter the reverse scoring
reverse_scores <- c("Q4", "Q6", "Q8", "Q9", "Q11", "Q13", "Q15", "Q18", "Q20", "Q21")

rwa <- rwa %>% 
mutate(across(all_of(reverse_scores), ~ case_when(
  . == 1 ~ 9,
  . == 2 ~ 8,
  . == 3 ~ 7,
  . == 4 ~ 6,
  . == 5 ~ 5,
  . == 6 ~ 4,
  . == 7 ~ 3,
  . == 8 ~ 2,
  . == 9 ~ 1
)))
  
# secondly we have 4 pivot longers to do
rwa2 <- rwa %>% 
  pivot_longer(cols = c(Q1:Q22,E1:E22,TIPI1:TIPI10,VCL1:VCL16), names_to = "question",values_to = "answer")  
# add on rwa score - could i have made this any more diffcult on myself?
rwa2 <- rwa2 %>% 
  filter((!question %in% c("Q1", "Q2")) & (!str_starts(question, "E")) &
                                          (!str_starts(question, "T")) &
                                          (!str_starts(question, "V"))) %>%
  select(Id, question, answer) %>% 
  group_by(Id) %>% 
  summarise(rwa_score = mean(answer)) %>% 
  right_join(rwa2, "Id")


rwa2 %>% 
sum(is.na(gender))







rwa2 %>% 
write_csv("clean_data/task5_clean.csv")
