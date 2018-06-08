library(maps)
library(maptools)
library(mapproj)
library(sf)

robinson = CRS(" +proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
latlon = CRS("+init=epsg:4326")

pts=SpatialPoints(rbind(c(-180,-90),c(-180,90),c(180,90),c(180,-90)), CRS("+init=epsg:4326"))
gl = gridlines(pts, easts = seq(-180,180,180), norths = seq(-90,90,90), ndiscr = 100)
gl.robinson = spTransform(gl, robinson)

data("wrld_simpl")
wrld_transf = spTransform(wrld_simpl, robinson)

# create a map of surface pressure availability
df <- read.table("data/surface_pressure_availibility/surface_pressure.csv",
                 sep =",",
                 header = TRUE,
                 stringsAsFactors = FALSE)

year = max(df$end)

# read pressure station data
ps = read.table("data/surface_pressure_availibility/ispd_history_v4.00_pressure_stations.csv",
                sep = "|", 
                header = TRUE,
                stringsAsFactors = FALSE)

start_year = as.numeric(substr(ps$Start.time,1,4))
end_year = as.numeric(substr(ps$End.time,1,4))

loc = which(start_year < year & end_year >= year)

# convert from modelling to standard coordinates
ps$Long = ifelse(ps$Long > 180, -180 + (ps$Long - 180), ps$Long)

# pressure stations
ps_points = SpatialPoints(coords = cbind(ps$Long[loc],ps$Lat[loc]),
                          proj4string = latlon)
ps_points = spTransform(ps_points, robinson)

df_points = SpatialPoints(coords = cbind(df$lon,df$lat),
                          proj4string = latlon)
df_points = spTransform(df_points, robinson)

# load data
data("wrld_simpl")

# create grid lines
pts=SpatialPoints(rbind(c(-180,-90),
                        c(-180,90),
                        c(180,90),
                        c(180,-90)),
                  CRS("+init=epsg:4326"))
gl = gridlines(pts, easts = seq(-180,180,180), norths = seq(-90,90,90), ndiscr = 100)
bb = gridlines(pts, easts = seq(-180,180,360), norths = seq(-90,90,180), ndiscr = 100)

# reproject grid lines and bounding box
gl_robinson = spTransform(gl, robinson)
bb_robinson = spTransform(bb, robinson)

# transform the wold map and data
wrld_robinson = spTransform(wrld_simpl, robinson)

pdf("output/ispd_surface_pressure_map.pdf", 9,7)
par(mar=c(3,0,3,0))
plot(wrld_robinson,
     border = "grey25",
     main = "" )

points(ps_points, pch=19,col='red', cex = 0.3)

points(df_points,
       pch=19,
       col='blue',
       cex = 0.8)

legend("topright",
       legend = c("COBECORE","ISPD"),
       col = c("blue","red"),
       pch = 19, bty = "n")

#lines(gl_robinson, col = "grey25")
lines(bb_robinson, lwd = 2)

mtext(text = sprintf("%s : Total # stations = %s",year, length(loc) + nrow(ps)),
      line = 1,
      side = 3,
      cex = 1.5)
dev.off()