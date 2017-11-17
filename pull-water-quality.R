#------------------------------------------------------------------------------#
## This is an R script to retrieve water quality data from both the USGS and EPA 
## for a specified geography, using the dataRetrieval package. Documentation and 
## vignettes for this package are on CRAN:
## https://cran.r-project.org/package=dataRetrieval.
##
## USGS and EPA water quality data are obtained from the Water Quality Portal
## at https://www.waterqualitydata.us.
##
## Author: Neil Miller <nmiller@chapinhall.org>

#------------------------------------------------------------------------------#
### Set up workspace -----------------------------------------------------------
#------------------------------------------------------------------------------#
rm(list=ls())
library(dataRetrieval, logical.return = TRUE)
try(setwd(dir = "H:/ECHO Project/data/Environmental/Water"),
    silent = TRUE)

#------------------------------------------------------------------------------#
### Defining our pull ----------------------------------------------------------
#------------------------------------------------------------------------------#
startDate <- Sys.Date() - (5 * 365)
endDate <- Sys.Date()
pullCharacteristics <- c(specifc.conductance = "specific conductance")
  # More research needed on which characteristcs are of interest, and are widely measured. 
  # ph = "pH", chloride = "Chloride" are possibilities. 

pullCounties <- list(bos = "US:25:025",
                     chi = "US:17:031",
                     sd = "US:06:075",
                     tb = "US:12:057")
    # This is Suffolk County, MA; Cook County, IL;
    # San Diego County, CA; and Hillsborough County, FL.
    # pullStates <- c("US:06", "US:13", "US:17", "US:25") is an alternative,
    # pulling California, Florida, Illinois, Massachusetts.

#------------------------------------------------------------------------------#
### Obtaining site info --------------------------------------------------------
#------------------------------------------------------------------------------#
for (char in pullCharacteristics){
  sites = NULL
  # Sites in each geography that take this meaurement
  for (county in pullCounties){
  print(paste0("...pulling list of sites that measure ", char, " in ", county, "..."))
  sitesFull <-
    whatWQPsites(countycode = county,
                 characteristicName = char)
  #The function whatWQPdata may be better
  sites <- rbind(sites,
                   with(data = sitesFull, cbind.data.frame(OrganizationIdentifier, OrganizationFormalName, MonitoringLocationIdentifier,
                                                         MonitoringLocationName, MonitoringLocationTypeName, MonitoringLocationDescriptionText,
                                                         LatitudeMeasure, LongitudeMeasure, StateCode, CountyCode)))
      # The documentation for this function lists the 36 columns returned; these 9
      # are the most relevant, I believe. Of the chosen columns, latitude and longitude
      # are numeric, and the rest are character strings.
  }
    print(paste0("There are ", nrow(sites), " sites that measure ", char, " in your geography."))
    write.csv(sites, file = paste0("sites-", char, ".csv"),
          row.names = FALSE)
}
#------------------------------------------------------------------------------#
### Pulling measurements for each characteristic of interest -------------------
#------------------------------------------------------------------------------#

for (char in pullCharacteristics){
  results = NULL
  for (county in pullCounties){
    print(paste0("...pulling measurements of ", char, " in ", county, "..."))
  resultsFull <- readWQPdata(countycode = county,
                             characteristicName = char,
                             startDateLo = startDate,
                             startDateHi = endDate)
  print(paste0("...There are ", nrow(resultsFull), " measurements of ", char, " in ", county))
  results <- rbind(results, with(data = resultsFull, cbind.data.frame(OrganizationIdentifier, OrganizationFormalName, MonitoringLocationIdentifier,
                                                                      ActivityStartDate, ActivityEndDate, CharacteristicName, ResultMeasureValue,
                                                                      ResultMeasure.MeasureUnitCode, ResultStatusIdentifier, PrecisionValue,
                                                                      ResultCommentText)))
          }
  print(paste0("There are ", nrow(results), " measurements of ", char, " in your geography."))
  write.csv(sites, file = paste0("results-", char, ".csv"),
            row.names = FALSE)
}
