library(reshape2)
library(ggplot2)
library(gridExtra)
library(dplyr)

#insert here the path to the results folder
# ex. path <-  "C:/.../results"
path <- "/home/valentina_galeone/Desktop/github_rep/metabarcoding/results/"

#insert name of the directory in result with the ASVs separated in different files.
#this directory is obtained from extracting_ASVs.py. 
#Important: the second column should be filled with the ASVs ID
results_dir <- "seqtab_nonchim_id_ASV"

path_result <- paste(path, results_dir, "/", sep = "")
setwd(path_result)

# norm = TRUE if you want to normalize by the highest peak for the ASV. 
norm <- FALSE

# for ORDERING: insert a file with a column with the name of the samples (column name: SAMPLE_NAME), 
# and either a column with dates (column name: DATE) if you want to order by dates, or a column with simply an order (column name: Order).
# additionally, for ordering AND grouping in different plots, the file should also have a column with the groups
# (column name: Group)
label_file <- "/home/valentina_galeone/Desktop/github_rep/metabarcoding/Data/sample_labels_mugg.csv" 
#change here the format of the date 
format_dates = "%d.%m.%y" 

# Plotting one species ####

#this function plots one species, given the name of the species and norm = TRUE or FALSE.
plot_one_species <- function(file_name, norm){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col = ncol(file_csv)-9
  n_row = nrow(file_csv)
  r_n <- paste( "species", 1:n_row)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "row_names" = r_n)
    ylab_text <- "% reads"
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "row_names" = r_n)
    ylab_text <- "# reads"
  }
  df2 <- melt(df1,"row_names")
  g <- ggplot(data=df2, aes(x=variable, y=value, group=row_names)) +
    geom_line(aes(color=row_names))+ ylab(ylab_text) +
    xlab("samples")+ theme(legend.title = element_blank(), axis.text.x = element_blank()) + ggtitle(tools::file_path_sans_ext(file_name))
  return (g)
}

#insert here the file with the species you are interested in, check that this file is in *results_dir*
file_name <-  "Aulacoseira_granulata.csv"
g <- plot_one_species(file_name, norm)
g

# Plotting just one species, ordered by Date ####

#this function plots one species, given the name of the species and norm = TRUE or FALSE and a dataset where each 
#sample name is associated to a date
plot_one_species_dates <- function(file_name, norm, sample_dates){
  n_col <- ncol(file_csv)-9
  n_row <- nrow(file_csv)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "ASV_ID" = r_n)
    ylab_text <- "% reads"
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "ASV_ID" = r_n)
    ylab_text <- "# reads"
  }
  df2 <- melt(df1,"ASV_ID")
  colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
  df_dates <- merge(df2, sample_dates, by.x = "SAMPLE_NAME")
  
  df_dates$Date <- as.Date(df_dates$Date, format = format_dates) 
  g <- ggplot(data=df_dates, aes(x=Date, y=value, group = ASV_ID, color=ASV_ID)) +
    geom_line() + theme_bw() + 
    theme(axis.text.x = element_text(angle = 45, hjust=1)) +
    ylab(ylab_text) +
    xlab("") +
    theme(legend.position = "right") +scale_x_date(date_labels = "%Y %b %d") + theme(legend.title = element_blank()) 
  return (g)
}

file_name <-  "Aulacoseira_granulata.csv"
file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)

#reading the file with the dates
sample_dates <- read.csv(file=label_file, header=TRUE, sep = ",") %>% select(c(SAMPLE_NAME, Date))
g <- plot_one_species_dates(file_name, norm, sample_dates)
g

# Plotting just one species, ordered by Order ####

#this function plots one species, given the name of the species and norm = TRUE or FALSE and a dataset where each 
#sample name is associated to an order
plot_one_species_order <- function(file_name, norm, sample_order){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col <- ncol(file_csv)-9
  n_row <- nrow(file_csv)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "ASV_ID" = r_n)
    ylab_text <- "% reads"
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "ASV_ID" = r_n)
    ylab_text <- "# reads"
  }
  df2 <- melt(df1,"ASV_ID")
  colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
  df_order <- merge(df2, sample_order, by.x = "SAMPLE_NAME")
  
  g <- ggplot(data=df_order, aes(x=Order, y=value, group = ASV_ID, color=ASV_ID)) +
    geom_line() + theme_bw() + 
    theme(axis.text.x = element_text(angle = 45, hjust=1)) +
    ylab(ylab_text) +
    xlab("") +
    theme(legend.position = "right")  + theme(legend.title = element_blank()) 
  return (g)
}

file_name <-  "Aulacoseira_granulata.csv"
file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)

#reading the file with the dates
sample_order <- read.csv(file=label_file, header=TRUE, sep = ",") %>% select(c(SAMPLE_NAME, Order))
g <- plot_one_species_order(file_name, norm, sample_order)
g

# Plotting just one species, ordered by Order + grouped by Group ####

#this function plots one species, given the name of the species and norm = TRUE or FALSE and a dataset where each 
#sample name is associated to an order an a group (different plot for each group)
# it is used inside the last chunk of code, check below. 

