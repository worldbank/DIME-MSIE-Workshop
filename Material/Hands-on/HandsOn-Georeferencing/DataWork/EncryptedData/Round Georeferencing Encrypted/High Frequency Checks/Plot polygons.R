#------------------------------------------------------------------------------#
#                                                                              #
#                      DIME Field Coordinator Training 2019                    #
#                      Hands-on-Session on Georeferencing                      #                                     
#                                                                              #
#------------------------------------------------------------------------------#

  # PURPOSE:    Create a shapefile with polygons and plot it
  
  # NOTES:      
  
  # WRITTEN BY: Jonas Guthoff [jguthoff@worldbank.org] and
  #             Matteo Ruzzante [mruzzante@worldbank.org]

  # Clear memory
  rm(list=ls())
  
  # List packages used
  packages  <- c("readstata13",
                 "dplyr",
                 "sp", 
                 "rgdal", 
                 "rgeos",
                 "leaflet",
                 "ggplot2",
                 "raster",
                 "geosphere",
                 "osrm",
                 "readstata13",
                 "ggmap",
                 "mapview")
  
  # Install packages that are not yet installed
  sapply(packages, function(x) {
    if (!(x %in% installed.packages())) {
      install.packages(x, dependencies = TRUE) 
    }
  }
  )
  
  # Load all packages -- this is equivalent to using library(package) for each 
  sapply(packages, library, character.only = TRUE)


# PART 1: Root folder --------------------------------------------------

  # Add your username and folder path here (for Windows computers)
  # To find out what your username is, type Sys.getenv("USERNAME")
  if (Sys.getenv("USERNAME") == "WB527265") {
    dropbox  <- "C:/Users/WB527265/Dropbox/Georeferencing"
  }
  if (Sys.getenv("USERNAME") == "ruzza") {
    dropbox  <- "C:/Users/ruzza/Dropbox/Georeferencing"
  }
  
  # For Mac
  system <- Sys.getenv(x = NULL, unset = "")
    user <- system["USER"]
    
  if (is.na(user) == FALSE) {
    if (user == "jonasguthoff") {
        dropbox <- "/Users/jonasguthoff/Dropbox/Georeferencing"
    }
  }
  
# PART 1.1: Project subfolders --------------------------------------------------

  dataWorkFolder   <- file.path(dropbox       , "DataWork")
  encryptFolder    <- file.path(dataWorkFolder, "EncryptedData")
  geo_encrypt      <- file.path(encryptFolder , "Round Georeferencing Encrypted")
  geo_raw_data     <- file.path(geo_encrypt   , "Raw Identified Data")
  geo_hfc			     <- file.path(geo_encrypt   , "High Frequency Checks")
  geo_hfc_data     <- file.path(geo_hfc       , "Data")
  geo_hfc_out      <- file.path(geo_hfc       , "Output")
  
  geo_hfc_map      <- file.path(geo_hfc_out   , "Mapping")


# PART 2: Load survey data --------------------------------------------------
  
  gps    <- read.dta13(file.path(geo_raw_data, "plots_clean.dta"))
  
  data   <- read.dta13(file.path(geo_raw_data, "additional_info.dta"))

    
# PART 3: Prepare inputs ----------------------------------------------------
  
  # Order the observations so the map is not tangled
  gps <- gps[order(gps$plot_ID), ]
  
  # Check class
  class(gps) # should be a data frame

  # Find out which is the first listed ID so we can create the plot object
  first <- unique(gps$plot_ID)[1]
  
  
# PART 4: Create shapefile -------------------------------------------------
  
  # We will create one shapefile for each Plot, then merge them. This is necessary
  # because the functions that create it don't work properly if the different plots
  # have different number of vertices
  for (id in unique(gps$plot_ID)) {
    
    # Keep only the vertices of that plot
    map <- subset(gps, gps$plot_ID == id)[, c("longitude", "latitude")]
    
    # Turn it into a shapefile
    map <- list(Polygon(map))
    map <- list(Polygons(map, id))
    map <- SpatialPolygons(map)
    
    # Save it into the final oject to merge with other plots
    if (id == first) {
      polygons <- map
    } else {
      polygons <- rbind(polygons,map)
    }
    
    # Remove the single plot so we can start it again from scratch
    rm(map)
    
  }
  

