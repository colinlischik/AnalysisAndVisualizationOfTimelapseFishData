//Divides channel 1 by channel 2 and vice versa
//saves the result in the chosen folder as a measurement

//--------------change these variables---------------

//what are the names of the present channels?
firstchannel = "Stack_0_Channel_0";
secondchannel = "Stack_0_Channel_1";
//overwrite existing csvs?
overwrite = true;

//--------------nothing has to be changed from here on---------------


setBatchMode(true);

  //choose image path
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
				
				//which channel and which loop is this?
				looppath = dir+list[i];
				loop = substring(list[i], 0, lengthOf(list[i]) - 4);
				print("loop number: "+ loop);
				channelpath = File.getParent(looppath);
				channel = substring(channelpath, lengthOf(File.getParent(channelpath)) + 1, lengthOf(channelpath));
				print("channel: " + channel);
				//which well is this?
				well = File.getParent(channelpath);
				well = substring(well, lengthOf(File.getParent(well)) + 1, lengthOf(well));
				print("well number: " + well);
				desiredchannel = firstchannel;
				
				//only access one channel, specified above
				if (channel != desiredchannel){
					print("skipped, only the first folder is used to do all calculations");
					continue;
				}

				//if it has been the right folder find the corresponding images
				//finding other images
				corrPath = File.getParent(channelpath);
				corrPath2 = corrPath + "/" + secondchannel + "/" + loop + ".tif";
				
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
        		
           		//loading the Files and create masks
           		print(dir + list[i]);
           		open(dir + list[i]);
           		rename("firstchannel");
           		run("Duplicate...", "duplicate");
				run("Auto Threshold", "method=Otsu white stack");
				rename("first mask");
				run("Divide...", "value=255 stack");
           		print(corrPath2);
           		open(corrPath2);
           		rename("secondchannel");
           		run("Duplicate...", "duplicate");
				run("Auto Threshold", "method=Otsu white stack");
				rename("second mask");
				run("Divide...", "value=255 stack");

				//create masked stacks
				imageCalculator("Multiply create stack", "firstchannel", "first mask");
				rename("first_first");
				imageCalculator("Multiply create stack", "firstchannel", "second mask");
				rename("first_second");
				imageCalculator("Multiply create stack", "secondchannel", "first mask");
				rename("second_first");
				imageCalculator("Multiply create stack", "secondchannel", "second mask");
				rename("second_second");
				
				
           		//divide firstchannel by secondchannel
           		imageCalculator("Divide create 32-bit stack", "first_second", "second_second");

				//measure
           		run("Clear Results");
           		for (n=1; n<=nSlices; n++) {
         			setSlice(n);
          			run("Measure");
      			}
           		///creating the needed folders and saving
           		resultdirectory = resultsdir + "/" + well + "/" + firstchannel + "_by_" + secondchannel + "/" + loop + ".csv";
           		File.makeDirectory(File.getParent(File.getParent(resultdirectory)));
           		File.makeDirectory(File.getParent(resultdirectory));
           		saveAs("Results", resultdirectory);
           		
           		//divide secondchannel by firstchannel
           		imageCalculator("Divide create 32-bit stack", "second_first", "first_first");

				//measure
           		run("Clear Results");
           		for (n=1; n<=nSlices; n++) {
         			setSlice(n);
          			run("Measure");
      			}
           		///creating the needed folders and saving
           		resultdirectory = resultsdir + "/" + well + "/" + secondchannel + "_by_" + firstchannel + "/" + loop + ".csv";
           		File.makeDirectory(File.getParent(File.getParent(resultdirectory)));
           		File.makeDirectory(File.getParent(resultdirectory));
           		saveAs("Results", resultdirectory);
           		
           		//close all windows
				closeallwindows();
				run("Collect Garbage");
           } else if (endsWith(list[i], "/")) { //if list element is a folder recall function
           		measureStacks(dir+list[i]);
           }// if folder
     }//for
  }

function closeallwindows() { 
	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
    } 
}  
setBatchMode(false);
