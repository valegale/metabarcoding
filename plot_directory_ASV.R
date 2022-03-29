library(reshape2)
library(ggplot2)
library(gridExtra)
library(dplyr)

#insert here the path to the results folder
# ex. path <-  "C:/.../results"
# ex. path <- "C:/metabarcoding/results/"
path <- "/home/valentina_galeone/Desktop/github_rep/metabarcoding/results/"

#insert name of the directory in result with the ASVs separated in different files.
#this directory is obtained from extracting_ASVs.py. 
#Important: the second column should be filled with the ASVs ID
#ex. results_dir <- "seqtab_nonchim_id_ASV"
results_dir <- "poland_seqtab_ASV"

path_result <- paste(path, results_dir, "/", sep = "")
setwd(path_result)

# norm = TRUE if you want to normalize by the highest peak for the ASV. 
norm <- FALSE

# for ORDERING: insert a file with a column with the name of the samples (column name: SAMPLE_NAME), 
# and either a column with dates (column name: DATE) if you want to order by dates, or a column with simply an order (column name: Order).
# additionally, for ordering AND grouping in different plots, the file should also have a column with the groups
# (column name: Group)
#label_file <- "/home/valentina_galeone/Desktop/github_rep/metabarcoding/Data/sample_labels_mugg.csv" #muggelsee
label_file <- "/home/valentina_galeone/Desktop/github_rep/metabarcoding/Data/sample_labels_poland.csv" #poland
#change here the format of the date 
format_dates = "%d.%m.%y" 

# Plotting just one species ####
#insert here the file with the species you are interested in, this file should be in results_dir
# file_name = "Aulacoseira_granulata.csv"
file_name <-  "Aulacoseira_granulata.csv"

file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
n_col = ncol(file_csv)-9
n_row = nrow(file_csv)
r_n <- paste( "species", 1:n_row)
r_n <- file_csv[,1]
if (norm == TRUE){
  normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
  df1 <- data.frame(normalized_table, 
                    "row_names" = r_n)
} else if (norm == FALSE){
  df1 <- data.frame(file_csv[,2:n_col], 
                    "row_names" = r_n)
}
df2 <- melt(df1,"row_names")
g <- ggplot(data=df2, aes(x=variable, y=value, group=row_names)) +
  geom_line(aes(color=row_names))+ ylab("# reads") +
  xlab("samples")+ theme(legend.title = element_blank(), axis.text.x = element_blank()) + ggtitle(tools::file_path_sans_ext(file_name))
g 

# Plotting just one species, ordered by Date ####
file_name <-  "Aulacoseira_granulata.csv"

file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
n_col <- ncol(file_csv)-9
n_row <- nrow(file_csv)
r_n <- file_csv[,1]
if (norm == TRUE){
  normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
  df1 <- data.frame(normalized_table, 
                    "ASV_ID" = r_n)
} else if (norm == FALSE){
  df1 <- data.frame(file_csv[,2:n_col], 
                    "ASV_ID" = r_n)
}
df2 <- melt(df1,"ASV_ID")
colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
df_dates <- merge(df2, sample_dates, by.x = "SAMPLE_NAME")

df_dates$Date <- as.Date(df_dates$Date, format = format_dates) 
g <- ggplot(data=df_dates, aes(x=Date, y=value, group = ASV_ID, color=ASV_ID)) +
  geom_line() + theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust=1)) +
  ylab("nr of reads") +
  xlab("") +
  theme(legend.position = "right") +scale_x_date(date_labels = "%Y %b %d") + theme(legend.title = element_blank()) 
g 

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

