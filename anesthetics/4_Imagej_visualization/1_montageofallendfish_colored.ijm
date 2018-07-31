// creates a montage of stacks used for the final evaluation
// You also need to supply a sufficiently sized legend.tif file in black and white for the legend
// The well vectors can be exported from R with the script:

//--------------change these variables---------------

//Opacity of the overlayed colors
opacity = 60;
//image size for scaling
image_size = 256;
//size of legend rectangles in pixels
legend_size = 76;

//which wells should be used for montage? This can be exported from R
montage = "stack_1=A001-1.tif stack_2=A003-1.tif stack_3=A004-1.tif stack_4=A006-1.tif stack_5=A008-1.tif stack_6=A009-1.tif stack_7=A010-1.tif stack_8=A011-1.tif stack_9=A012-1.tif stack_10=B001-1.tif stack_11=B002-1.tif stack_12=B003-1.tif stack_13=B012-1.tif stack_14=C001-1.tif stack_15=C002-1.tif stack_16=C004-1.tif stack_17=C005-1.tif stack_18=C006-1.tif stack_19=C007-1.tif stack_20=C008-1.tif stack_21=D001-1.tif stack_22=D002-1.tif stack_23=D006-1.tif stack_24=D007-1.tif stack_25=D009-1.tif stack_26=D010-1.tif stack_27=D011-1.tif stack_28=D012-1.tif stack_29=E001-1.tif stack_30=E002-1.tif stack_31=E003-1.tif stack_32=E004-1.tif stack_33=E006-1.tif stack_34=E007-1.tif stack_35=E009-1.tif stack_36=E010-1.tif stack_37=E011-1.tif stack_38=E012-1.tif stack_39=F003-1.tif stack_40=F004-1.tif stack_41=F005-1.tif stack_42=F007-1.tif stack_43=F008-1.tif stack_44=F009-1.tif stack_45=F010-1.tif stack_46=F012-1.tif stack_47=G001-1.tif stack_48=G004-1.tif stack_49=G005-1.tif stack_50=G007-1.tif stack_51=G008-1.tif stack_52=G009-1.tif stack_53=G011-1.tif stack_54=H002-1.tif stack_55=H003-1.tif stack_56=H005-1.tif stack_57=H007-1.tif stack_58=H009-1.tif stack_59=H010-1.tif stack_60=H011-1.tif";
//how many rows and columns should the montage have?
rows = 6;
columns = 10;

//these are the different conditions and its corresponding values currently 6 are implemented. The order has to be the same in the legend.tif
name1 = "aB_color";
red1 = 118;
green1 = 42;
blue1 = 131;
name2 = "DMSO_color";
red2 = 175;
green2 = 141;
blue2 = 195;
name3 = "Etomidate_color";
red3 = 231;
green3 = 212;
blue3 = 232;
name4 = "mock_color";
red4 = 217;
green4 = 240;
blue4 = 211;
name5 = "Tricaine_color";
red5 = 127;
green5 = 191;
blue5 = 123;
name6 = "uninjected_color";
red6 = 27;
green6 = 120;
blue6 = 55;

//--------------nothing has to be changed from here to the next note---------------

  //Directory choosing dialog 
  dir = getDirectory("Choose the directory");
  // opening and compressing stacks
  stack_iterator(dir);    


