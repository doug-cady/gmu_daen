######
#   micromapST - Example 05 - horizontal stacked (segmented) bars
#     segbar plots the input data, normbar plots percent of total
#     package computes the percents from input data
#     input for the categories for each state must be in consecutive
#     columns of the input data.frame using the default border group of "USStatesBG"
####

data(statePop2010,envir=environment())

panelDesc05 <- data.frame(
    type=c("map","id","segbar","normbar"),
    lab1=c("","","Stacked Bar","Normalized Stacked Bar"),
    lab2=c("","","Counts","Percent"),
    col1=c(NA,NA,"Hisp","Hisp"),
    col2=c(NA,NA,"OtherWBH","OtherWBH")
    )

pdf(file="../graphics/Ex05-Stkd-Bar-var-height.pdf",width=7.5,height=10)
micromapST(statePop2010, panelDesc05, sortVar="OtherWBH", ascend=FALSE,
     title=c("Ex05-Stacked Bars: 2010 Census Pop by Race, Sorted by Count Other Race",
             "Cat-L to R: Hispanic, non-Hisp White, Black, Other-sn-varbar"),
     details=list(SNBar.varht=TRUE), axisScale="sn" )
dev.off()
## End Example 05
