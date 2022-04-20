library(ggplot2);

wtDir1 <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.07.30_FishDev_WT_02_3/obj_probs";
wtDir2 <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.07.30_FishDev_WT_01_1/obj_probs";
#wtDir <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.12.04_20201127_FishDev_WT_28.5_1/obj_probs";
wt25Dir <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.08.04_FishDev_WT_25C_1/obj_probs";
#koDir <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.09.30_FishDev_KO1_1/obj_probs";
#wt33Dir <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.10.01_FishDev_WT_33C_1/obj_probs";
#wt26.5Dir <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.11.19_FishDev_WT_26.5_v2_1/obj_probs";

hpfOffset <- 4.5;
framesToHpf <- 0.25;

#files <- c(file.path(wtDir, list.files(wtDir, pattern = "txt")),
#           file.path(wt25Dir, list.files(wt25Dir, pattern = "txt")),
#           file.path(koDir, list.files(koDir, pattern = "txt")),
#           file.path(wt33Dir, list.files(wt33Dir, pattern = "txt")),
#           file.path(wt26.5Dir, list.files(wt26.5Dir, pattern = "txt")));

files <- c(file.path(wtDir1, list.files(wtDir1, pattern = "txt")),
           file.path(wtDir2, list.files(wtDir2, pattern = "txt")),
           file.path(wt25Dir, list.files(wt25Dir, pattern = "txt")));

allData <- data.frame();

for(f in files){
  # labelIndex <- regexpr("_[[:alpha:]][[:digit:]]{1,2}-", f);
  # labelLength <- attr(labelIndex, "match.length");
  # col <- as.numeric(substr(f,labelIndex + 2, labelIndex + labelLength - 2));
  exp <- "control";
  if(grepl("WT_25C", f)){
    exp <- "25C";
  }
  if(grepl("WT_26", f)){
    exp <- "26.5C";
  }
  if(grepl("WT_33C", f)){
    exp <- "33C";
  }
  if(grepl("02_3", f)){
    exp <- "control2";
  }
  if(grepl("KO1", f)){
    exp <- "KO";
  }
  
  data <- read.table(f);
  developed <- subset(data, !grepl("unhatched", data$Label));
  allData <- rbind(allData,
                   data.frame(actual_hpf = hpfOffset + (framesToHpf * (developed$Slice - 1)),
                              prob = developed$Mean,
                              type = exp,
                              original_file = f,
                              slice = developed$Slice));
}

#allData <- data.frame(allData, data.frame(logProb = log(allData$prob)));

allData <- allData[allData$actual_hpf < 17.5, ];
allData$predicted_hpf <- allData$prob * 17.25 + 1.5;

axislabel <- element_text(size=18, colour = "black");

p <- ggplot(NULL, aes(actual_hpf, predicted_hpf));
p <- p + geom_jitter(data=allData[allData$type=="control",], color=c("green"));
p <- p + geom_jitter(data=allData[allData$type=="control2",], color=c("red"));
p <- p + geom_jitter(data=allData[allData$type=="25C",], color=c("blue"));
#p <- p + geom_jitter(data=allData[allData$type=="26.5C",], color=c("green"));
#p <- p + geom_jitter(data=allData[allData$type=="KO",], color=c("yellow"));
p <- p + xlab("Actual HPF") + ylab("Predicted HPF");
p <- p + coord_cartesian(xlim = c(4, 18), ylim = c(2, 18));
p <- p + theme_minimal();
p + theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel);

p <- ggplot(NULL, aes(actual_hpf, predicted_hpf));
p <- p + geom_smooth(data=allData[allData$type=="control",], aes(colour="Control 1"), method="loess");
p <- p + geom_smooth(data=allData[allData$type=="control2",], aes(colour="Control"), method="loess");
p <- p + geom_smooth(data=allData[allData$type=="25C",], aes(colour="25 C"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="26.5C",], aes(colour="26.5 C"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="KO",], aes(colour="KO"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="33C",], aes(colour="33 C"), method="loess");
p <- p + scale_colour_manual(name="", values=c("blue", "green", "red", "yellow", "purple"));
p <- p + xlab("HPF") + ylab("Predicted HPF");
p <- p + coord_cartesian(xlim = c(4, 18), ylim = c(2, 18));
p <- p + theme_minimal();
p + theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel, legend.position ="bottom");

write.csv(allData, "Fish_Quant.csv");


temp <- allData[allData$type=="control",];
temp12 <- temp[temp$predicted_hpf>11.5 & temp$predicted_hpf < 12.5,];
temp14 <- temp[temp$predicted_hpf>13.5 & temp$predicted_hpf < 14.5,];
temp12 <- temp12[sample(1:nrow(temp12), 50),];
temp14 <- temp14[sample(1:nrow(temp14), 50),];
write.csv(temp12, "pred12hpf.csv");
write.csv(temp14, "pred14hpf.csv");
