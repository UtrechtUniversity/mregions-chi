mr_gazetteer_feature_get <- function(mrid) {
  wmsinfo <- httr::content(httr::GET(paste0("http://www.marineregions.org/rest/getGazetteerWMSes.json/", mrid, "/")))
  if(length(wmsinfo) == 0) {
    print(paste(mrid, "No wms found", wmsinfo))
    return(list())
  }
  features <- list()
  for(wms in wmsinfo) {
    if(grepl("wms[?]$", wms$url) || grepl("gis[.]ngdc[.]noaa[.]gov", wms$url)) {
      if(grepl("gis[.]ngdc[.]noaa[.]gov", wms$url)) {
        wfs_url <- sub("/arcgis/services/", "/arcgis/rest/services/web_mercator/", wms$url)
        wfs_url <- sub("/MapServer/WmsServer[?]$", "/MapServer/3/query?f=geojson&where=", wfs_url)
        wfs_url <- paste0(wfs_url, wms$featureName,'%3D', wms$value)
      } else {
        wfs_url <- paste0(sub("wms[?]$", "wfs?", wms$url), "request=getfeature&version=1.1.0&service=wfs",
                          "&typename=", wms$namespace, ':', wms$featureType,
                          '&CQL_FILTER=', tolower(wms$featureName), "='", wms$value, "'",
                          "&outputFormat=application/json")
      }
      wfs_url <- URLencode(wfs_url)
      ft <- fetch_feature(wfs_url)
      if(!is.null(ft)) {
        features[[length(features)+1]] <- ft
      }
    } else if (grepl("geogratis[.]gc[.]ca/services/geoname/en/geonames", wms$url)) {
      kml_url <- paste0(wms$url, wms$value, '.kml')
      ft <- fetch_feature(kml_url)
      if(!is.null(ft)) {
        features[[length(features)+1]] <- ft
      }
    } else {
      print(paste(mrid, "Url is no WMS", wms$url))
    }
  }
  features <- do.call(rbind, features)
  features
}