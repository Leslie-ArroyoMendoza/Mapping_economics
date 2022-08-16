## Mapping_economics: Explaining macroeconomics in a better way


My main purpose is to show the change in the number of entreprises per 1000 habitants before and after the first years of COVID. 

With this R code you will be able to plot data extrated from [SIRTOD](https://systems.inei.gob.pe/SIRTOD/) and plot it in R.

![alt text](https://github.com/Leslie-ArroyoMendoza/Mapping_economics/blob/5fb41af1893fcb87df6d59ecab86e904876ede84/SIRTOD.png)

## Dowload the data
This respository is aimed to plot 1 calculated variable: **number of entreprises per 1000 habitants** = __Número de empresas por estado__ divided by __Población total__ 

Variables in SIRTOD: 
* Demográfico
  * Población Estimada y Proyectada
      + __Población total__
 
* Económico 
  * Empresas y Establecimientos
      + __Número de empresas por estado__
 
Or use the excel file: Lima_data.xlsx
```r
# direccion is the path where the data has been saved
Lima_data<-read_excel(paste0(direccion,'/Lima_data.xlsx'),skip = 7)
```

## Shapefiles
The map can be dowloaded in [GEO GPS PERÚ](https://www.geogpsperu.com/2014/03/base-de-datos-peru-shapefile-shp-minam.html).

Or extract *provincia* folder with shapefiles located in the RAR folder and save it next to the R script
```r
lima<-readOGR(paste0(direccion,"/provincia"), layer="PROVINCIAS",use_iconv = T,
              encoding = 'UTF-8')
```

## Cleaning data
The excel file that you can obtain from SIRTOD is not clean and it must be processed to obtain the variable we want to plot.
We will use the package __dplyr__ to clean and create the variable *Enterprise_per_capita*
 
 ## Plotting variable
 After creating the variable and merging it with the shapefiles, we will use the package  __spplot__ to plot our variable.
 
 You will obtain three graphs like this:
 
 ![alt text](https://github.com/Leslie-ArroyoMendoza/Mapping_economics/blob/a98a2ac1c54ef942d0dc5bc554baf3c0d3dc4080/Graph2.png)
 
 
