// Crops the present images by automatically selecting the embryo by fluorescence
// Both channels will be masked by both channels. Yielding 4 different results.
// Image folder structure needs to be:
// /<well_identifier>/<channel>/<timestep>/<zslice>--<other information>.tif

//--------------change these variables---------------
  
  //what are the names of the present channels?
  firstchannel = "CO3";
  secondchannel = "CO4";
  //how is the beginning of the first zslice named?
  first_zslice_name = "001";

//--------------nothing has to be changed from here on---------------

setBatchMode(true);

  //Directory choosing dialog
  dir_uncropped = getDirectory("Choose a Directory which harbours the images");
  dir_cropped = getDirectory("Choose a Directory to store the cropped images");

  //calling of recursive function to crop the pictures by the different channels
  cropStacks(dir_uncropped); 
  
  //This function crops the stacks and saves them in the same folder structure.
  function cropStacks(dir) {
	 //Get the file list of the directory
     list = getFileList(dir);
	 //Iterate through the file list
     for (i=0; i<list.length; i++) {
     	//if file is a .tif stack and the first z slice open and measure
        if (endsWith(list[i], ".tif") & startsWith(list[i], first_zslice_name)){
        		
        	// print the current directory as progress report
           	print("current directory:" + dir);
           	// get current system time and display with folder in use for debugging
           	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     	   	print(hour + ":" + minute + ":" + second);
			
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
				
			//Cropping is done for both channels simultaneously, so the second one is skipped
			if (channel != firstchannel){
				print("Skipped: the second channel is skipped, all cropping is done in the first channel");
				continue;
			}

			//If is is the first channel find the corresponding image in the second channel:
			dir2 = File.getParent(channelpath);
			dir2 = dir2 + "/" + secondchannel;
			//adding the loop
			dir2 = dir2 + "/" + loop + "/";

			//opening one stack of each channel
			run("Image Sequence...", "open=[" + dir + "] sort");
			rename("firstchannel_original");
			run("Image Sequence...", "open=[" + dir2 + "] sort");
			rename("secondchannel_original");

           	//thresholding both channels with information from the first channel
           	selectWindow("firstchannel_original");
			//threshold a copy of the first channel
           	run("Duplicate...", "duplicate");
			run("Auto Threshold", "method=Otsu white stack");
			rename("firstchannel_mask");
			//create a binary from the mask
			run("Duplicate...", "duplicate");
			run("Divide...", "value=255 stack");
			rename("firstchannel_binary");
			//mask both channels by the binary mask
			imageCalculator("Multiply create stack", "firstchannel_original", "firstchannel_binary");
			rename("firstchannel_firstmask");
			imageCalculator("Multiply create stack", "secondchannel_original", "firstchannel_binary");
			rename("secondchannel_firstmask");

			//thresholding both channels with information from the second channel
			selectWindow("secondchannel_original");
			//threshold a copy of the first channel
           	run("Duplicate...", "duplicate");
			run("Auto Threshold", "method=Otsu white stack");
			rename("secondchannel_mask");
			//create a binary from the mask
			run("Duplicate...", "duplicate");
			run("Divide...", "value=255 stack");
			rename("secondchannel_binary");
			//mask both channels by the binary mask
			imageCalculator("Multiply create stack", "firstchannel_original", "secondchannel_binary");
			rename("firstchannel_secondmask");
			imageCalculator("Multiply create stack", "secondchannel_original", "secondchannel_binary");
			rename("secondchannel_secondmask");

			//create cropping mask for the first channel
			selectWindow("firstchannel_mask");
			run("Z Project...", "projection=[Max Intensity]");
			run("Make Binary");
			run("Create Selection");

			//crop both channels with first mask
			selectWindow("firstchannel_firstmask");
			run("Restore Selection");
			selectWindow("secondchannel_firstmask");
			run("Restore Selection");
			run("Crop");
			width1 = getWidth;
			height1 = getHeight;
			selectWindow("firstchannel_firstmask");
			run("Crop");
			width2 = getWidth;
			height2 = getHeight;

			//ensure the same dimensions in both images
			width = width1 - width2;
			height = height1 - height2;
			
			//This is only for troubleshooting, it should never be different dimensions!
			if ((width != 0) | (height != 0)){
				print("cropped images have different dimensions! (channel 1)");
			} else {
				print("cropped images have the same dimensions (channel 1)");
			}

			//create cropping mask for second channel
			selectWindow("secondchannel_mask");
			run("Z Project...", "projection=[Max Intensity]");
			run("Make Binary");
			run("Create Selection");

			//crop both channels with second mask
			selectWindow("firstchannel_secondmask");
			run("Restore Selection");
			selectWindow("secondchannel_secondmask");
			run("Restore Selection");
			run("Crop");
			width1 = getWidth;
			height1 = getHeight;
			selectWindow("firstchannel_secondmask");
			run("Crop");
			width2 = getWidth;
			height2 = getHeight;

			//ensure the same dimensions in both images
			width = width1 - width2;
			height = height1 - height2;
			
			//This is only for troubleshooting, it should never be different dimensions!
			if ((width != 0 ) | (height != 0)){
				print("cropped images have different dimensions! (channel 2)");
			} else {
				print("cropped images have the same dimensions (channel 2)");
			}

			//creating the directories for saving the cropped images
			savingdirectory1 = dir_cropped + "/" + well + "/" + firstchannel + "_" + firstchannel + "mask/";
			savingdirectory2 = dir_cropped + "/" + well + "/" + secondchannel + "_" + firstchannel + "mask/";
			savingdirectory3 = dir_cropped + "/" + well + "/" + firstchannel + "_" + secondchannel + "mask/";
			savingdirectory4 = dir_cropped + "/" + well + "/" + secondchannel + "_" + secondchannel + "mask/";
			File.makeDirectory(File.getParent(savingdirectory1));
			File.makeDirectory(savingdirectory1);
			File.makeDirectory(savingdirectory2);
			File.makeDirectory(savingdirectory3);
			File.makeDirectory(savingdirectory4);

			//save results
			selectWindow("firstchannel_firstmask");
			run("Save", "save=[" + savingdirectory1 + loop + ".tif]");
			selectWindow("secondchannel_firstmask");
			run("Save", "save=[" + savingdirectory2 + loop + ".tif]");
			selectWindow("firstchannel_secondmask");
			run("Save", "save=[" + savingdirectory3 + loop + ".tif]");
			selectWindow("secondchannel_secondmask");
			run("Save", "save=[" + savingdirectory4 + loop + ".tif]");

			//close all open windows and clean RAM
			closeallwindows();
			run("Collect Garbage");
			
           } else if (endsWith(list[i], "/")) { //if list element is a folder recall function
           		cropStacks(""+dir+list[i]);
           }// if folder
     }//for iterating through the file list
  }//function cropStacks(dir)

  
// Function to close all windows
function closeallwindows() { 
	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
    } 
}  
setBatchMode(false);