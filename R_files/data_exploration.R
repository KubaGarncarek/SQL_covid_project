library(tidyverse)
library(lubridate)

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



vaccinations_data %>% group_by(date) %>%
  summarize(vac = sum(new_vaccinations)) %>%
  ggplot(aes(date, vac))+
  geom_point()

# percent people vaccinated

vac_percent <- vaccinations_data %>% group_by(location) %>%
  summarize(vac = sum(new_vaccinations), population=population[1])

sum(vac_percent$vac)/sum(vac_percent$population)

# percent vaccinated people in last 6 months

vac_percent <- vaccinations_data %>%
  filter(today() - vaccinations_data$date <360) %>%
  group_by(location) %>%
  summarize(vac = sum(new_vaccinations), population=population[1])

sum(vac_percent$vac)/sum(vac_percent$population)


# max stringency in country

vaccinations_data %>%
  group_by(location) %>% filter(stringency_index >0) %>%
  summarize(str = max(stringency_index))


# mean stringency in country

vaccinations_data %>%
  group_by(location) %>%
  summarize(str = mean(stringency_index, na.rm=TRUE)) %>% print(n=200)

# population density

dens <- vaccinations_data %>% group_by(location) %>%
  summarize(dens = population_density[1])

plot(dens$dens)


# percent of older people

sixty_five <- vaccinations_data %>% group_by(location) %>%
  summarize(sixty_five = aged_65_older[1])

sixty_five %>% 
  ggplot(aes(sixty_five))+
  geom_histogram()

seventy <- vaccinations_data %>% group_by(location) %>%
  summarize(seventy = aged_70_older[1])

seventy %>% 
  ggplot(aes(seventy))+
  geom_histogram()

# gdp

gdp <- vaccinations_data %>% group_by(location) %>%
  summarize(gdp = gdp_per_capita[1])

gdp %>%
  ggplot(aes(gdp)) +
  geom_histogram()


# cardiovascular death rate

cardiovascular_death_rate <- vaccinations_data %>% group_by(location) %>% 
  summarize(card = cardiovasc_death_rate[1])

cardiovascular_death_rate %>%
  ggplot(aes(card)) +
  geom_histogram()


# diabetes rate

diabetes <- vaccinations_data %>% group_by(location) %>%
  summarize(diabetes = diabetes_prevalence[1])

diabetes %>%
  ggplot(aes(diabetes))+
  geom_histogram()


# life expectancy 

life_expectancy <- vaccinations_data %>% group_by(location) %>%
  summarize(exp = life_expectancy[1])

life_expectancy %>%
  ggplot(aes(exp)) +
  geom_histogram()