plot_one_species_order_group <- function(file_name, norm, sample_order){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col <- ncol(file_csv)-9
  n_row <- nrow(file_csv)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "ASV_ID" = r_n)
    ylab_text <- "% reads"
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "ASV_ID" = r_n)
    ylab_text <- "# reads"
  }
  df2 <- melt(df1,"ASV_ID")
  colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
  df_group <- merge(df2, sample_order, by.x = "SAMPLE_NAME")
  all_df <- split(df_group, df_group$Group)
  
  ggplot_list <- list()
  i <- 1
  for (single_df in all_df){
    g <- ggplot(data=single_df, aes(x=Order, y=value, group = ASV_ID, color=ASV_ID)) +
      geom_line() + theme_bw() + 
      theme(axis.text.x = element_text(angle = 45, hjust=1)) +
      ylab(ylab_text´) +
      xlab("") +
      theme(legend.position = "right") + theme(legend.title = element_blank())    
    ggplot_list[[i]] <- g
    i <- i + 1 
  }
  return (ggplot_list)
}


# Plotting the entire directory. one file for each species ####
path_plots <- paste(path, "plots/", sep = "")
dir.create(path_plots)

# creating a *results_dir*_normalized folder if norm = True, otherwise only a folder called with the same name as 
# *results_dir* inside plots.
# Each plot is a different species with all the matching ASVs. 
if (norm == TRUE){
  path_plots <- paste(path, "plots/", results_dir,"_normalized/", sep = "")
  dir.create(path_plots)
} else if (norm == FALSE){
  path_plots <- paste(path, "plots/", results_dir, "/", sep = "")
  dir.create(path_plots)
}

for (file_name in list.files()){ #for all files in the directory *results_dir*
  g <- plot_one_species(file_name, norm)
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot ", name_file, sep = "")
  print(printing)  
}


# Plotting the entire directory, ordered by Date ####

sample_dates <- read.csv(file=label_file, header=TRUE, sep = ",") %>% select(c(SAMPLE_NAME, Date))

path_plots <- paste(path, "plots/", sep = "")
dir.create(path_plots)

# creating a *results_dir*_normalized_ordered_date folder if norm = True, otherwise only a folder called  
# *results_dir*_ordered_date inside plots.
# Each plot is a different species with all the matching ASVs. 
if (norm == TRUE){
  path_plots <- paste(path, "plots/", results_dir,"_normalized_ordered_date/", sep = "")
  dir.create(path_plots)
} else if (norm == FALSE){
  path_plots <- paste(path, "plots/", results_dir, "_ordered_date/", sep = "")
  dir.create(path_plots)
}

for (file_name in list.files()){ #for all files in the directory *results_dir*
  g <- plot_one_species_dates(file_name, norm, sample_dates)
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot ", name_file, sep = "")
  print(printing)
}

# Plotting the entire directory + ordering by Order ####

sample_order <- read.csv(file=label_file, header=TRUE, sep = ",") %>% select(c(SAMPLE_NAME, Order))

# creating a *results_dir*_normalized_ordered folder if norm = True, otherwise only a folder called  
# *results_dir*_ordered inside plots.
# Each plot is a different species with all the matching ASVs. 
if (norm == TRUE){
  path_plots <- paste(path, "plots/", results_dir,"_normalized_ordered/", sep = "")
  dir.create(path_plots)
} else if (norm == FALSE){
  path_plots <- paste(path, "plots/", results_dir, "_ordered/", sep = "")
  dir.create(path_plots)
}

for (file_name in list.files()){ #for all files in the directory *results_dir*
  g <- plot_one_species_order(file_name, norm, sample_order)
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot for ", name_file, sep = "")
  print(printing)
}
  
# Plotting the entire directory + ordering by Order + separating by Group ####
# Ordering by Order column and making groups with Group column
# insert here the number of columns for the final layout of the image. number_column = 1, vertically ordered
number_column = 1

sample_order <- read.csv(file=label_file, header=TRUE, sep = ",") %>% select(c(SAMPLE_NAME, Group, Order))
  
path_plots <- paste(path, "plots/", sep = "")
dir.create(path_plots)
  
# creating a *results_dir*_normalized_ordered folder if norm = True, otherwise only a folder called  
# *results_dir*_ordered inside plots.
# Each plot is a different species with all the matching ASVs. 
if (norm == TRUE){
  path_plots <- paste(path, "plots/", results_dir,"_normalized_grouped/", sep = "")
  dir.create(path_plots)
} else if (norm == FALSE){
  path_plots <- paste(path, "plots/", results_dir, "_grouped/", sep = "")
  dir.create(path_plots)
}

for (file_name in list.files()){
  ggplot_list <- plot_one_species_order_group(file_name, norm, sample_order)
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, do.call("arrangeGrob", c(ggplot_list, ncol = 1)))
  printing <- paste("saving plot for ", name_file, sep = "")
  print(printing)
}

