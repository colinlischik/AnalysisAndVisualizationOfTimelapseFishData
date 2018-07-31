//creates a montage of all surviving wells.
//list can be exported by R script:

//--------------change these variables---------------
//what are the names of the present channels?
firstchannel = "CO3";
secondchannel = "CO4";
//how many loops should be used?
loops = 68;
//which zslice should be used?
zslice = 5;
//how man wells are being used?
wells = 66;
//how many rows should be created in the montage?
rows = 6;
//how many columns should be created in the montage?
columns = 11;
//String for creating the montage. This can be exported from R
montage = "stack_1=A001-1.tif stack_2=A002-1.tif stack_3=A003-1.tif stack_4=A004-1.tif stack_5=A005-1.tif stack_6=A007-1.tif stack_7=A010-1.tif stack_8=A012-1.tif stack_9=B001-1.tif stack_10=B002-1.tif stack_11=B004-1.tif stack_12=B006-1.tif stack_13=B008-1.tif stack_14=B009-1.tif stack_15=B011-1.tif stack_16=C002-1.tif stack_17=C003-1.tif stack_18=C004-1.tif stack_19=C005-1.tif stack_20=C006-1.tif stack_21=C007-1.tif stack_22=C010-1.tif stack_23=C011-1.tif stack_24=C012-1.tif stack_25=D001-1.tif stack_26=D002-1.tif stack_27=D003-1.tif stack_28=D005-1.tif stack_29=D007-1.tif stack_30=D008-1.tif stack_31=D010-1.tif stack_32=D011-1.tif stack_33=D012-1.tif stack_34=E001-1.tif stack_35=E003-1.tif stack_36=E004-1.tif stack_37=E005-1.tif stack_38=E006-1.tif stack_39=E008-1.tif stack_40=E009-1.tif stack_41=E011-1.tif stack_42=E012-1.tif stack_43=F001-1.tif stack_44=F003-1.tif stack_45=F005-1.tif stack_46=F006-1.tif stack_47=F008-1.tif stack_48=F009-1.tif stack_49=F010-1.tif stack_50=F011-1.tif stack_51=F012-1.tif stack_52=G001-1.tif stack_53=G002-1.tif stack_54=G003-1.tif stack_55=G004-1.tif stack_56=G005-1.tif stack_57=G006-1.tif stack_58=G007-1.tif stack_59=G008-1.tif stack_60=G010-1.tif stack_61=G011-1.tif stack_62=G012-1.tif stack_63=H003-1.tif stack_64=H004-1.tif stack_65=H005-1.tif stack_66=H007-1.tif";


//--------------do not change anything between this note and the next. Do not forget to add more after the next note---------------

  //Directory choosing dialog
  dirin = getDirectory("Choose a Directory which harbours the images");
  //setting array
  wellstouse = newArray(wells);
  //setting array of used wells
  wellstouse = setArray(wellstouse);
  //calling of function for creating the montage
  createmontage(dirin); 


  function createmontage(dir) {
	//iterate through all wells
  	for (i = 0; i < wells; i++){
		//iterate over all loops in one well
  		for (j = 1; j < (loops + 1); j++){
  			print(wellstouse[i]);
			//load both channels for the current loops
  			temppath1 = dir + wellstouse[i] + "/" + firstchannel + "/LO" + pad(j,3,0) + "/";
  			temppath2 = dir + wellstouse[i] + "/" + secondchannel + "/LO" + pad(j,3,0) + "/";
  			templist1 = getFileList(temppath1);
  			templist2 = getFileList(temppath2);
  			print(temppath1 + templist1[zslice]);
  			open(temppath1 + templist1[zslice]);
  			open(temppath2 + templist2[zslice]);
  		}//for loops
		//create a stack along t for the well
  		run("Images to Stack", "name=" + wellstouse[i] +".tif title=[] use");
		//make the stack smaller
  		run("Scale...", "x=- y=- z=1.0 width=256 height=256 depth=136 interpolation=Bilinear average process create");
		//change the stack to correctly show the channels
  		run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=1 frames=" + loops + " display=Color");
  		//close the larger stack of the well
		selectWindow(wellstouse[i] +".tif");
  		close();
  	}//for well
  //create the montage for all selected wells and save it
  run("Multi Stack Montage...", montage + " rows=" + rows + " columns="+columns);
  selectWindow("Montage of Stacks");
  saveAs("Tiff", dir + "Montage" + ".tif");
  closeallwindows();
  }//function

function closeallwindows() { 
	while (nImages>0) { 
		selectImage(nImages); 
        close(); 
    } 
}

function pad (a, left, right) {
	while (lengthOf(""+a)<left) a="0"+a;
		separator=".";
	while (lengthOf(""+separator)<=right)
		separator=separator+"0";
return ""+a;
} 
//--------------change the wellstouse This is also exported from R---------------
function setArray(wellstouse){
wellstouse[0] = "A001";
wellstouse[1] = "A002";
wellstouse[2] = "A003";
wellstouse[3] = "A004";
wellstouse[4] = "A005";
wellstouse[5] = "A007";
wellstouse[6] = "A010";
wellstouse[7] = "A012";
wellstouse[8] = "B001";
wellstouse[9] = "B002";
wellstouse[10] = "B004";
wellstouse[11] = "B006";
wellstouse[12] = "B008";
wellstouse[13] = "B009";
wellstouse[14] = "B011";
wellstouse[15] = "C002";
wellstouse[16] = "C003";
wellstouse[17] = "C004";
wellstouse[18] = "C005";
wellstouse[19] = "C006";
wellstouse[20] = "C007";
wellstouse[21] = "C010";
wellstouse[22] = "C011";
wellstouse[23] = "C012";
wellstouse[24] = "D001";
wellstouse[25] = "D002";
wellstouse[26] = "D003";
wellstouse[27] = "D005";
wellstouse[28] = "D007";
wellstouse[29] = "D008";
wellstouse[30] = "D010";
wellstouse[31] = "D011";
wellstouse[32] = "D012";
wellstouse[33] = "E001";
wellstouse[34] = "E003";
wellstouse[35] = "E004";
wellstouse[36] = "E005";
wellstouse[37] = "E006";
wellstouse[38] = "E008";
wellstouse[39] = "E009";
wellstouse[40] = "E011";
wellstouse[41] = "E012";
wellstouse[42] = "F001";
wellstouse[43] = "F003";
wellstouse[44] = "F005";
wellstouse[45] = "F006";
wellstouse[46] = "F008";
wellstouse[47] = "F009";
wellstouse[48] = "F010";
wellstouse[49] = "F011";
wellstouse[50] = "F012";
wellstouse[51] = "G001";
wellstouse[52] = "G002";
wellstouse[53] = "G003";
wellstouse[54] = "G004";
wellstouse[55] = "G005";
wellstouse[56] = "G006";
wellstouse[57] = "G007";
wellstouse[58] = "G008";
wellstouse[59] = "G010";
wellstouse[60] = "G011";
wellstouse[61] = "G012";
wellstouse[62] = "H003";
wellstouse[63] = "H004";
wellstouse[64] = "H005";
wellstouse[65] = "H007";
return wellstouse;
}