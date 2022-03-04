library(reshape2)
library(ggplot2)
library(gridExtra)

# Plotting the entire directory. One file for each species ####

#insert here the path to the results folder
# ex. path = "C:/.../results"
path <- "C:/metabarcoding/results/"
path <- "/home/valentina_galeone/Desktop/github_rep/metabarcoding/results/"

#insert name of the directory with all ASVs separated in different files 
#this directory is obtained from extracting_ASVs.py. Important: the second 
#column should be the ASVs ID

results_dir <- "seqtab_nonchim_id_ASV/"

path_result <- paste(path, results_dir, sep = "")
setwd(path_result)
 
path_plots <- paste(path, "plots/", sep = "")
dir.create(path_plots)
path_plots <- paste(path, "plots/", results_dir, sep = "")
dir.create(path_plots)

file_list <- list.files()
ggplot_list <- list()
i = 1
for (file_name in file_list){
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
  ggplot_list[[i]] = g
  i <- i +1 
  name_file <- paste(path_plots, tools::file_path_sans_ext(file_name), ".png", sep = "")
  ggsave(name_file, width = 8, height = 4.5, dpi=500)
  
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


#TO DO ####
# plotting relative abundance

#TO DO ####
# insert a file with the order -- change from sample to time