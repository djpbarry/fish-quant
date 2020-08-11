wells <- vector();

for(i in 1:12){
  for(j in 1:8){
    wells[(i-1) * 8 + j] <- paste(LETTERS[j], i);
}
}

for(i in 1:1){
  j <- round(runif(1, 1, 96));
  while(grepl("done", wells[j])){
    j <- round(runif(1, 1, 96));
  }
  print(wells[j]);
  wells[j] <- "done";
}