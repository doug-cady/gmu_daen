######
#   micromapST - Example # 02 - map with cumulative shading
#                      from top down (mapcum), arrow and bar charts,
#                      sorted in descending order by starting
#                      value of arrows (1950-69 rates) using default
#                      border group of "USStatesDF".  This
#                      example also provides custom colors for the
#                      linked micromaps, highlights, etc.
#
####
# Load example data from package.

data(wmlung5070,wmlung5070US,envir=environment())

glimpse(wmlung5070)

panelDesc02 <- data.frame(
   type=c("mapcum","id","arrow","bar"),
   lab1=c("","","Rates in","Percent Change"),
   lab2=c("","","1950-69 and 1970-94","1950-69 To 1970-94"),
   lab3=c("MAPCUM","","Deaths per 100,000","Percent"),
   col1=c(NA,NA,"RATEWM_50","PERCENT"),
   col2=c(NA,NA,"RATEWM_70",NA)
 )

colorsRgb = matrix(c(                    # the basic 7 colors.
 213,  62,  79,   #region 1: red        #D53E4F - Rust Red
 252, 141,  89,   #region 2: orange     #FC8D59 - Brn/Org
 253, 225, 139,   #region 3: green      #FEE08B - Pale Brn
 153, 213, 148,   #region 4: greenish blue  #99D594 - med Green
  50, 136, 189,   #region 5: lavendar       #3288BD - Blue
 255,   0, 255,   #region 6                 #FF00FF - Magenta
 .00, .00, .00,   #region 7: black for median #000000 - Black
 230, 245, 152,   #non-highlighted foreground #E6F598 - YellowGreen
 255, 174, 185,   # alternate shape upper   #FFAEB9 - Mauve
 191, 239, 255,   # alternate shape lower   #BFEFFF - Cyan
 242, 242, 242,   # lightest grey for non-referenced sub-areas  #F2F2F2
 234, 234, 234),  # lighter grey for background - non-active sub-areas. #EAEAEA

  ncol=3,byrow=TRUE)

xcolors = c( grDevices::rgb(colorsRgb[,1],colorsRgb[,2],colorsRgb[,3],
                            maxColorValue=255),
              # set solid colors
            grDevices::rgb(colorsRgb[,1],colorsRgb[,2],colorsRgb[,3],64,
                            maxColorValue=255))
              # set translucent colors for time series.

# set up reference names for color set
names(xcolors) =c("rustred","orange","lightbrown","mediumgreen",
                  "blue","magenta", "black","yellowgreen",
                  "mauve","cyan","lightest grey","lighter grey",
                  "l_rustred","l_orange","vlightbrown","lightgreen",
                  "lightblue","l_black","l_yelgreen","l_mauve",
                  "l_cyan","l_lightest grey","l_lighter grey")

pdf(file="../graphics/Ex02-WmLung50-70-Arrow-Bar.pdf",width=7.5,height=10)

micromapST(wmlung5070,panelDesc02,sortVar=1,ascend=FALSE,
        title=c("Ex02-Change in White Male Lung Cancer Mortality Rates",
                   "from 1950-69 to 1970-94-Diff colors"), colors=xcolors
            )

dev.off()
##End Example 02
