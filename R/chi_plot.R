
chi_breaks <-  c(-1, 0.1, 0.2, 0.4, 0.6, 0.8, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4.0, 5, 100)
chi_cols <- c("#9E0142", "#B91F48", "#D53E4F", "#F46D43", "#FDAE61", "#FEE08B", "#FFFFBF", "#EFF9FF", "#BDE4FC", "#3288BD")
chi_cols = rev(colorRampPalette(chi_cols)(length(chi_breaks)-1)) 
chi_legend_labels <- c(0, 0.2, 0.6, 1, 1.5, 2, 3, 4.0, ">5")
chi_label_sequence <- c(1, 3,  5,   7, 9,  11, 13, 15, 17)


legend.shrink <- 0.7
legend.width <- 0.7

chi_plot <- function(raster_data, title, title_legend=NULL, title_size = 1, 
                     color_breaks=chi_breaks, cols=chi_cols,
                     legend_break_labels=chi_legend_labels, 
                     label_sequence = chi_label_sequence, 
                     legend=TRUE, condensed=FALSE){
  if(condensed){
    par(mar=c(0,0,1.3,0)) # bottom, left, top, and right
  } else{
    par(mar=c(4,4,4,4)) # bottom, left, top, and right
  }
  
  par(oma=c(0,0,0,0))
  plot(raster_data, col=cols, axes=TRUE, box=FALSE, breaks=color_breaks, legend=FALSE)
  title(title, line=0, cex.main =title_size)
  
  if(legend){
    # add axis with fields package function:
    break_locations <- seq(0, length(color_breaks), length.out=length(color_breaks)) # breaks for colors for legend
    legend_label_locations <- break_locations[label_sequence] # label locations (every other color labeled)
    
    fields::image.plot(raster_data, #zlim = c(min(myBreaks), max(myBreaks)), 
                       legend.only = TRUE, 
                       legend.shrink=legend.shrink,
                       legend.width=legend.width,
                       col = cols,
                       #legend.lab=title_legend,
                       breaks=break_locations,
                       axis.args=list(cex.axis=0.6, at=legend_label_locations, labels=legend_break_labels))
  }
  ext_rast <- extent(raster_data)
  #map("world", add = TRUE, xlim = c(ext_rast[1],ext_rast[2]), ylim = c(ext_rast[3],ext_rast[4]), col="gray90", fill = TRUE)
}