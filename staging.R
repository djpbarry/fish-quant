library(ggplot2)
library(caret)

data <- read.csv('E:/OneDrive - The Francis Crick Institute/Working Data/Smith/Rebecca/StagingResults.csv')
data <- data[!duplicated(paste(data$original_file, data$slice)),];

data$pred <- 0;

data[data$predicted_hpf < 12.5,]$pred <- 12;
data[!data$predicted_hpf < 12.5,]$pred <- 14;

 mod_data <- data.frame(matrix(data=0,ncol=3,nrow=4 * nrow(data)));
 colnames(mod_data) <- c("Staging", "Predicted_As", "Staged_By");
 
 for(i in 1:nrow(data)){
   j <- (i - 1) * 4 + 1;
   mod_data[j, 1] <- data$ï..actual_hpf[i];
   mod_data[j, 2] <- data$pred[i];
   mod_data[j, 3] <- "Actual HPF";
   mod_data[j+1, 1] <- data$MR[i];
   mod_data[j+1, 2] <- data$pred[i];
   mod_data[j+1, 3] <- "MR";
   mod_data[j+2, 1] <- data$RJ[i];
   mod_data[j+2, 2] <- data$pred[i];
   mod_data[j+2, 3] <- "RJ";
   mod_data[j+3, 1] <- data$NH[i];
   mod_data[j+3, 2] <- data$pred[i];
   mod_data[j+3, 3] <- "NH";
 }

 p <- ggplot(mod_data, aes(x=as.factor(Predicted_As), y=Staging, fill=Staged_By)) + geom_boxplot();
 p <- p + xlab("ML Classifier Prediction")
 p

mod_data <- data.frame(matrix(data=0,ncol=4,nrow=nrow(data)));
colnames(mod_data) <- c("Staged_As", "Staging_Error", "Predicted_As", "Actual_HPF");

for(i in 1:nrow(data)){
  mod_data[i, 1] <- mean(c(data$MR[i], data$RJ[i], data$NH[i]));
  mod_data[i, 2] <- sd(c(data$MR[i], data$RJ[i], data$NH[i]));
  mod_data[i, 3] <- data$pred[i];
  mod_data[i, 4] <- data$ï..actual_hpf[i];
}


ggplot(mod_data, aes(y=Staged_As, x=Actual_HPF, color=as.factor(Predicted_As))) +
  geom_point() +
  #geom_linerange(aes(ymin=Staged_As-Staging_Error, ymax=Staged_As+Staging_Error)) +
  scale_color_manual(values=c(blue,orange)) +
  xlab("Actual HPF") + ylab("Staged As") + labs(color = "Predicted As") + 
  theme_minimal();


mod_data <- data.frame(matrix(data=0,ncol=3,nrow=nrow(data)));
colnames(mod_data) <- c("Actual_HPF", "Staging", "Predicted_By");

for(i in 1:nrow(data)){
  j <- (i - 1) * 3 + 1;
  mod_data[j, 1] <- data$ï..actual_hpf[i];
  mod_data[j, 2] <- data$MR[i];
  mod_data[j, 3] <- "Human";
  mod_data[j+1, 1] <- data$ï..actual_hpf[i];
  mod_data[j+1, 2] <- data$RJ[i];
  mod_data[j+1, 3] <- "Human";
  mod_data[j+2, 1] <- data$ï..actual_hpf[i];
  mod_data[j+2, 2] <- data$NH[i];
  mod_data[j+2, 3] <- "Human";
  mod_data[j+2, 1] <- data$ï..actual_hpf[i];
  mod_data[j+2, 2] <- data$predicted_hpf[i];
  mod_data[j+2, 3] <- "Classifier";
}

black <- "#000000";
blue <- "#0000FF";
orange <- "#FF6600";

axislabel <- element_text(hjust=0.5, size=25, colour = "black");

ggplot(mod_data, aes(x=as.factor(Predicted_As), y=Staging, color=Staged_By, fill=Staged_By)) + 
  geom_point(position=position_jitterdodge(dodge.width=1.0),alpha=0.5,size=3) +
  geom_boxplot(width=1.0,color=black,coef=20,alpha=0.0) +
  scale_color_manual(values=c(blue,orange)) +
  #ylim(c(0,100)) +
  theme_linedraw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel, plot.title = axislabel) +
  theme(legend.position = c(0.15, 0.2), legend.title=element_blank()) +
  xlab("Predicted HPF") + ylab("Staging");

