//measures the difference between each timepoint n and n+1 for the previously created stacks

//--------------change these variables---------------

//which pixelsize in x and y is present?
pixelsize = 2048;

//--------------nothing has to be changed from here on---------------

setBatchMode(true);

  //Directory choosing dialog
  dir = getDirectory("Choose a Directory ");
  // iterating over stacks
  stack_iterator(dir);  



function stack_iterator(dir){
	//get the file list of the directory and iterate over it
	list = getFileList(dir);
    	for (i=0; i<list.length; i++) {
			//exclude wrong files
    		if (!endsWith(list[i], "_MAX.tif")){
    			if (!endsWith(list[i], "_AVG.tif")){
    				if (!endsWith(list[i], "_STD.tif")){
    					if (endsWith(list[i], ".tif")){
						//open stack
    					open(dir+list[i]);
    					stringlength = lengthOf(list[i]);
    					run("Duplicate...", "duplicate");
						//create two empty slices
    					newImage("Untitled", "16-bit black", pixelsize, pixelsize, 1);
    					newImage("Untitled2", "16-bit black", pixelsize, pixelsize, 1);
						//add the slice once to the beginning and once to the end of the stack
    					run("Concatenate...", "  title=[Stackblack] image1=" + list[i] + " image2=Untitled");
    					run("Concatenate...", "  title=[Blackstack] image1=Untitled2 image2=" + substring(list[i],0,(stringlength-4)) + "-1.tif");
						//take the difference of both stacks. Yields the difference between timepoint n and n+1
    					imageCalculator("Difference create 32-bit stack", "Stackblack","Blackstack");
						//remove the first and the last slice, since these will not have any valuable information due to the empty slices
    					run("Slice Remover", "first=1 last=1 increment=1");
    					run("Slice Remover", "first=" + nSlices + " last=" + nSlices + " increment=1");
						//square the result to enhance differences between the stacks
    					imageCalculator("Multiply create stack", "Result of Stackblack", "Result of Stackblack");
						//measure the stack and close everything
    					measure_stack(dir+list[i]);
						closeallwindows();
    					}
    				}
    			}
    		}
    	}
}


// Measure Stack
//
// This macro measure all the slices in a stack and saves a .xls file with the same name

  function measure_stack(filename) {
       saveSettings;
       stringlength = lengthOf(filename);
       setOption("Stack position", true);
       for (n=1; n<=nSlices; n++) {
          setSlice(n);
          run("Measure");
      }
      saveAs("Results", substring(filename,0,(stringlength-4)) +".xls");
      run("Clear Results");
      restoreSettings;
  }


  function closeallwindows() { 
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
  }  

setBatchMode(false);
