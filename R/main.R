## Verander alleen de regel hieronder naar de juiste map en alles zou moeten werken!

setwd('/home/jelle/Repositories/bruinvis/project_folder/R')

source('requirements.R')
source('chi_plot.R')

csvfile = "../data/MarineRegions.csv"

# if not present in data folder, download input file from https://knb.ecoinformatics.org/view/doi:10.5063/F12B8WBS 
destfile = '../data/cumulative_impact_2008.tif'
cropped_file = '../data/cumulative_impact_2008_cropped.tif'

# target coordinate reference system
c1 = CRS("+proj=longlat +datum=WGS84 +no_defs")

# if necessary, download file
if(!file.exists(cropped_file) & !file.exists(destfile)){
  download.file('https://knb.ecoinformatics.org/knb/d1/mn/v2/object/urn%3Auuid%3Afc3c0795-5d04-40b9-9362-ae397e4a8b2b', destfile)
}

# if necessary, crop and reproject file
if(!file.exists(cropped_file)){
  r1 <- raster(destfile)
  plot(r1)
  
  # optional step 1b reduce the size of the map in order to speed up the transformation in step 3
  r2 <- crop(r1, extent(-18000000,6000000,2000000, 9020067))
  
  # step 3: transform raster object to match the coordinate reference system of the polygon
  if (print(CRSargs(crs(r2))) != print(CRSargs(crs(c1)))){
    rx <- raster::projectRaster(from=r2, crs=crs(c1),method="ngb")
  }
  writeRaster(rx, cropped_file)
  rm(rx, r1, r2)
}

# load processed raster file
r1 <- raster(cropped_file)

# step 2: create tables of marine regions for manual selecting regions
#iho_table <- mr_names('MarineRegions:iho')
#eez_table <- mr_names('MarineRegions:eez')

## Create maps
d2 <- read.csv(csvfile, sep=";")
CI_mean=c(); CI_median=c(); CI_min=c(); CI_max=c()
CI_mean[1] = 0; CI_median[1] = 0; CI_min[1] = 0; CI_max[1] = 0

for (i in unique(d2$ID)) {
  r_names <- paste("r", 1:(sum(d2$ID == i)), sep = "")
  r_list <- as.list(1:(sum(d2$ID == i)))
  names(r_list) <- r_names
  regions = lapply(r_list, function(x)
    mr_gazetteer_feature_get(d2[d2$ID == i,]$mrgid[x]))
  region = regions[[1]]
  if (length(region$id) > 1){
    region <- st_union(region)
  }
  if (sum(d2$ID == i) > 1){
    for (j in 2:sum(d2$ID == i)){
      if(i == 1 & j == 2){
        region = st_union(region, regions[[j]])
        x_coords <- c(-13.0,-3.0,-3.0,-13.0, -13.0)
        y_coords <- c(50.0,50.0,46.0,46.0, 50.0)
        pol = st_sfc(st_polygon(list(cbind(x_coords,y_coords))))
        h = st_sf(r = 5, pol)
        st_crs(h) <- c1
        region <- st_difference(region, h)
      }else if(i == 7 & j == 3){
        region = st_union(region, regions[[j]])
        x_coords <- c(-8.034351,8.40,8.40,-8.034351, -8.034351)
        y_coords <- c(55.811086,55.811086,63.0,63.0, 55.811086)
        pol = st_sfc(st_polygon(list(cbind(x_coords,y_coords))))
        h = st_sf(r = 5, pol)
        st_crs(h) <- c1
        region <- st_difference(region, h)
      }else if(i == 15 & j == 2){
        region = st_union(region, regions[[j]])
        x_coords <- c(-8.034351,-5.0,-3.0,8.40,8.40,-8.034351, -8.034351)
        y_coords <- c(56.0,54.8,55.811086,55.811086,50.0,50.0, 56.0)
        pol = st_sfc(st_polygon(list(cbind(x_coords,y_coords))))
        h = st_sf(r = 5, pol)
        st_crs(h) <- c1
        region <- st_difference(region, h)
      }else if(i == 15 & j == 8){
        region = st_union(region, regions[[j]])
        x_coords <- c(-2.0,-6.26,-7.18,-9.29, -10.63, -17.13, -3.42, -0.88, -2.0)
        y_coords <- c(61.0,58.52,57.52,47.04, 47.04, 60.02, 62.57, 61.0, 61.0)
        pol = st_sfc(st_polygon(list(cbind(x_coords,y_coords))))
        h = st_sf(r = 5, pol)
        st_crs(h) <- c1
        region <- st_difference(region, h)
        
      }else if (d2$include[d2$ID == i][j] == "include"){
        region = st_union(region, regions[[j]])
      } else if (d2$X[d2$ID == i][j] == "exclude"){
        region <- st_difference(region, regions[[j]])
      } else {
        "Warning! Include/Exclude field not filled properly"
      }
    }
  }
  map1 <-raster::crop(r1, extent(region)+5)
  
  figname = paste0("../output/",d2[d2$ID == i,]$Study_area[1],".png", sep = "")
  png(filename = figname)
  chi_plot(raster_data=map1,  title="", 
           cols=chi_cols, color_breaks = chi_breaks,
           legend_break_labels = chi_legend_labels,
           label_sequence = chi_label_sequence)
  
  plot(st_geometry(region), add=TRUE, border="green", lwd=2)
  dev.off()
  mr <- raster::extract(x = map1, 
                        y = region, 
                        df=TRUE)
  
  CI_mean[i] <- mean(mr[,2],na.rm=TRUE)
  CI_median[i] <- median(mr[,2],na.rm=TRUE)
  CI_min[i] <- min(mr[,2],na.rm=TRUE)
  CI_max[i] <- max(mr[,2],na.rm=TRUE)
}

df <- data.frame(cbind(unique(d2$Study_area),CI_mean,CI_median,CI_min,CI_max))
write.csv(df, "../output/results.csv")
