# Carga de librerías
library(rgdal)
library(dplyr)
library(leaflet)
library(readxl)
library(htmlwidgets)

# Se fija la ruta de trabajo
setwd("RUTA")

# Capa de secciones censales 2011
# Fuente: INE / Cartografía digitalizada http://ine.es/censos2011_datos/cen11_datos_resultados.htm
sc <- readOGR("cartografia_censo2011_nacional/SECC_CPV_E_20111101_01_R_INE.shp",
   encoding = "utf8", use_iconv = TRUE) %>%
   spTransform(CRS("+init=epsg:4326"))

# Índice de Privación 2011
# Fuente: SEE, Grupo de Trabajo sobre determinantes sociales de la salud
# https://www.seepidemiologia.es/gruposdetrabajo.php?contenido=gruposdetrabajosub6
ip <- read_xlsx("IP2011_RE.xlsx")
sc@data <- merge(x = ip, y = sc@data, by.x = "CUSEC", by.y = "CUSEC")

# Cálculo de quintiles
bins <- quantile(sc@data$IP2011, probs = seq(0, 1, 1/5))

# Colores para la leyenda
paleta <- colorBin("Blues", domain = sc@data$IP2011, bins = bins)

# Mapa interactivo
leaflet(sc) %>%
   setView(lng = -3.692125,
           lat =  40.41896944, 
           zoom = 6) %>%
   addPolygons(fillColor = ~paleta(IP2011),
               color = "#444444",
               weight = 0.001,
               stroke = FALSE,
               smoothFactor = 0,
               opacity = 1.0,
               fillOpacity = 0.7,
               popup = paste("Sección censal: ", sc$CUSEC, "<br>Municipio: ", sc$NMUN, "<br>Índice de privación: ", round(sc$IP2011, 1))) %>%
   addLegend("bottomleft", 
             colors = paleta(sc@data$IP2011) %>% table %>% row.names %>% rev,
             labels= c("Q1 (Menos privación)", "Q2", "Q3", "Q4", "Q5 (Más privación)"),
             title= "Índice de privación (SEE, 2011)",
             opacity = 0.7) -> mapa
mapa

# Guardar mapa en HTML:
saveWidget(mapa, file = "mapeo_ip.html", selfcontained = F)
