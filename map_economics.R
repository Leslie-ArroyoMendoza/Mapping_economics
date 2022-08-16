# Number of enterprises in Lima department
# evaluation of economy post first waves of COVID
rm(list=ls())
usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)}

paquetes<-c('readxl','dplyr','stringr','tidyr',
            "rgdal","rstudioapi","lattice",
            "latticeExtra")
options(warn = - 1)  
lapply(paquetes, usePackage)


path<-getSourceEditorContext()$path
direccion<-dirname(path)


# Import data, shape files at "provincia" level
# Provincia: subnational region of Peru
lima<-readOGR(paste0(direccion,"/provincia"), 
              layer="PROVINCIAS",use_iconv = T,
              encoding = 'UTF-8')

# Import data of Lima's provinces
# source https://systems.inei.gob.pe/SIRTOD/
# select variables needed: total population estimates
#                    number of enterprises 
# then save file as xlsx
Lima_data<-read_excel(paste0(direccion,'/Lima_data.xlsx'),skip = 7)

##################################################
# DATA CLEANING ##################################
################################################
# Delete columns with all NAs
Lima_data <- Lima_data[ , colSums(is.na(Lima_data)) < nrow(Lima_data)]

# change the names of the variables
colnames(Lima_data)<-c(colnames(Lima_data)[1:3],seq(2019,2021,by=1))

#Delete rows with no relevant data
Lima_data<-Lima_data %>% 
  filter(!is.na(Lima_data$`2019`) |!is.na(Lima_data$`2021`))

# Fill missing row data, convert string to numeric, filter variables
Lima_data<-Lima_data  %>% 
  tidyr::fill(DEPARTAMENTO,.direction = c('down'))%>%
  tidyr::fill(PROVINCIA,.direction = c('down')) %>%
  mutate(across(.cols = 4:6,function(x) as.numeric(gsub(" ","",x)))) %>%
  select(-DEPARTAMENTO) 

####################################################
# Number of enterprises per 1000 people
#####################################################
# calculate the variable of study
 Lima_data<-Lima_data %>% 
  pivot_longer(cols = 3:5,names_to = 'Year',values_to = "Data") %>%
  pivot_wider(names_from = "INDICADOR",values_from = "Data") %>%
  mutate(Enterprise_Per_Capita=.[[4]]/(.[[5]]/1000),
         PROVINCIA=chartr("аимсз","AEIOU",PROVINCIA))%>% 
  dplyr::select(PROVINCIA,Year,Enterprise_Per_Capita)

# create function to plot a map depending on the year
plot_data<-function(data,year,lima){
  data<-data %>% 
    dplyr::filter(Year==year) %>%
    dplyr::select(PROVINCIA, Enterprise_Per_Capita)
  #merge the data with the plotting coordinates
  lima@data<-lima@data %>%full_join(data,by='PROVINCIA')
  # save province names
  prov<-lima@data$PROVINCIA[128:137]
  # save data only related to Lima department
  rlima<-lima[which(lima@data$PROVINCIA %in% prov),]
  # Adding formats to plot
  variable_name<-names(lima)[7]
  format <- list('sp.text', coordinates(rlima) , prov,
                 spar=.1,
                 col='black', cex=0.6,
                 fontface=2)
  # shit the coordinates for the numeric info of the variable
  coords<-coordinates(rlima)
  coords[,2]<-coords[,2]-0.06
  
  # Adding numeric info to plot
  labels_data <- list('sp.text', coords, 
                      sapply(round(data[,2],0),as.character),
              cex=0.45, col='white',
              fontface=2)
 
  # Changing colors #####################################
  manual.col = colorRampPalette(c("#1a78f8","#f61370"))
  color.match=rev(manual.col(150))
  # Plotting
  p<-spplot(rlima, variable_name, sp.layout=list(format,labels_data),
         col.regions=color.match,
         main=paste0('Enterprises per 1000 habitants in ' , year) )
  #return the plot 
  return(p)
}

graph1<-plot_data(Lima_data,'2019',lima)
graph2<-plot_data(Lima_data,'2020',lima)
graph3<-plot_data(Lima_data,'2021',lima)


# colors ##
#https://www.0to255.com/de4e29


