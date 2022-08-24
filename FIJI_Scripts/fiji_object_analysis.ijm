unhatched = "unhatched";
hatched = "hatched";
unhatched_mask = unhatched+"_mask";
hatched_mask = hatched+"_mask";
file = getArgument();
//file = "Z:\\working\\barryd\\Working Data\\Smith\\rebecca\\outputs\\obj_probs\\Hatching V1-0_1_MMStack_A2-Site_0.ome_Object Probabilities.tiff";

//shorterFileName = substring(file, lastIndexOf(file, "/") + 1, indexOf(file, "Object Predictions"));

//directory = getDirectory("Choose a Directory");

setBatchMode(true);

processFile(file);

//files = getFileList(directory);

//for(i = 0; i < files.length; i++){
	//if(endsWith(files[i], "tiff")){
		//processFile(files[i]);
	//}
//}

//run("Image Sequence...", "open=[" + file + "] file=[" + shorterFileName + "] sort");

setBatchMode(false);

exit();

function processFile(file){

	open(file);
	
	if(nSlices() % 2 > 0){
		Stack.setSlice(nSlices());
		run("Delete Slice");
	}
	
	run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=1 frames="+nSlices()/2+" display=Color");
	run("Split Channels");
	
	windows = getList("image.titles");
	
	setOption("BlackBackground", false);
	
	for(i = 0; i < windows.length; i++){
		if(startsWith(windows[i], "C1")){
			selectWindow(windows[i]);
			rename(unhatched);
			run("Duplicate...", "title="+unhatched_mask+" duplicate");
			setThreshold(0.01, 1.0);
			run("Convert to Mask", "background=Dark");
		}else if(startsWith(windows[i], "C2")){
			selectWindow(windows[i]);
			rename(hatched);
			run("Duplicate...", "title="+hatched_mask+" duplicate");
			setThreshold(0.01, 1.0);
			run("Convert to Mask", "background=Dark");
		}
	}
	
	run("Set Measurements...", "area mean stack display redirect="+unhatched+" decimal=3");
	selectWindow(unhatched_mask);
	run("Analyze Particles...", "size=100000-Infinity display stack");
	
	run("Set Measurements...", "area mean stack display redirect="+hatched+" decimal=3");
	selectWindow(hatched_mask);
	run("Analyze Particles...", "size=100000-Infinity display stack");
	
	close("*");
	
	outputfilename = substring(file, lastIndexOf(file, File.separator), lengthOf(file));
	
	saveAs("Results", substring(file, 0, lastIndexOf(file, File.separator)) + File.separator + outputfilename + "_results.txt");

	//saveAs("Results", directory + File.separator + file + "_results.txt");
	
	run("Clear Results");
}
