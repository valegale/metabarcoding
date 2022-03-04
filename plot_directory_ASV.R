library(reshape2)
library(ggplot2)
library(gridExtra)

# PLOTTING THE ENTIRE DIRECTORY. ONE FILE FOR EACH SPECIES ####

#insert here the path to the results folder
# ex. path = "C:/.../results"
path <- "C:/metabarcoding/results/"

#insert name of the directory with all ASVs separated in different files 
#this directory is obtained from extracting_ASVs.py. Important: the second 
#column should be filled with the ASVs ID

results_dir <- "poland_seqtab_ASV"

path_result <- paste(path, results_dir, "/", sep = "")
setwd(path_result)

path_plots <- paste(path, "plots/", results_dir,"/", sep = "")
dir.create(path_plots)

file_list <- list.files()
ggplot_list <- list()
i = 1
for (file_name in file_list){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col = ncol(file_csv)-9
  n_row = nrow(file_csv)
  r_n <- file_csv[,1]
  df1 <- data.frame(file_csv[,2:n_col], 
                                "row_names" = r_n)
  df2 <- melt(df1,"row_names")
  g <- ggplot(data=df2, aes(x=variable, y=value, group=row_names)) +
    geom_line(aes(color=row_names))+ ylab("# reads") +
    xlab("samples")+ theme(legend.title = element_blank(), axis.text.x = element_blank()) + ggtitle(tools::file_path_sans_ext(file_name))
  ggplot_list[[i]] = g
  i <- i +1 
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot for ", tools::file_path_sans_ext(file_name), sep = "")
  print(printing)  
  #for points <- geom_point(aes(color=row_names)) 
}


# PLOTTING JUST ONE SPECIES ####
#insert here the file with the species you are interested in, example:
# file_name = "Aulacoseira_granulata.csv"
file_name = "Aulacoseira_granulata.csv"

file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
n_col = ncol(file_csv)-9
n_row = nrow(file_csv)
r_n <- paste( "species", 1:n_row)
r_n <- file_csv[,1]
df1 <- data.frame(file_csv[,2:n_col], 
                  "row_names" = r_n)
df2 <- melt(df1,"row_names")
g <- ggplot(data=df2, aes(x=variable, y=value, group=row_names)) +
  geom_line(aes(color=row_names))+ ylab("# reads") +
  xlab("samples")+ theme(legend.title = element_blank(), axis.text.x = element_blank()) + ggtitle(tools::file_path_sans_ext(file_name))
g 


# NORMALIZING BEFORE PLOTTING THE ENTIRE DIRECTORY. ONE FILE FOR EACH SPECIES ########
# plotting relative abundance

#insert here the path to the results folder
# ex. path = "C:/.../results"
path <- "C:/metabarcoding/results/"

#insert name of the directory with all ASVs separated in different files 
#this directory is obtained from extracting_ASVs.py. Important: the second 
#column should be filled with the ASVs ID

results_dir <- "poland_seqtab_ASV"

path_result <- paste(path, results_dir,"/", sep = "")
setwd(path_result)

path_plots <- paste(path, "plots/", results_dir,"_normalized/", sep = "")
dir.create(path_plots)

file_list <- list.files()
ggplot_list <- list()
i = 1
for (file_name in file_list){
  file_csv <- read.csv(file=paste(path_result, file_name, sep = ""), header=TRUE, row.names = 1)
  n_col = ncol(file_csv)-9
  n_row = nrow(file_csv)
  r_n <- file_csv[,1]
  temp <- file_csv[,2:n_col]
  normalized_table <- t(apply(file_csv[,2:n_col], 1, function(x)(x-min(x))/(max(x)-min(x))))
  
  df1 <- data.frame(normalized_table, 
                    "row_names" = r_n)
  df2 <- melt(df1,"row_names")
  g <- ggplot(data=df2, aes(x=variable, y=value, group=row_names)) +
    geom_line(aes(color=row_names))+ ylab("# reads") +
    xlab("samples")+ theme(legend.title = element_blank(), axis.text.x = element_blank()) + ggtitle(tools::file_path_sans_ext(file_name))
  ggplot_list[[i]] = g
  i <- i +1 
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  printing <- paste("saving plot for ", tools::file_path_sans_ext(file_name), sep = "")
  print(printing)
  #for points <- geom_point(aes(color=row_names)) 
}

#TO DO ####
# insert a file with the order -- change from sample to time