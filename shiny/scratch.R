##################################################
# Reorganize some data
##################################################
library(here)
library(readr)
library(tidyr)

# load up data in global.R first

# There are duplicated entries! We must remove these in order to spread, gather, and plot

# convert from long to wide and overwrite on google sheet
nr <- nr[!duplicated(nr), ] %>% 
  spread(ID, `Nivel (m)`)
# move comentario to end
nr <- cbind.data.frame(nr[, -2], nr[, 2])
# save file to copy paste if we stat reporting in wide format
readr::write_csv(nr, "nr_wide.csv")

# repeat for pozos
np <- np[!duplicated(np), ] %>% 
  spread(ID, `Nivel (m)`)
# move comentario to end
np <- cbind.data.frame(np[, -2], np[, 2])
# save file to copy paste if we stat reporting in wide format
readr::write_csv(np, "np_wide.csv")
