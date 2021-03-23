# mregions-chi

This R code enriches marine regions polygons with CHI raster data from https://knb.ecoinformatics.org

The input table needed to run the code is a csv file containing at least the following columns:

| ID | Study\_area | mrgid | include |
| ---- | ---- | ---- | ---- |
| 1 | Kattegat Skagerrak Seas | 2374 | include |
| 1 | Kattegat Skagerrak Seas | 2379 | include |
| 2 | German North Sea | 5669 | include |
| 2 | German North Sea | 2401 | exclude |

The purpose of the include column is to decide whether to add or subtract a polygon to/from the first defined polygon. In the above example for ID = 1 the polygon in the second row is merged with the polygon in the first row. For ID = 2 the polygon in the fourth row is subtracted from the polygon in the third row.

## Configuration steps

- Change working directory in main script
- Change input file path if necessary
- Change cropping parameters (line 28) if marine regions lie outside these coordinates

## Code description
- A CHI map is downloaded if it does not exist in the data folder.
- The map is cropped and saved to speed up subsequent steps.
- Marine regions polygons of interest are downloaded as spatial features using the [marineregions.org REST service](https://www.marineregions.org/gazetteer.php?p=webservices)
- CHI values lying within the polygon are extracted from the CHI map using the raster package.

## Output
CHI maps with outline of the polygon.  
results.csv file containing the mean, median, min and max CHI in the polygon

![ID = 1](https://github.com/UtrechtUniversity/mregions-chi/blob/master/images/Kattegat-Skagerrak-Seas.png?raw=true)
