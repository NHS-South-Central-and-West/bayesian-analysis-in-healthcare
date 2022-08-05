# script to read and format raw data

# Setup ----

library(dplyr)

# Raw Data ----

## PHE Fingertips ----

# pull wider determinants raw data from fingertips
wider_determinants_raw <- 
  fingertipsR::fingertips_data(
    ProfileID = 130,
    # using pre 4/19 upper tier local authorities to match health index
    AreaTypeID = 102
  ) %>%
  janitor::clean_names()

# pull imd scores and deciles from fingertips
imd_raw <- 
  fingertipsR::deprivation_decile(
    AreaTypeID = 102
    ) %>%
  janitor::clean_names(abbreviations = c("IMD"))

# filter for the indicators of interest and wrangle data into tidy structure
health_inequalities_df <-
  wider_determinants_raw %>%
  filter(indicator_id %in% c(92488, 90366, 93553)) %>%
  filter(area_code != "E92000001") %>%
  group_by(indicator_name, area_code, timeperiod_sortable) %>%
  summarise(value = mean(value)) %>%
  mutate(year = stringr::str_remove_all(timeperiod_sortable, "0000")) %>%
  select(indicator_name, area_code, year, value) %>%
  tidyr::pivot_wider(
    names_from = indicator_name,
    values_from = value
  ) %>%
  full_join(imd_raw) %>%
  rename(
    life_expectancy = `Life expectancy at birth`,
    mortality = `Mortality rate from causes considered preventable (2016 definition)`
  ) %>%
  tidyr::drop_na()

# save fingertips data
readr::write_rds(
  health_inequalities_df,
  here::here(
    "data", "raw", "health_inequalities.rds"
    )
  )

## ONS Health Index ----

# import health index data 
health_index_df <- 
  openxlsx::read.xlsx(
    "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/healthandsocialcare/healthandwellbeing/datasets/healthindexengland/2015to2018/hibetadatatablesv2.xlsx",
    sheet = 8,
    rows = c(8:50252),
    colNames = TRUE
    ) %>%
  janitor::clean_names()

# save health index data
readr::write_rds(
  health_index_df,
  here::here(
    "data", "raw", "health_index.rds"
    )
  )

# Merge & Wrangle Deprivation Dataset ----

# filter for relevant risk factors and pivot
risk_factors <-
  health_index_df %>%
  filter(
    geography_type == "Upper Tier Local Authority" &
      indicator_grouping_name %in% c(
        "Physiological risk factors",
        "Behavioural risk factors"
      )
  ) %>%
  select(area_code, year, indicator_grouping_name, index_value) %>%
  tidyr::pivot_wider(
    names_from = indicator_grouping_name,
    values_from = index_value
  ) %>%
  janitor::clean_names()

# join risk factors to fingertips data for relevant date range
deprivation_df <- health_inequalities_df %>%
  filter(year %in% (2015:2018)) %>%
  mutate(year = as.double(year)) %>%
  inner_join(risk_factors)

# save deprivation data
readr::write_rds(
  deprivation_df,
  here::here(
    "data", "deprivation.rds"
    )
  )
