library(tidyverse)

# remove continents data

deaths_data <- subset(deaths_data, continent!="0")
vaccinations_data <- subset(vaccinations_data, continent!=" ")

# number of counties 

length(unique(deaths_data$location))

data <- deaths_data %>%
   left_join(vaccinactions_data, by=c("location", "date"))


country_total_cases <- deaths_data %>% group_by(location) %>%
  summarize(total_cases = max(total_cases, na.rm =TRUE))

country_total_tests <- vaccinactions_data %>% group_by(location) %>%
  summarize(total_tests = max(total_tests, na.rm =TRUE))



case_per_test <- country_total_cases %>%
  left_join(country_total_tests, by="location") %>%
  summarize(location = location, case_per_test = total_cases/total_tests)


case_per_test %>% filter(case_per_test >= 0.05)




