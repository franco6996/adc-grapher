class DataFile{
  // An array of Seed objects
  Seed[] seeds;
  
  String[] rawData;
  int[] rawDataVector;
  int rawDataQuantity;
  String fileNamePath , fileName;
  int fileIndex; // indicate the order in wich the file was added

  
  // For data validation
  String[] column_titles;
  
  // Initialize the file
  DataFile (String file, String filePath) {
    fileIndex = dataFileCount;
    // Get the name of the selected file
    fileNamePath = filePath;
    fileName = file;
    
    // Load .txt file
    rawData = loadStrings(fileNamePath);
    
    // Data file validation
    
    // At this point i supouse that the file loaded is valir and not corrupt
    
    // Determine the number of int16 data point is contained by the rawData string
    rawDataQuantity = floor( rawData[0].length() / 4 );
    dataPointCounter = rawDataQuantity;
    rawDataVector = new int[rawDataQuantity];
    
    /*  Extract the data vector  */
    for (int i = 0; i < rawDataQuantity; i++) {
      int relativePos = i * 4;  // by 4 becouse the ADC are 16bit values ( ej. 0x5522 = 4 characters of the string rawData)
      String s0= rawData[0].substring(relativePos,relativePos+2);
      String s1= rawData[0].substring(relativePos+2,relativePos+4);
      int value = unhex( s1 + s0 );
      
      rawDataVector[i] = value;
    }
    
  }
  
  // Returns the name of the original file loaded to this dataFile object
  String getFileName () {
    return fileName;
  }
  
  
  void plotData ( GPlot plot) {
    // Add one layer for every seed saved in file
    String layerName = fileName.substring(0,fileName.length()-4)  ; //Conform the plot layer name as 'csvFileName.#'
    int nPoints = rawDataQuantity;                       // number of value points in txt file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      points.add(i*0.1, rawDataVector[i], "("+ i*0.1 +" , "+ rawDataVector[i] +") "+layerName);
    }
    plot1.addLayer(layerName, points);     // add points to the layer
    plot1.getLayer(layerName).setFontSize(14);
  }
  
  void removeLayers (){
    // Remove one layer for every seed saved in file
    for (Seed s : seeds) {
      s.removeLayer( fileName, fileIndex);
    }
  }
  
  int getFileIndex() {
    return fileIndex;
  }
  
  void setFileIndex( int fi ) {
    fileIndex = fi;
  }
  
  void exportToFile( int format ){
    
    switch (format) {
      case 0:  /* Export in .h format   */
          exportToH();
      break;
      case 1:  /* Export in .csv format   */
          exportToCSV();
      break;
    }
    
  }
  
  
  
  void exportToCSV() {
    /*  Init new table where to export  */
    Table tableExport;
    tableExport = new Table();
    
    /*  Add colums  */
    tableExport.addColumn("#");
    tableExport.addColumn("timeStamp");
    for ( int i=0 ; i < 101 ; i++ ){
      tableExport.addColumn( str(i) );
    }
    
    timeStampsFilePathLoaded = false;
    File start = new File(sketchPath("")+"/*.txt");
    selectInput("Select a .txt file that contains the timeStamps to extract", "setTimeStampsFile", start);
    
    while( timeStampsFilePathLoaded == false ){delay(50);}
    
    String[] timeStamps = loadStrings(timeStampsFilePath);
    
    /*  Add Rows  */
    int count = 0;
    for (String t : timeStamps) { //<>//
      // Salteo string vacia
      if( timeStamps[count].isEmpty() ) {
        count++;
        continue;
      }
      
      // Me aseguro de tener puntos suficientes para guardar la semilla
      if( Integer.valueOf(timeStamps[count]) + 52 > rawDataQuantity )
        break;
      /*  Add row containing the data arraund each timestamp  */
      TableRow newRow = tableExport.addRow();
      newRow.setInt("#", count);
      newRow.setInt("timeStamp", Integer.valueOf(timeStamps[count]) );
      for (int i = 0; i<101; i++ ){
        newRow.setInt( str(i) , rawDataVector[i + (Integer.valueOf(timeStamps[count])-50) ]);
      }
      count++;
    }
    
    /*  Save table  */
    String fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exported.csv";
    saveTable( tableExport, fileSavedIn );
    
    /*  Show success  */
    javax.swing.JOptionPane.showMessageDialog(null, "File Exported in " + fileSavedIn, "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
  }
  
  void exportToH() {
    
    String matrixVector[] = {"",""};
        
    /*  Add the text of all the seeds data  */
    int numberOfPointsData = rawDataQuantity;
    
    /*  Add the start of the vector  */
    matrixVector[0] = "#define NUMBER_OF_POINTS " + numberOfPointsData;
    
    /*  Start the vector  */
    matrixVector[1] = "uint16_t adcData[NUMBER_OF_POINTS] = { ";
    
    /* Open a progress bar window  */
    thread("progressBarWindow");
    
    for (int i = 0; i < numberOfPointsData; i++) {
      matrixVector[1] += rawDataVector[i] + ", ";
      progressBarValue = 100*i/numberOfPointsData;  // update the progress
    }
    
    /*  Add the end of the vector  */
    matrixVector[1] = matrixVector[1].substring(0,matrixVector[1].length()-2 ) + "};";
    
    /*  Save text file  */
    String fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exported.h";
    saveStrings( fileSavedIn, matrixVector );
    
    progressBarValue = 100;  // make sure the progress bar is closed
    
    /*  Show success  */
    javax.swing.JOptionPane.showMessageDialog(null, "File Exported in " + fileSavedIn, "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
  
  }
  
}
