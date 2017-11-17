#------------------------------------------------------------------------------#
## This is an R script to explore how much data is available for specific 
## water characteristics for a specified geography, using the dataRetrieval 
## package. Documentation and vignettes for this package are on CRAN:
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
### What are you looking for? --------------------------------------------------
#------------------------------------------------------------------------------#
startDate <- Sys.Date() - (5 * 365)
endDate <- Sys.Date()
pullCharacteristics <- c(copper = "Copper", fluoride = "Flouride", mercury = "Mercury")
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
### Make the request -----------------------------------------------------------
#------------------------------------------------------------------------------#

for (char in pullCharacteristics){
  allObservations = NULL
  for (county in pullCounties){
    print(paste0("...exploring how many observations of ", char, " were taken in ", county, "..."))
    locationObservations <- whatWQPdata(countycode = county,
                               characteristicName = char,
                               startDateLo = startDate,
                               startDateHi = endDate)
    print(paste0("...There are ", sum(locationObservations$resultCount), " measurements of ", char, " at ", nrow(locationObservations), " sites in ", county))
    allObservations <- rbind.data.frame(allObservations, as.data.frame(with(data = locationObservations, cbind(OrganizationIdentifier, coordinates, OrganizationFormalName, MonitoringLocationIdentifier,
                                                                        MonitoringLocationName, MonitoringLocationTypeName,
                                                                        ResolvedMonitoringLocationTypeName, activityCount, resultCount
                                                                        ))))
    ## If we use cbind.data.frame, there's an error "arguments imply differing number of rows." Perhaps because the identifier used by this function isn't unique (e.g., OrganizationIdentifier)
  }
  print(paste0("There are ", sum(unlist(allObservations$resultCount)), " measurements of ", char, " at ", nrow(allObservations), " sites in your geography."))
}