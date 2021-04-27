# STAT 515 Final Project
# Doug Cady
# Apr 2021

library(dplyr)
library(lattice)
library(hexbin)
source("windows_gui.R")

# Load rds data file
ri_stops_fn <- '../input/yg821jf8611_ri_statewide_2020_04_01.rds'

ri_stops <- readRDS(ri_stops_fn)

summary(ri_stops)
glimpse(ri_stops)


# Scatterplot matrix to begin EDA
offDiag <- function(x,y,...){
    panel.grid(h=-1,v=-1,...)
    panel.hexbinplot(x,y,xbins=12,...,border=gray(.7),
       trans=function(x)x^1)
    panel.loess(x , y, ..., lwd=2,col='purple')
}

onDiag <- function(x, ...){
    yrng <- current.panel.limits()$ylim
    d <- density(x, na.rm=TRUE)
    d$y <- with(d, yrng[1] + 0.95 * diff(yrng) * y / max(y) )
    panel.lines(d,col=rgb(.83,.66,1),lwd=2)
    diag.panel.splom(x, ...)
}

windows(width=9, height=9)
splom(ri_stops,
    xlab='', main="Police Stop in RI 2005-2015",
    pscale=0, varname.cex=0.8, axis.text.cex=0.6,
    axis.text.col="red", axis.text.font=2,
    axis.line.tck=.5
    # panel=offDiag,
    # diag.panel = onDiag
)