file_list <- list.files()
ggplot_list <- list()
i <- 1
for (file_name in file_list){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col = ncol(file_csv)-9
  n_row = nrow(file_csv)
  r_n <- paste( "species", 1:n_row)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "row_names" = r_n)
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "row_names" = r_n)
  }
  df2 <- melt(df1,"row_names")
  g <- ggplot(data=df2, aes(x=variable, y=value, group=row_names)) +
    geom_line(aes(color=row_names))+ ylab("# reads") +
    xlab("samples")+ theme(legend.title = element_blank(), axis.text.x = element_blank()) + ggtitle(tools::file_path_sans_ext(file_name))
  ggplot_list[[i]] = g
  i <- i + 1 
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot for ", tools::file_path_sans_ext(file_name), sep = "")
  print(printing)  
  #for points <- geom_point(aes(color=row_names)) 
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

file_list <- list.files()
ggplot_list <- list()
i = 1
for (file_name in file_list){
  
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col <- ncol(file_csv)-9
  n_row <- nrow(file_csv)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "ASV_ID" = r_n)
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "ASV_ID" = r_n)
  }
  df2 <- melt(df1,"ASV_ID")
  colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
  df_dates <- merge(df2, sample_dates, by.x = "SAMPLE_NAME")
  
  df_dates$Date <- as.Date(df_dates$Date, format = format_dates) 
  
  g <- ggplot(data=df_dates, aes(x=Date, y=value, group = ASV_ID, color=ASV_ID)) +
    geom_line() + theme_bw() + 
    theme(axis.text.x = element_text(angle = 45, hjust=1)) +
    ylab("nr of reads") +
    xlab("") +
    theme(legend.position = "right") +scale_x_date(date_labels = "%Y %b %d") + theme(legend.title = element_blank()) 
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot for ", tools::file_path_sans_ext(file_name), sep = "")
  print(printing)
  #for points <- geom_point(aes(color=row_names)) 
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

file_list <- list.files()
ggplot_list <- list()
i = 1
for (file_name in file_list){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col <- ncol(file_csv)-9
  n_row <- nrow(file_csv)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "ASV_ID" = r_n)
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "ASV_ID" = r_n)
  }
  df2 <- melt(df1,"ASV_ID")
  colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
  df_order <- merge(df2, sample_order, by.x = "SAMPLE_NAME")
    
  g <- ggplot(data=df_order, aes(x=Order, y=value, group = ASV_ID, color=ASV_ID)) +
    geom_line() + theme_bw() + 
    theme(axis.text.x = element_text(angle = 45, hjust=1)) +
    ylab("nr of reads") +
    xlab("") +
    theme(legend.position = "right")  + theme(legend.title = element_blank()) 
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot for ", tools::file_path_sans_ext(file_name), sep = "")
  print(printing)
}
  
# Ordering by Order + separating by Group ####
#ORDERING by Order column and making groups with Group column
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

file_list <- list.files()
ggplot_list <- list()
i = 1
for (file_name in file_list){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col <- ncol(file_csv)-9
  n_row <- nrow(file_csv)
  r_n <- file_csv[,1]
  if (norm == TRUE){
    normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
    df1 <- data.frame(normalized_table, 
                      "ASV_ID" = r_n)
  } else if (norm == FALSE){
    df1 <- data.frame(file_csv[,2:n_col], 
                      "ASV_ID" = r_n)
  }
  df2 <- melt(df1,"ASV_ID")
  colnames(df2) <- c("ASV_ID", "SAMPLE_NAME", "value")
  df_group <- merge(df2, sample_order, by.x = "SAMPLE_NAME")
  all_df <- split(df_group, df_group$Group)
  
  i <- 1
  for (single_df in all_df){
    g <- ggplot(data=single_df, aes(x=Order, y=value, group = ASV_ID, color=ASV_ID)) +
      geom_line() + theme_bw() + 
      theme(axis.text.x = element_text(angle = 45, hjust=1)) +
      ylab("nr of reads") +
      xlab("") +
      theme(legend.position = "right") + theme(legend.title = element_blank())    
    ggplot_list[[i]] <- g
    i <- i + 1 
  }
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(paste(name_file, ".png", sep = ""), do.call("arrangeGrob", c(ggplot_list, ncol = 1)))
  printing <- paste("saving plot for ", tools::file_path_sans_ext(file_name), sep = "")
  print(printing)
}
