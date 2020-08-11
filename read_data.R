#koDirectory <- "Z:/working/barryd/hpc/rebecca/outputs/ko_results";
wtDirectory <- "C:/Users/Dave/Desktop/fq";

probThresh <- 0.5;
maxN <- 71;

#koFramesToHpf <- 5;
wtFramesToHpf <- 7;

#koFiles <- list.files(koDirectory);
wtFiles <- list.files(wtDirectory);

allHatched <- data.frame();
allUnhatched <- data.frame();

hatchTimes <- list(data.frame(), data.frame());

# for(f in koFiles){
#   data <- read.table(file.path(koDirectory, f));
#   unhatched <- subset(data, grepl("unhatched", data$Label));
#   probs <- unhatched$Mean;
#   slices <- unhatched$Slice;
#   n <- nrow(unhatched);
#   r <- 1;
#   while(r <= n && probs[r] > probThresh){
#     r <- r + 1;
#   }
#   if(r > n){
#     r <- n;
#   }
#   if(unhatched$Slice[r] < maxN){
#     hpf <- unhatched$Slice[r] + koFramesToHpf + 1;
#     hatchTimes[1] <- rbind(hatchTimes[1], data.frame(koHatchTime=hpf));
#   }
#   #allHatched <- rbind(allHatched, subset(data, !grepl("unhatched", data$Label)));
#   #allUnhatched <- rbind(allUnhatched, subset(data, grepl("unhatched", data$Label)));
# }

for(f in wtFiles){
  data <- read.table(file.path(wtDirectory, f));
  unhatched <- subset(data, grepl("unhatched", data$Label));
  probs <- unhatched$Mean;
  slices <- unhatched$Slice;
  n <- nrow(unhatched);
  r <- 1;
  while(r <= n && probs[r] > probThresh){
    r <- r + 1;
  }
  if(r > n){
    r <- n;
  }
  if(unhatched$Slice[r] < maxN){
    hpf <- unhatched$Slice[r] + wtFramesToHpf + 1;
    hatchTimes[2] <- rbind(hatchTimes[2], data.frame(wtHatchTime=hpf));
    print(paste(f, ":", unhatched$Slice[r]));
  }
  #allHatched <- rbind(allHatched, subset(data, !grepl("unhatched", data$Label)));
  #allUnhatched <- rbind(allUnhatched, subset(data, grepl("unhatched", data$Label)));
}

#koh <- hist(hatchTimes[[1]], freq = TRUE, main="", ylab="Number of Embryos",xlab="Hatch Time (hpf)", breaks=seq(from = 0, to = 80, by = 2));
wth <- hist(hatchTimes[[2]], freq = TRUE, breaks=seq(from = 0, to = 80, by = 2));

plot(wth$mids, wth$counts, type="l", col="green", ylab="Number of Embryos",xlab="Hatch Time (hpf)", xlim=c(0,80), lwd = 3);
#lines(koh$mids, koh$counts, col="red", lwd = 3)
#legend("topright", c("WT", "KO"), fill=c("green","red"));

# Calculate Average

#slices <- unique(allHatched$Slice);

#summary <- data.frame();

#for(s in slices){
#  currentHatchedSlice <- subset(allHatched, allHatched$Slice == s);
#  meanHatched <- mean(currentHatchedSlice$Mean);
#  currentUnhatchedSlice <- subset(allUnhatched, allUnhatched$Slice == s);
#  meanUnhatched <- mean(currentUnhatchedSlice$Mean);
#  summary <- rbind(summary, data.frame(Slice=s, Hatched=meanHatched, Unhatched=meanUnhatched));
#}

#plot(summary$Slice, summary$Unhatched, ylim=c(0,1));
#points(summary$Slice, summary$Hatched);
