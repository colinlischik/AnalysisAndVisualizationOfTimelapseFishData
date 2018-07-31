//Measures the cropped images
//saves the result in the chosen folder as a measurement


//--------------change these variables---------------

//overwrite existing csvs?
overwrite = true;
//what are the names of the present channels?
firstchannel = "CO3";
secondchannel = "CO4";

//--------------nothing has to be changed from here on---------------

setBatchMode(true);

  //Directory choosing dialog
  dir = getDirectory("Choose a Directory which harbours the images");
  //choose results directory
  resultsdir = getDirectory("Choose a Directory for saving the results");
  //calling of recursive function
  measureStacks(dir); 


  function measureStacks(dir) {
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
     	//if file is a .tif stack open and measure
        if (endsWith(list[i], ".tif")){
        		
        	// print the current filename as progress report
           	print("current file:" + dir + list[i]);
           	print("current loop:" + i);
           	// get current system time and display with folder in use for debugging
           	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     	   	print(hour + ":" + minute + ":" + second);
     	   		
        	//determine length of list entry
        	stringlength = lengthOf(list[i]);
			
			//Get the loop, channel and well paths
			looppath = File.getParent(dir+list[i]);
			channelpath = File.getParent(looppath);
			wellpath = File.getParent(channelpath);
			
			//Get the loop, channel and well identifiers
			loop = substring(looppath, lengthOf(channelpath), lengthOf(looppath));
			print("loop number: "+ loop);
			channel = substring(channelpath, lengthOf(wellpath), lengthOf(channelpath));
			print("channel: " + channel);
			well = substring(wellpath, lengthOf(File.getParent(wellpath)), lengthOf(wellpath));
			print("well number: " + well);
			
			desiredchannel = firstchannel + "_" + firstchannel + "mask";
				
			//measurements are all performed after opening the first channel masked by the first channel
			//Therefore, every other channel will be skipped
			if (channel != desiredchannel){
				print("Skipped: calculations for this channel have already been performed");
				continue;
			}

			//if it has been the right folder find the corresponding images
			//finding other images
			corrPath = File.getParent(channelpath);
			corrPath2 = corrPath + "/" + firstchannel + "_" + secondchannel + "mask" + "/" + loop + ".tif";
			corrPath3 = corrPath + "/" + secondchannel + "_" + firstchannel + "mask" + "/" + loop + ".tif";
			corrPath4 = corrPath + "/" + secondchannel + "_" + secondchannel + "mask" + "/" + loop + ".tif";
				
        	//if csvs should be not overwritten the existing ones should be skipped
        	if (overwrite == false){
        		//if it is not the last list element compare the name and continue to next loop if the same
        		if (i+1 < list.length)
        			if (substring(list[i],0,(stringlength-3)) == substring(list[i+1],0,(stringlength-3))){
        				print("skipped: next element the same name");
        				continue;
        			}
        		//if it is not the first list element compare the name and continue to next loop if the same
        		if (i-1 >= 0)
        			if (substring(list[i],0,(stringlength-3)) == substring(list[i-1],0,(stringlength-3))){
        				print("skipped: previous element the same name");
        				continue;
        			}
        	}// fi overwrite
        		
           	//loading the Files, measuring them directly and saving the results
           	//1
           	print(dir + list[i]);
           	open(dir + list[i]);
           	rename("firstchannel_firstmask");
           	run("Select None");
           	run("Clear Results");
           	for (n=1; n<=nSlices; n++) {
         		setSlice(n);
          		run("Measure");
      		}
      		resultdirectory = resultsdir + "/" + well + "/" + firstchannel + "_" + firstchannel + "mask/" + loop + ".csv";
           	File.makeDirectory(File.getParent(File.getParent(resultdirectory)));
           	File.makeDirectory(File.getParent(resultdirectory));
           	saveAs("Results", resultdirectory);

           	//2
           	print(corrPath2);
           	open(corrPath2);
           	rename("firstchannel_secondmask");
           	run("Select None");
           	run("Clear Results");
           	for (n=1; n<=nSlices; n++) {
         		setSlice(n);
          		run("Measure");
      		}
      		resultdirectory = resultsdir + "/" + well + "/" + firstchannel + "_" + secondchannel + "mask/" + loop + ".csv";
           	File.makeDirectory(File.getParent(File.getParent(resultdirectory)));
           	File.makeDirectory(File.getParent(resultdirectory));
           	saveAs("Results", resultdirectory);

           	//3
           	print(corrPath3);
           	open(corrPath3);
           	rename("secondchannel_firstmask");
           	run("Select None");
           	run("Clear Results");
           	for (n=1; n<=nSlices; n++) {
         		setSlice(n);
          		run("Measure");
      		}
      		resultdirectory = resultsdir + "/" + well + "/" + secondchannel + "_" + firstchannel + "mask/" + loop + ".csv";
           	File.makeDirectory(File.getParent(File.getParent(resultdirectory)));
           	File.makeDirectory(File.getParent(resultdirectory));
           	saveAs("Results", resultdirectory);

           	//4
           	print(corrPath4);
           	open(corrPath4);
           	rename("secondchannel_secondmask");
           	run("Select None");
           	run("Clear Results");
           	for (n=1; n<=nSlices; n++) {
         		setSlice(n);
          		run("Measure");
      		}
      		resultdirectory = resultsdir + "/" + well + "/" + secondchannel + "_" + secondchannel + "mask/" + loop + ".csv";
           	File.makeDirectory(File.getParent(File.getParent(resultdirectory)));
           	File.makeDirectory(File.getParent(resultdirectory));
           	saveAs("Results", resultdirectory);
           	
           	//close all windows
			closeallwindows();
			run("Collect Garbage");
           } else if (endsWith(list[i], "/")) { //if list element is a folder recall function
           		measureStacks(dir+list[i]);
           }// if folder
     }//for iterating through the folder content
  }// function

function closeallwindows() { 
	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
    } 
}  
setBatchMode(false);