function stack_iterator(dir){
	list = getFileList(dir + "stacks/");
	//making color scales
	//color for condition1
	newImage("red", "RGB black", image_size, image_size, 1);
	run("Set...", red1);
	newImage("green", "RGB black", image_size, image_size, 1);
	run("Set...", green1);
	newImage("blue", "RGB black", image_size, image_size, 1);
	run("Set...", blue1);
	run("Merge Channels...", "c1=red c2=green c3=blue");
	run("RGB Color");
	rename(name1);
	//color for condition2
	newImage("red", "RGB black", image_size, image_size, 1);
	run("Set...", red2);
	newImage("green", "RGB black", image_size, image_size, 1);
	run("Set...", green2);
	newImage("blue", "RGB black", image_size, image_size, 1);
	run("Set...", blue2);
	run("Merge Channels...", "c1=red c2=green c3=blue");
	run("RGB Color");
	rename(name2);
	//color for condition3
	newImage("red", "RGB black", image_size, image_size, 1);
	run("Set...", red3);
	newImage("green", "RGB black", image_size, image_size, 1);
	run("Set...", green3);
	newImage("blue", "RGB black", image_size, image_size, 1);
	run("Set...", blue3);
	run("Merge Channels...", "c1=red c2=green c3=blue");
	run("RGB Color");
	rename(name3);
	//color for condition4
	newImage("red", "RGB black", image_size, image_size, 1);
	run("Set...", red4);
	newImage("green", "RGB black", image_size, image_size, 1);
	run("Set...", green4);
	newImage("blue", "RGB black", image_size, image_size, 1);
	run("Set...", blue4);
	run("Merge Channels...", "c1=red c2=green c3=blue");
	run("RGB Color");
	rename(name4);
	//color for condition5
	newImage("red", "RGB black", image_size, image_size, 1);
	run("Set...", red5);
	newImage("green", "RGB black", image_size, image_size, 1);
	run("Set...", green5);
	newImage("blue", "RGB black", image_size, image_size, 1);
	run("Set...", blue5);
	run("Merge Channels...", "c1=red c2=green c3=blue");
	run("RGB Color");
	rename(name5);
	//color for condition6
	newImage("red", "RGB black", image_size, image_size, 1);
	run("Set...", red6);
	newImage("green", "RGB black", image_size, image_size, 1);
	run("Set...", green6);
	newImage("blue", "RGB black", image_size, image_size, 1);
	run("Set...", blue6);
	run("Merge Channels...", "c1=red c2=green c3=blue");
	run("RGB Color");
	rename(name6);
	
	
//--------------from here on the wells for the conditions have to be added---------------
	//iterating through files
    	for (i=0; i< list.length ; i++) {
    		//only opening the surviving wells this can also be exported from R
    		if ((list[i] == "A001.tif" ) | (list[i] == "A003.tif" ) | (list[i] == "A004.tif" ) | (list[i] == "A006.tif" ) | (list[i] == "A008.tif" ) | (list[i] == "A009.tif" ) | (list[i] == "A010.tif" ) | (list[i] == "A011.tif" ) | (list[i] == "A012.tif" ) | (list[i] == "B001.tif" ) | (list[i] == "B002.tif" ) | (list[i] == "B003.tif" ) | (list[i] == "B012.tif" ) | (list[i] == "C001.tif" ) | (list[i] == "C002.tif" ) | (list[i] == "C004.tif" ) | (list[i] == "C005.tif" ) | (list[i] == "C006.tif" ) | (list[i] == "C007.tif" ) | (list[i] == "C008.tif" ) | (list[i] == "D001.tif" ) | (list[i] == "D002.tif" ) | (list[i] == "D006.tif" ) | (list[i] == "D007.tif" ) | (list[i] == "D009.tif" ) | (list[i] == "D010.tif" ) | (list[i] == "D011.tif" ) | (list[i] == "D012.tif" ) | (list[i] == "E001.tif" ) | (list[i] == "E002.tif" ) | (list[i] == "E003.tif" ) | (list[i] == "E004.tif" ) | (list[i] == "E006.tif" ) | (list[i] == "E007.tif" ) | (list[i] == "E009.tif" ) | (list[i] == "E010.tif" ) | (list[i] == "E011.tif" ) | (list[i] == "E012.tif" ) | (list[i] == "F003.tif" ) | (list[i] == "F004.tif" ) | (list[i] == "F005.tif" ) | (list[i] == "F007.tif" ) | (list[i] == "F008.tif" ) | (list[i] == "F009.tif" ) | (list[i] == "F010.tif" ) | (list[i] == "F012.tif" ) | (list[i] == "G001.tif" ) | (list[i] == "G004.tif" ) | (list[i] == "G005.tif" ) | (list[i] == "G007.tif" ) | (list[i] == "G008.tif" ) | (list[i] == "G009.tif" ) | (list[i] == "G011.tif" ) | (list[i] == "H002.tif" ) | (list[i] == "H003.tif" ) | (list[i] == "H005.tif" ) | (list[i] == "H007.tif" ) | (list[i] == "H009.tif" ) | (list[i] == "H010.tif" ) | (list[i] == "H011.tif" )){
    		open(dir+"stacks/"+list[i]);
    		run("Scale...", "x=- y=- z=1.0 width=" + image_size +" height=" + image_size + " depth=166 interpolation=Bilinear average process create");
    		selectWindow(list[i]);
    		close();
    		print(list[i]);
    		//coloring according to condition
    		if((list[i] == "B001.tif" ) | (list[i] == "D001.tif" ) | (list[i] == "F008.tif" ) | (list[i] == "G001.tif" ) | (list[i] == "G009.tif" ) | (list[i] == "G011.tif" ) | (list[i] == "H005.tif" ) | (list[i] == "H011.tif" ) | (list[i] == "H012.tif" )){
    			run("RGB Color");
    			run("Add Image...", "image=" + name1 + " x=0 y=0 opacity=" + opacity);
    			run("To ROI Manager");
    			run("Labels...", "color=white font=12 draw");
    			run("Flatten", "stack");
    		} // if condition1
    		if((list[i] == "A004.tif" ) | (list[i] == "A008.tif" ) | (list[i] == "D009.tif" ) | (list[i] == "E003.tif" ) | (list[i] == "E012.tif" ) | (list[i] == "F003.tif" ) | (list[i] == "F009.tif" ) | (list[i] == "F010.tif" ) | (list[i] == "G004.tif" ) | (list[i] == "H009.tif" )){
    			run("RGB Color");
    			run("Add Image...", "image=" + name2 + " x=0 y=0 opacity=" + opacity);
    			run("To ROI Manager");
    			run("Labels...", "color=white font=12 draw");
    			run("Flatten", "stack");
    		} // if condition2
    		if((list[i] == "A006.tif" ) | (list[i] == "B002.tif" ) | (list[i] == "B003.tif" ) | (list[i] == "C001.tif" ) | (list[i] == "C006.tif" ) | (list[i] == "C007.tif" ) | (list[i] == "D002.tif" ) | (list[i] == "D006.tif" ) | (list[i] == "D010.tif" ) | (list[i] == "E001.tif" ) | (list[i] == "F007.tif" ) | (list[i] == "G005.tif" ) | (list[i] == "G007.tif" ) | (list[i] == "G008.tif" ) | (list[i] == "H003.tif" )){
    			run("RGB Color");
    			run("Add Image...", "image=" + name3 + " x=0 y=0 opacity=" + opacity);
    			run("To ROI Manager");
    			run("Labels...", "color=white font=12 draw");
    			run("Flatten", "stack");
    		}// if condition3
    		if((list[i] == "A001.tif" ) | (list[i] == "A009.tif" ) | (list[i] == "A010.tif" ) | (list[i] == "C004.tif" ) | (list[i] == "C005.tif" ) | (list[i] == "E002.tif" ) | (list[i] == "E006.tif" ) | (list[i] == "E007.tif" ) | (list[i] == "E009.tif" ) | (list[i] == "E010.tif" ) | (list[i] == "F005.tif" ) | (list[i] == "F012.tif" ) | (list[i] == "H002.tif" ) | (list[i] == "H007.tif" ) | (list[i] == "H010.tif" )){
    			run("RGB Color");
    			run("Add Image...", "image=" + name4 + " x=0 y=0 opacity=" + opacity);
    			run("To ROI Manager");
    			run("Labels...", "color=white font=12 draw");
    			run("Flatten", "stack");
    		}//if condition4
    		if((list[i] == "A003.tif" ) | (list[i] == "A012.tif" ) | (list[i] == "C002.tif" ) | (list[i] == "C008.tif" ) | (list[i] == "D007.tif" ) | (list[i] == "D011.tif" ) | (list[i] == "D012.tif" ) | (list[i] == "E004.tif" ) | (list[i] == "E011.tif" ) | (list[i] == "F004.tif" )){
    			run("RGB Color");
    			run("Add Image...", "image=" + name5 + " x=0 y=0 opacity=" + opacity);
    			run("To ROI Manager");
    			run("Labels...", "color=white font=12 draw");
    			run("Flatten", "stack");
    		}//if condition5
    		if((list[i] == "A011.tif" ) | (list[i] == "B012.tif" )){
    			run("RGB Color");
    			run("Add Image...", "image=" + name6 + " x=0 y=0 opacity=" + opacity);
    			run("To ROI Manager");
    			run("Labels...", "color=white font=12 draw");
    			run("Flatten", "stack");
    		}//if condition6
    		}//if open
    	}
//--------------nothing has to be changed from here on---------------		
		//create the montage
    	run("Multi Stack Montage...", montage + " rows=" + rows + " columns=" + columns);
    	rename("Montage");
		//create legend color code
		open(dir + "legend.tif");
    	selectWindow(name1);
    	run("Scale...", "x=- y=- z=1.0 width=500 height=" + legend_size + " depth=165 interpolation=Bilinear average process create");
    	selectWindow("legend.tif");
    	run("Add Image...", "image=" + name1 + "-1 x=0 y=0 opacity=" + opacity);
    	run("To ROI Manager");
    	run("Labels...", "color=white font=12 draw");
    	run("Flatten", "stack");
    	selectWindow(name2);
    	run("Scale...", "x=- y=- z=1.0 width=500 height=" + legend_size + " depth=165 interpolation=Bilinear average process create");
    	selectWindow("legend.tif");
    	run("Add Image...", "image=" + name2 + "-1 x=0 y=" + legend_size+1 +" opacity=" + opacity);
    	run("To ROI Manager");
    	run("Labels...", "color=white font=12 draw");
    	run("Flatten", "stack");
    	selectWindow(name3);
    	run("Scale...", "x=- y=- z=1.0 width=500 height=" + legend_size + " depth=165 interpolation=Bilinear average process create");
    	selectWindow("legend.tif");
    	run("Add Image...", "image=" + name3 + "-1 x=0 y=" + legend_size*2+1 +" opacity=" + opacity);
    	run("To ROI Manager");
    	run("Labels...", "color=white font=12 draw");
    	run("Flatten", "stack");
    	selectWindow(name4);
    	run("Scale...", "x=- y=- z=1.0 width=500 height=" + legend_size + " depth=165 interpolation=Bilinear average process create");
    	selectWindow("legend.tif");
    	run("Add Image...", "image=" + name4 + "-1 x=0 y=" + legend_size*3+1 +" opacity=" + opacity);
    	run("To ROI Manager");
    	run("Labels...", "color=white font=12 draw");
    	run("Flatten", "stack");
    	selectWindow(name5);
    	run("Scale...", "x=- y=- z=1.0 width=500 height=" + legend_size + " depth=165 interpolation=Bilinear average process create");
    	selectWindow("legend.tif");
    	run("Add Image...", "image=" + name5 + "-1 x=0 y=" + legend_size*4+1 +" opacity=" + opacity);
    	run("To ROI Manager");
    	run("Labels...", "color=white font=12 draw");
    	run("Flatten", "stack");
    	selectWindow(name6);
    	run("Scale...", "x=- y=- z=1.0 width=500 height=" + legend_size + " depth=165 interpolation=Bilinear average process create");
    	selectWindow("legend.tif");
    	run("Add Image...", "image=" + name6 + "-1 x=0 y=" + legend_size*5+1 +" opacity=" + opacity);
    	run("To ROI Manager");
    	run("Labels...", "color=white font=12 draw");
    	run("Flatten", "stack");
    	//combine legend with stack and saving
    	run("Combine...", "stack1=Montage stack2=legend.tif");
    	saveAs("Tiff", dir + "Montage_colored_legend" + ".tif");
    	closeallwindows();
    }//function

  function closeallwindows() { 
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
  }  

//setBatchMode(false);
