//Files have to be present in the format: 
//<well>/<timestep>.tif
//This script will then concatenate all timesteps of one well to a single stack
//Furthermore, it will create a movie, an average, std and max projection along t for each well

//--------------nothing has to be changed from here on---------------

setBatchMode(true);

  //Directory choosing dialog
  dir = getDirectory("Choose a Directory ");
  //calling of concatenation function
  makeStacks(dir); 


  function makeStacks(dir) {
	//get all folders in the directory
    list = getFileList(dir);
    //create all needed folders
	File.makeDirectory(dir + "videos/");
    File.makeDirectory(dir + "stacks/");
    File.makeDirectory(dir + "AVG/");
    File.makeDirectory(dir + "STD/");
    File.makeDirectory(dir + "MAX/");
    
	//iterate over the folders
    for (i=0; i<list.length; i++) {
     	//if file is a folder list all files in folder
        if (endsWith(list[i], "/")){
           list2 = getFileList(dir+list[i]);

           // get current system time and display with folder in use for debugging
           getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     	   print(hour + ":" + minute + ":" + second);
           print("current folder in use:" + list[i]);
           // open images in folder as stack
           print(dir + list[i] + list2[0]);
       	   run("Image Sequence...", "open="+dir+list[i]+list2[0]+" sort");
       	   // get length of filename
       	   stringlength = lengthOf(list[i]);
       	   // save stack as .avi video
       	   run("AVI... ", "compression=JPEG frame=30 save="+ dir + "videos/" + substring(list[i],0,(stringlength-1)) +".avi");
       	   // save stack raw data as .tif
       	   saveAs("Tiff", dir + "stacks/" + substring(list[i],0,(stringlength-1)) + ".tif");
       	   // average intensity projection and saving projection
       	   run("Z Project...", "projection=[Average Intensity]");
       	   run("Save", "save="+ dir + "AVG/" + substring(list[i],0,(stringlength-1)) +"_AVG.tif");
       	   close();
       	   // average standard deviation projection and saving projection
       	   run("Z Project...", "projection=[Standard Deviation]");
       	   run("Save", "save="+ dir + "STD/" +substring(list[i],0,(stringlength-1)) +"_STD.tif");
       	   close();
       	   // average maximum intensity projection and saving projection
       	   run("Z Project...", "projection=[Max Intensity]");
       	   run("Save", "save="+ dir + "MAX/" +substring(list[i],0,(stringlength-1)) +"_MAX.tif");
       	   close();
       	   close();
        }   
     }
  }
setBatchMode(false);
