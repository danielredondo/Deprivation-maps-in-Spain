# Carga de librerías
library(rgdal)
library(dplyr)
library(leaflet)
library(stringr)
library(readxl)
library(htmlwidgets)

# Fijamos ruta de trabajo
setwd("RUTA")
#setwd("\\\\10.10.1.202/Compartidas/RegistroCancer/transporte/DanielDavid/DRS/Geocodificación/20190909_CR_2004_2013/cruce_2011/")

# Capa de secciones censales 2011
# Fuente: INE / Cartografía digitalizada http://ine.es/censos2011_datos/cen11_datos_resultados.htm
sc <- readOGR("cartografia_censo2011_nacional/SECC_CPV_E_20111101_01_R_INE.shp",
   encoding = "utf8", use_iconv = TRUE)    #%>%
   #spTransform(CRS("+init=epsg:4326"))

# Añado EDI
edi <- read_xlsx("IP2011_RE.xlsx")
sc@data <- merge(x = edi, y = sc@data, by.x = "CUSEC", by.y = "CUSEC")
summary(sc@data$IP2011)

# Cálculo de quintiles
bins <- quantile(sc@data$IP2011, probs = seq(0, 1, 1/5))

# Colores para la leyenda
paleta <- colorBin("Blues", domain = sc@data$IP2011, bins = bins)

# Sacar colores
paleta(sc@data$IP2011) %>% table

# Zoom Granada provincia
leaflet(sc) %>%
   addTiles() %>%
   setView(lng = -3.20,
           lat =  37.38,
           zoom = 9) %>%
   addPolygons(fillColor = ~paleta(IP2011),
               weight = 1,
               opacity = 1,
               color = "white",
               dashArray = "3",
               fillOpacity = 0.7,
               popup = paste("SECCION CENSAL: ", sc$CUSEC, "<br>NMUN: ", sc$NMUN, "<br>IP: ", round(sc$IP2011, 1)),
               highlightOptions = highlightOptions(color = "#666", weight = 4)) %>%
   addLegend("bottomright", 
             colors = c("#EFF3FF", "#BDD7E7", "#6BAED6", "#3182BD", "#08519C"),
             labels= c("Q1 (Less deprived)", "Q2", "Q3", "Q4", "Q5 (Most deprived)"),
             title= "Deprivation index (SEE, 2011)",
             opacity = 0.7) -> mapa
mapa

# Guardar mapa en HTML:
saveWidget(mapa, file = "mapeo_edi_granada.html", selfcontained = F)
