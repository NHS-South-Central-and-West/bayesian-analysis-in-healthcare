# script to read and format raw data

# Fingertips Data ----

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
  dplyr::filter(indicator_id %in% c(92488, 90366, 93553)) %>%
  dplyr::filter(area_code != "E92000001") %>%
  dplyr::group_by(indicator_name, area_code, timeperiod_sortable) %>%
  dplyr::summarise(value = mean(value)) %>%
  dplyr::mutate(year = stringr::str_remove_all(timeperiod_sortable, "0000")) %>%
  dplyr::select(indicator_name, area_code, year, value) %>%
  tidyr::pivot_wider(
    names_from = indicator_name,
    values_from = value
  ) %>%
  dplyr::full_join(imd_raw) %>%
  dplyr::rename(
    life_expectancy = `Life expectancy at birth`,
    mortality = `Mortality rate from causes considered preventable (2016 definition)`
  ) %>%
  tidyr::drop_na()

# save fingertips data
readr::write_rds(health_inequalities_df, here::here("data", "health_inequalities.rds"))

# Health Index Data ----

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
readr::write_rds(health_index_df, here::here("data", "health_index.rds"))

