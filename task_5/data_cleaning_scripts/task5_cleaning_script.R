a
# secondly we have 4 pivto longers to do

rwa <- rwa %>% 
  pivot_longer(cols = c(Q1:Q22,E1:E22,TIPI1:TIPI10,VCLI1-VCLI16)   names_to = "q_question", values_to = "q_answer") %>% 
  pivot_longer(cols = E1:E22,  names_to = "e_timed_question", values_to = "e_time_to_answer")
  