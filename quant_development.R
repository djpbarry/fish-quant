library(ggplot2);

wtDir1 <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.07.30_FishDev_WT_02_3/obj_probs";
wtDir2 <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.07.30_FishDev_WT_01_1/obj_probs";
wt25Dir <- "Z:/working/barryd/Working_Data/Smith/rebecca/outputs/2020.08.04_FishDev_WT_25C_1/obj_probs";

hpfOffset <- 4.5;
framesToHpf <- 0.25;

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
  if(grepl("02_3", f)){
    exp <- "control2";
  }
  
  data <- read.table(f);
  developed <- subset(data, !grepl("unhatched", data$Label));
  allData <- rbind(allData,
                   data.frame(actual_hpf = hpfOffset + (framesToHpf * (developed$Slice - 1)),
                              prob = developed$Mean,
                              type = exp));
}

#allData <- data.frame(allData, data.frame(logProb = log(allData$prob)));

allData <- allData[allData$actual_hpf < 17.5, ];
allData$predicted_hpf <- allData$prob * 17.25 + 1.5;

axislabel <- element_text(size=18, colour = "black");

p <- ggplot(NULL, aes(actual_hpf, predicted_hpf));
p <- p + geom_jitter(data=allData[allData$type=="control2",], color=c("green"));
p <- p + geom_jitter(data=allData[allData$type=="25C",], color=c("red"));
p <- p + xlab("Actual HPF") + ylab("Predicted HPF");
p <- p + coord_cartesian(xlim = c(4, 18), ylim = c(4, 18));
p <- p + theme_minimal();
p + theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel);

p <- ggplot(allData, aes(actual_hpf, predicted_hpf));
p <- p + geom_smooth(method='lm', formula='y ~ poly(x, 2)');
p <- p + xlab("Actual HPF") + ylab("Predicted HPF");
p <- p + coord_cartesian(xlim = c(4, 18), ylim = c(4, 18));
p <- p + theme_minimal();
p + theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel);
