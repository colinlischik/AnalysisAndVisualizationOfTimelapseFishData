//opens two timepoints of one well at a time to check for fluorescence and death
//works on the folder, which includes the wells
//needs the same folder structure as in the first script, but since it is already established it can be used directly


//--------------change these variables---------------

//what are the names of the present channels?
firstchannel = "CO3";
secondchannel = "CO4";
//which timepoint should be shown additionally to the last? Unit is percent
timepoint = 0.75;

//--------------nothing has to be changed from here on---------------

//Directory choosing dialog
dir = getDirectory("Choose a Directory which harbours the wells to be checked");
//calling of checking function
openStacks(dir); 


  function openStacks(dir) {
	//get a list of all files
    list = getFileList(dir);
	//prepare the results table
    print("ID,well,positive");
	     
    //iterate over well folders
    for (i=0; i<list.length; i++) {
		//open the last loop and the loop after half of the timepoints for the first channel
		//how many loops are there?
     	looplist = getFileList(dir + list[i] + firstchannel + "/");
     	halfloop = dir + list[i] + firstchannel + "/" + looplist[(looplist.length % (1 / timepoint))];
     	lastloop = dir + list[i] + firstchannel + "/" + looplist[looplist.length - 1];
     	run("Image Sequence...", "open=[halfloop] sort");
     	rename("firstchannel_timepoint_n");
     	run("Image Sequence...", "open=[lastloop] sort");
     	rename("firstchannel_timepoint_last");

     	//open the last loop and the loop after half of the timepoints for the second channel
     	looplist = getFileList(dir + list[i] + secondchannel + "/");
     	halfloop = dir + list[i] + secondchannel + "/" + looplist[(looplist.length % (1 / timepoint))];
     	lastloop = dir + list[i] + secondchannel + "/" + looplist[looplist.length - 1];
     	run("Image Sequence...", "open=[halfloop] sort");
     	rename("secondchannel_timepoint_n");
     	run("Image Sequence...", "open=[lastloop] sort");
     	rename("secondchannel_timepoint_last");

     	//combine stacks as an overview
     	run("Combine...", "stack1=firstchannel_timepoint_n stack2=secondchannel_timepoint_n");
     	rename("first");
     	run("Combine...", "stack1=firstchannel_timepoint_last stack2=secondchannel_timepoint_last");
     	rename("second");
     	run("Combine...", "stack1=first stack2=second combine");
     	rename("final");
     	
     	//play through z slices
		doCommand("Start Animation");

		//prompt to enter whether the embryo is fluorescent
		positive = getNumber("is the embryo fluorescent?", 1);
     	
     	//set Value depending on keyboard entry
     	print(i + "," + substring(list[i], 0, lengthOf(list[i]) - 1) + "," + positive);

     	//close image
     	close;
     }//for
     //saving Results
     saveAs("Text", dir + "positive.csv");
  }//function