ggplot(mod_data, aes(x=Actual_HPF, y=Staging, color=Predicted_By)) +
  geom_point() +
  #geom_linerange(aes(ymin=Staged_As-Staging_Error, ymax=Staged_As+Staging_Error)) +
  scale_color_manual(values=c(blue,orange)) +
  xlab("Actual HPF") + ylab("Staged As") + labs(color = "Predicted As") + 
  theme_linedraw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(legend.text = axislabel, axis.text.y = axislabel, axis.text.x = axislabel, axis.title.x = axislabel, axis.title.y = axislabel, legend.title = axislabel, plot.title = axislabel) +
  theme(legend.position = c(0.12, 0.85), legend.title=element_blank());

###############################################



data <- read.csv('E:/OneDrive - The Francis Crick Institute/Working Data/Smith/Rebecca/StagingResults.csv')
data <- data[data$predicted_hpf < 12.5,];
dups <- duplicated(paste(data$original_file, data$slice));

n <- nrow(data) / 2;

mod_data <- data.frame(matrix(data=0,ncol=3,nrow=3 * n));
colnames(mod_data) <- c("Staging_Difference", "Predicted_As", "Staged_By");
index<-1;
for(i in 1:nrow(data)){
  if(!dups[i]){
    copy <- data[data$original_file == data$original_file[i] & data$slice == data$slice[i],];
    j <- (index - 1) * 3 + 1;
    mod_data[j, 1] <- abs(copy$MR[2] - copy$MR[1]);
    mod_data[j, 2] <- 12;
    mod_data[j, 3] <- "MR";
    mod_data[j+1, 1] <- abs(copy$RJ[2] - copy$RJ[1]);
    mod_data[j+1, 2] <- 12;
    mod_data[j+1, 3] <- "RJ";
    mod_data[j+2, 1] <- abs(copy$NH[2] - copy$NH[1]);
    mod_data[j+2, 2] <- 12;
    mod_data[j+2, 3] <- "NH";
    index<-index+1;
  }
}

p <- ggplot(mod_data, aes(x=as.factor(Staged_By), y=Staging_Difference)) + geom_boxplot();
p <- p + xlab("Staged By")
p


mod_data <- data.frame(matrix(data=0,ncol=5,nrow=nrow(data)));
colnames(mod_data) <- c("Actual_HPF", "Human_Pred", "Classifier_Pred", "Human_Error", "Classifier_Error");

for(i in 1:nrow(data)){
  mod_data[i, 2] <- round(mean(c(data$MR[i], data$RJ[i], data$NH[i])));
  mod_data[i, 3] <- round(data$pred[i]);
  mod_data[i, 1] <- round(data$ï..actual_hpf[i]);
  mod_data[i, 4] <- abs(mod_data[i, 2] - mod_data[i, 1]);
  mod_data[i, 5] <- abs(mod_data[i, 3] - mod_data[i, 1]);
}

levels <- seq(8,18,1)

sum(mod_data$Human_Error)
sum(mod_data$Classifier_Error)

median(mod_data$Human_Error)
median(mod_data$Classifier_Error)

data <- factor(mod_data$Actual_HPF, levels=levels);
human_pred<- factor(mod_data$Human_Pred, levels=levels);
classifier_pred<- factor(mod_data$Classifier_Pred, levels=levels);

cm <- confusionMatrix(classifier_pred, data)

df <- data.frame(cm$table)

ggplot(data =  df, mapping = aes(x = Reference, y = Prediction)) +
  geom_tile(aes(fill = Freq), colour = "white") +
  geom_text(aes(label = sprintf("%1.0f", Freq))) +
  scale_fill_gradient2(low = "blue", mid="grey",high = "orange", midpoint = 16) +
  theme_bw() + theme(legend.position = "none") +
  xlab("Actual HPF") + ylab("Classifier-Predicted HPF")