# PART 5: Adjust final shapefile ----------------------------------------------
 
  # Eye check
  plot(polygons)
  class(polygons) #must be a spatial polygon
  
  # Ordering the polygons in the shapefile in the same order as they were created
  polygons <- polygons[order(as.numeric(row.names(polygons))),] 
  
  # The data needs to be in the same order as the shapefile to merge properly
  data <- data[order(data$plot_ID), ]
  
  # It also needs to have the same rownames
  rownames(data) <- data$plot_ID
  
  # Merge with the rest of the data
  plots <- SpatialPolygonsDataFrame(polygons, data)
  
  # Calculate the area and convert it to hectares
  plots$area <- areaPolygon(plots) * 0.0001
  
  # Save the SpatialPolygonDataFrame as a data frame
  plot_data <- as.data.frame(plots)
  
  # Save the data in DTA format
  save.dta13(plot_data, file.path(geo_hfc_data,"geo_plots_area.dta"))
  
  # Projection
  proj4string(polygons) <- CRS("+init=epsg:4326")

# PART 7: INTERACTIVE MAPPING ----------------------------------------------
  
  # Round area to decimals 
  plots$area <- round(plots$area, 2)
  
  # Produce Leaflet map
  leaflet() %>%
    addTiles() %>%
    addProviderTiles(providers$Esri.WorldImagery) %>%
    addPolygons(data=polygons,
                group = "team",
                color = "red",
    popup = paste0("Team: ",
                   plots$team,
                   "<br>",
                   "Plot description: ",
                   plots$plot_desc,
                   "<br>",
                   "Area: ",
                   plots$area,
                   " ha"))
     
# PART 8: STATIC MAPPING ----------------------------------------------
  
  # Add your API key here:
  # if you don't have it, please visit https://developers.google.com/maps/documentation/javascript/get-api-key
  googleKey <- ""
 
  # Register Google API 
  register_google(key = googleKey, write = TRUE)
  
  # bounding_box <- bbox(plots[plots@data$com == com, ])
  # centroid     <- c(mean(bounding_box[1,]), mean(bounding_box[2,]))
  
  # We use the centroid as the bounding box does not seem to work with Google API
  # mapZoom <- mean(kitPlots_spdf@data$zoom[kitPlots_spdf@data$com == com])
  
  # Create folder if it does not exist yet
  dir.create(geo_hfc_map, showWarnings = FALSE)
  
  # Save maps by team
  for (team in unique(plots@data$team)) {
    
    # Save team name in string
    team_name    <- plots@data$team[plots@data$team == team]
    
    bounding_box <- bbox(plots[plots@data$hhid == team, ])
    centroid     <- c(mean(bounding_box[1,]), mean(bounding_box[2,]))
    
    # Retrieve base map
    DC_basemap   <- get_map(location = centroid,
                            zoom     = 17,
                            source   = "google",
                            maptype  = "satellite")
    
    # Generate map object
    map <- ggmap(DC_basemap) +
      
           # Plot polygon
           geom_polygon(data = plots[plots@data$team == team, ],
                        aes(long, lat, group = group),
                        fill = "orange", colour = "red", alpha = 0.2) +
                        
           # Remove axis title, text, and ticks
           theme(axis.title.x = element_blank(),
                 axis.text.x  = element_blank(),
                 axis.ticks.x = element_blank(),
                 axis.title.y = element_blank(),
                 axis.text.y  = element_blank(),
                 axis.ticks.y = element_blank(),
                 plot.title   = element_text(hjust = .5,
                                             vjust = .5,
                                             face = "bold"),
                 legend.position = "none" ) +
      
           labs(title = paste0("Team: ", team_name))
                        
    # Save map in PDF
    pdf(file.path(geo_hfc_map, file = paste0(team, ".pdf")))
    print(map)
    dev.off()
  
  }
  
  