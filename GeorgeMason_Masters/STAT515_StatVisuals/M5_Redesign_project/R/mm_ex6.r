
######
#
#   micromapST - Example 06 - horizontal stacked (segmented) bars
#     segbar plots the input data, normbar plots percent of total
#     package computes the percents from input data
#     input for the categories for each state must be in consecutive
#     columns of the input data.frame using the default border group
#     of "USStatesBG".
#
#     Turning off the variable bar height and the midpoint dot features
#     in the horizontal stacked bars (segmented)
#
#  USES data loaded for Example 05 above - statePop2010.
#
####

data(statePop2010,envir=environment())

panelDesc06= data.frame(
      type=c("map","id","segbar","normbar"),
      lab1=c("","","Stacked Bar","Normalized Stacked Bar"),
      lab2=c("","","Counts","Percent"),
      col1=c(NA,NA,"Hisp","Hisp"),
      col2=c(NA,NA,"OtherWBH","OtherWBH")
    )

pdf(file="../graphics/Ex06-Stkd-Bar-fixedheight-nodot.pdf",width=7.5,height=10)

micromapST(statePop2010,panelDesc06,sortVar=4,ascend=FALSE,
             title=c("Ex7-Stacked Bars: 2010 Census Pop by Race, Sorted by Other Race",
             "Cat-L to R: Hisp, non-Hisp White, Black, Other,ID-diamond"),
             details=list(SNBar.Middle.Dot=FALSE,SNBar.varht=FALSE,Id.Dot.pch=23)
           )
dev.off()

## End Example 06
