filterRadius = 5.0;
delimiter = ",";

arg = getArgument();

args = split(arg, delimiter);
file = args[0];
inputDir = args[1];
outputDir = args[2];
finalOutputSize = args[3];

setBatchMode(true);

processFile(file);

setBatchMode(false);

exit();



function processFile(file){

	print("Opening " + file);
	open(inputDir + File.separator + file);
	original = getTitle();
	getDimensions(width, height, channels, slices, frames);
	print("Making substack...");
	run("Make Substack...", "  slices=3-" + slices + "-3");
	substack = getTitle();
	getDimensions(width, height, channels, slices, frames);
	print("Converting...");
	run("32-bit");
	print("Filtering...");
	for (i = 0; i < filterRadius; i++) {
		run("Smooth", "stack");
	}
	setAutoThreshold("Default dark stack");
	setOption("BlackBackground", false);
	print("Thresholding...");
	run("Convert to Mask", "method=Default background=Dark");
	print("Removing edge objects...");
	run("Analyze Particles...", "  show=Masks exclude stack");
	rename("Edge Filtered");
	edgeFiltered = getTitle();
	print("Duplicating...");
	run("Duplicate...", "duplicate");
	rename("Dup Edge Filtered");
	dupEdgeFiltered = getTitle();
	print("Filling holes...");
	run("Fill Holes", "stack");
	rename("Filled");
	filled = getTitle();
	run("Duplicate...", "duplicate");
	run("Options...", "iterations=50 count=1 do=Erode stack");
	rename("Eroded");
	eroded = getTitle();
	imageCalculator("Difference create stack", filled, eroded);
	rename("Edge Mask");
	edgeMask = getTitle();
	imageCalculator("Subtract create stack", edgeFiltered, edgeMask);
	rename("Difference Image");
	diffImage = getTitle();
	print("Filling holes again...");
	run("Fill Holes", "stack");
	print("Removing artifacts...");
	run("Analyze Particles...", "size=300000-Infinity circularity=0.50-1.00 show=Masks stack");
	print("Pruning...");
	run("Options...", "iterations=10 count=1 do=Open stack");
	result = getTitle();
	setSlice(slices);
	while(slices < finalOutputSize){
		run("Add Slice");
		slices++;
	}
	print("Saving output...");
	run("Properties...", "channels=1 slices=1 frames=" + slices + " pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	saveAs("Tiff", outputDir + File.separator + file + "_Binary.tiff");
	close("*");
	print("Done.");
}
