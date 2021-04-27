# Windows function for all platforms

windows <- function(width = 7, height = 7) {
    init_platform <- sessionInfo()$platform

    if (grepl("linux", init_platform)) {
        platform <- x11(width=width, height=height)
    } else if (grepl("apple", init_platform)) {
        platform <- quartz(width=width, height=height)
    } else {
        platform <- windows(width=width, height=height)
    }
}
