library(tidyverse)
library(viridis)
library(gridExtra)
library(ggpubr)

projects <- c("compA_proj3", "compB_proj4", "compB_proj4_int")

cbb_palette = c("Jaccard" = "#E69F00",
            "SS" = "#CC79A7",
            "Levenshtein" = "#009E73",
            "NCD" = "#000000",
            "Random" = "#56B4E9")


generate_plots <- function(project_name) {
  filename <- paste0("coverage_plot/", project_name, ".csv")
  rawdf <- read.csv(filename, header = T)
  colnames(rawdf) <- c("Technique", "TC.ID", "Priority", "Num.Req.Covered")
  
  cov_summary <-  rawdf %>% 
    separate(col = Technique, into = c("Technique", "Trial"), sep = "_") %>% 
    mutate(Trial = ifelse(is.na(Trial), 1, Trial))
  
  rdm_sub_df <- cov_summary %>% 
    filter(Technique == "Random") %>% 
    group_by(Technique, Priority) %>% 
    summarise(Num.Req.Covered = mean(Num.Req.Covered))
  
  joined_df <- cov_summary %>% 
    filter(Technique != "Random") %>% 
    select(Technique, Priority, Num.Req.Covered) %>% 
    bind_rows(., rdm_sub_df) %>% 
    filter(Priority == 1 | (Priority %% 10 == 0))
  
  sum_df <- joined_df %>% 
    group_by(Technique) %>% 
    mutate(Budget = round(100*Priority / max(Priority)),
           Perc.Covered = round(100*Num.Req.Covered / max(Num.Req.Covered))) %>% 
    filter(Budget == 1 | (Budget %% 10 == 0))
  
  cov_plot <- ggplot(sum_df, aes(x = Budget, y = Perc.Covered, color = Technique)) +
    geom_line() + geom_point() + 
    scale_x_continuous(limits = c(0,100), breaks = seq(0,100, by = 10)) +
    scale_y_continuous(limits = c(0,100), breaks = seq(0,100, by = 10)) +
    labs(x = "Budget", y = "Requirements Covered (%)", title = project_name) +
    scale_color_manual(values = cbb_palette) +
    theme_bw() + theme(legend.position = "bottom")
  return(cov_plot)
}

p1 <- generate_plots("Comp A - System")
p2 <- generate_plots("Comp B - System")
p3 <- generate_plots("Comp B - Integration")

all_plots <- ggarrange(p1, p2, p3, ncol=2, nrow=2, common.legend = TRUE)

ggsave(all_plots, filename = "allplots.pdf", device = pdf(), width = 15, height = 15, units = "cm")


