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

for(i in seq(from=4.5,to=17.5,by=0.25)){
  allData <- rbind(allData,
                   data.frame(actual_hpf = i / (0.055 * 28.5 - 0.57),
                              prob = (i - 1.5)/17.25,
                              type = "kimmel28.5",
                              original_file = "",
                              slice = -1));
  allData <- rbind(allData,
                   data.frame(actual_hpf = i / (0.055 * 25.0 - 0.57),
                              prob = (i - 1.5)/17.25,
                              type = "kimmel25",
                              original_file = "",
                              slice = -1));
}

#allData <- data.frame(allData, data.frame(logProb = log(allData$prob)));

allData <- allData[allData$actual_hpf < 17.5, ];
allData$predicted_hpf <- allData$prob * 17.25 + 1.5;
write.csv(allData, "Fish_Quant.csv");

hpfs <- seq(from=4.5,to=17.25,by=0.25);

lags <- data.frame(data=matrix(data=0,nrow=length(hpfs),ncol=7));
colnames(lags) <- c("hpf", "control_mean", "control_se", "mean25", "se25", "upper", "lower");


for(i in 1:length(hpfs)){
  a <- allData[(allData$type=="control" | allData$type=="control2")  & allData$actual_hpf==hpfs[i],]
  b <- allData[allData$type=="25C" & allData$actual_hpf==hpfs[i],]
  
  lags$hpf[i] <- hpfs[i];
  lags$control_mean[i] <- mean(a$predicted_hpf);
  lags$control_se[i] <- sd(a$predicted_hpf)/sqrt(length((a$predicted_hpf)));
  lags$mean25[i] <- mean(b$predicted_hpf);
  lags$se25[i] <- sd(b$predicted_hpf)/sqrt(length((b$predicted_hpf)));
  lags$upper[i] <- lags$control_mean[i] + lags$control_se[i] - (lags$mean25[i] - lags$se25[i]);
  lags$lower[i] <- lags$control_mean[i] - lags$control_se[i] - (lags$mean25[i] + lags$se25[i]);
}

axislabel <- element_text(size=18, colour = "black");

p <- ggplot(NULL, aes(actual_hpf, predicted_hpf));
p <- p + geom_jitter(data=allData[allData$type=="control",], color=c("green"));
p <- p + geom_jitter(data=allData[allData$type=="control2",], color=c("red"));
p <- p + geom_jitter(data=allData[allData$type=="25C",], color=c("blue"));
p <- p + geom_jitter(data=allData[allData$type=="kimmel28.5",], color=c("black"));
p <- p + geom_jitter(data=allData[allData$type=="kimmel25",], color=c("black"));
p <- p + xlab("Actual HPF") + ylab("Predicted HPF");
p <- p + coord_cartesian(xlim = c(4, 18), ylim = c(2, 18));
p <- p + theme_minimal();
p + theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel);

p <- ggplot(NULL, aes(actual_hpf, predicted_hpf));
p <- p + geom_smooth(data=allData[allData$type=="control",], aes(colour="WT (rep. 1)"), method="loess");
p <- p + geom_smooth(data=allData[allData$type=="control2",], aes(colour="WT (rep. 2)"), method="loess");
p <- p + geom_smooth(data=allData[allData$type=="25C",], aes(colour="WT (25 C)"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="lag",], aes(colour="lag"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="kimmel28.5",], aes(colour="kimmel28.5"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="kimmel25",], aes(colour="kimmel25"), method="loess");
#p <- p + geom_smooth(data=allData[allData$type=="33C",], aes(colour="33 C"), method="loess");
p <- p + scale_colour_manual(name="", values=c("blue", "green", "red", "yellow", "purple"));
p <- p + xlab("HPF") + ylab("Predicted HPF");
p <- p + coord_cartesian(xlim = c(4, 18), ylim = c(2, 18));
p <- p + theme_minimal();
p + theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel, legend.position ="bottom");
