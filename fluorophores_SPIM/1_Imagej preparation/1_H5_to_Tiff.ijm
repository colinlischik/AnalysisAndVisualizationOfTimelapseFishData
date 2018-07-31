//recursively calls all .h5 files in all subdirectories of the chosen directory.
//Files are opended, corrected for anisotropy values and resaved as tiff
//This is only necessary if files are present in .h5 format
//Depending on the microscope type there might be the need for adjustments

//--------------change these variables---------------

//set VoxelSize in x and y
voxelSize = 0.406;
//set used units
unit = "um";

//--------------nothing has to be changed from here on---------------

setBatchMode(true);

  //Directory choosing dialog
  dir = getDirectory("Choose a Directory ");
  //calling of recursive function
  convertFiles(dir); 

  function convertFiles(dir) {
     list = getFileList(dir);
	 //iterate over the filelist
     for (i=0; i<list.length; i++) {
     	//if file is a folder recall function
        if (endsWith(list[i], "/"))
           convertFiles(""+dir+list[i]);
        else
        //if it is a file, check, if it is an .h5 file and convert
           if (endsWith(list[i], ".h5")){
           		// print the current filename as progress report
           		print(dir + list[i]);
           		print(i);
           		//loading the File
           		run("Scriptable load HDF5...", "load=["+ dir + list[i] +"] datasetnames=/Data nframes=1 nchannels=1");
           		// get the Pixelsize 
				getPixelSize(dummy, zsize, ysize, xsize);
				// get all dimension for setting properties
				getDimensions(dummy, dummy, channels, slices, frames);
				// set properties accordingly
				run("Properties...", "channels=" + channels + " slices=" + slices + " frames=" + frames + " unit=" + unit + " pixel_width=" + voxelSize + " pixel_height=" + voxelSize + " voxel_depth=" + zsize +"");
				// resave file as tiff and close
				stringlength = lengthOf(list[i]);
				saveAs("Tiff", dir + substring(list[i],0,(stringlength-3)) + ".tif");
				closeallwindows();
            	run("Collect Garbage");
           }
     }
  }

 function closeallwindows() { 
	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
    } 
}  
setBatchMode(false);
