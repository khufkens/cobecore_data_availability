# load libraries
require('raster')
require('maptools')
require('rgdal')
require('rgeos')

# create a map of surface pressure availability
df <- read.table("data/surface_pressure_availibility/surface_pressure.csv",
                 sep =",",
                 header = TRUE)

# calculate number of years
df$site_years <- df$nr_of_scans / 12

# load provinces
provinces = readOGR("data/gis/provinces/", "RDC_provinces")
#provinces_no_katanga = provinces[provinces@data$PROVINCE != "Katanga",]
#katanga = provinces[provinces@data$PROVINCE == "Katanga",]
DRC = gUnaryUnion(provinces)

# read the river data
river = readOGR("data/gis/river/",
                "RDC_hydro_surface")
river = spTransform(river,
                    CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
                    )
# drop NA values in shp file
river = river[!is.na(river@data$DESCRIPTIO),]

# drop all lakes in the shp file
river = river[river@data$DESCRIPTIO != "Lac",]

# load landsat data
img = 'data/gis/raster/world.topo.bathy.200406.3x21600x10800.jpg'
r = brick(img)
projection(r) = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
extent(r) = extent(-180, 180,-90, 90)

# set extent
e <- extent(11.400134, 32.306382,-14.302275, 7.105700)
r = crop(r,e)

# mean image (grey)
dull = mean(r)

# split channels
b = r$world.topo.bathy.200406.3x21600x10800.3
g = r$world.topo.bathy.200406.3x21600x10800.2
r = r$world.topo.bathy.200406.3x21600x10800.1

maskloc = mask(r,DRC,updatevalue=NA)

b[is.na(maskloc)] = (b[is.na(maskloc)] + 30)
g[is.na(maskloc)] = (g[is.na(maskloc)] + 40)
r[is.na(maskloc)] = (r[is.na(maskloc)] + 45)

b[b<0] = 0
g[g<0] = 0
r[r<0] = 0

# CLEAR GRAPHICS
try(dev.off())

pdf('output/Figure_surface_pressure_sites.pdf',10,9.62)

text.axis = 1.3
text.ticks = 2
text.labels = 1.5
col.axis = "grey"
col.text = "white"

par(
  oma = c(5, 6.5, 5, 6.5),
  bg = "white",
  fg = "white",
  col.axis = "grey",
  col.lab = "grey",
  col.main = "grey",
  col.sub = "grey",
  col = "grey"
  #family = "Times New Roman"
)

# plot map
plotRGB(stack(r,g,b), ext = e, axes = F)

# plot river
plot(river,add=TRUE,col='lightblue',lty=0)

# add DRC outline
plot(DRC,add=TRUE,fg='white')

# add grid 
grid(col = col.axis, lwd = 0.5)

# Surface pressure stations
points(df$lon,
       df$lat,
       pch = 6,
       lwd = 2,
       cex = log(df$site_years),
       col = 'yellow')

# kisangani marker
points(25.194944,
       0.509854,
       pch = 15,
       col = 'white')

text(25.704944,
     0.509854,
     "Kisangani",
     pos = 4,
     col = 'White',
     cex = 1.3)

segments(25.794944,
        0.509854,
        25.194944,
        0.509854)

# kinshasa marker
points(15.317664,
       -4.431888,
       pch = 15,
       col = 'white')

text(16.217664,
     -4.331888,
     "Kinshasa",
     pos = 4,
     col = 'White',
     cex = 1.3)

 segments(
   15.317664,
   -4.431888,
   16.317664,
   -4.431888
  )

# scalebar
scalebar(
  500,
  xy = c(12,-13.5),
  type = 'bar',
  divs = 2,
  col = col.text,
  adj = c(0, -1.2),
  cex = 1.3,
  below = 'km'
)

# plot axis and axis labels
axis(
  1,
  col = col.axis,
  col.ticks = col.axis,
  cex = text.ticks,
  cex.axis = 1.3,
  tck = -0.01,
  lwd = 2
)
axis(
  2,
  col = col.axis,
  col.ticks = col.axis,
  cex = text.ticks,
  cex.axis = 1.3,
  tck = -0.01,
  lwd = 2
)

mtext(expression(paste("Longitude (", degree, ")")), 1, 3, cex = text.axis)
mtext(expression(paste("Latitude (", degree, ")")), 2, 3, cex = text.axis)

# add a fat box around the map
box(lwd = 2)

# close device
dev.off()