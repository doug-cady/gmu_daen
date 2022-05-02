Human Freedom Index and Suicides Project
================
Doug Cady
November 6, 2021

``` r
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
```

## Load datasets into R

``` r
suicides <- read_csv("../data/suicide_rates.csv")
hfi <- read_csv("../data/hfi_cc_2018.csv")
```

## Explore Suicides dataset

``` r
print(summary(suicides))
```

    ##    country               year          sex                age           
    ##  Length:27820       Min.   :1985   Length:27820       Length:27820      
    ##  Class :character   1st Qu.:1995   Class :character   Class :character  
    ##  Mode  :character   Median :2002   Mode  :character   Mode  :character  
    ##                     Mean   :2001                                        
    ##                     3rd Qu.:2008                                        
    ##                     Max.   :2016                                        
    ##                                                                         
    ##   suicides_no      population       suicides/100k pop country-year      
    ##  Min.   :    0   Min.   :     278   Min.   :  0.00    Length:27820      
    ##  1st Qu.:    3   1st Qu.:   97498   1st Qu.:  0.92    Class :character  
    ##  Median :   25   Median :  430150   Median :  5.99    Mode  :character  
    ##  Mean   :  243   Mean   : 1844794   Mean   : 12.82                      
    ##  3rd Qu.:  131   3rd Qu.: 1486143   3rd Qu.: 16.62                      
    ##  Max.   :22338   Max.   :43805214   Max.   :224.97                      
    ##                                                                         
    ##   HDI for year   gdp_for_year ($)   gdp_per_capita ($)  generation       
    ##  Min.   :0       Min.   :4.69e+07   Min.   :   251     Length:27820      
    ##  1st Qu.:1       1st Qu.:8.99e+09   1st Qu.:  3447     Class :character  
    ##  Median :1       Median :4.81e+10   Median :  9372     Mode  :character  
    ##  Mean   :1       Mean   :4.46e+11   Mean   : 16866                       
    ##  3rd Qu.:1       3rd Qu.:2.60e+11   3rd Qu.: 24874                       
    ##  Max.   :1       Max.   :1.81e+13   Max.   :126352                       
    ##  NA's   :19456

read\_csv(“../data/hfi\_cc\_2018.csv”)
