public class DataFile{
  // An array of Seed objects
  Seed[] seeds;
  
  String[] rawData;
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
    
  }
  
  // Returns the name of the original file loaded to this dataFile object
  String getFileName () {
    return fileName;
  }
  
  
  void plotData ( GPlot plot) {
    // Add one layer for every seed saved in file
    String layerName = fileName + "." + str(fileIndex); //Conform the plot layer name as 'csvFileName.#'
    int nPoints = rawDataQuantity;                       // number of value points in txt file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      int relativePos = i * 4;  // by 4 becouse the ADC are 16bit values ( ej. 0x5522 = 4 characters of the string rawData)
      String s0= rawData[0].substring(relativePos,relativePos+2);
      String s1= rawData[0].substring(relativePos+2,relativePos+4);
      int value = unhex( s1 + s0 );
      
      points.add(i*0.1, value, "("+ i*0.1 +","+ value +") "+layerName);
    }
    plot.addLayer(layerName, points);     // add points to the layer
    
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
    
    switch (format) { //<>//
      case 0:  /* Export in .h format   */
          if( rawDataQuantity > 2000 ) {
            /*  Show wait info  */
            javax.swing.JOptionPane.showMessageDialog(null, "In a moment your file will be exported", "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
          }
          exportToH();
          
      break;
    }
    
  }
  
  void exportToH() {
    
    String matrixVector[] = {"",""};
        
    /*  Add the text of all the seeds data  */
    int numberOfPointsData = rawDataQuantity;
    
    /*  Add the start of the vector  */
    matrixVector[0] = "#define NUMBER_OF_POINTS " + numberOfPointsData;
    
    /*  Start the vector  */
    matrixVector[1] = "uint16_t adcData[NUMBER_OF_POINTS] = { ";
    
    for (int i = 0; i < numberOfPointsData; i++) {
      int relativePos = i * 4;  // by 4 becouse the ADC are 16bit values ( ej. 0x5522 = 4 characters of the string rawData)
      String s0= rawData[0].substring(relativePos,relativePos+2);
      String s1= rawData[0].substring(relativePos+2,relativePos+4);
      int value = unhex( s1 + s0 );
      
      matrixVector[1] += value + ", ";
    }
    
    /*  Add the end of the vector  */
    matrixVector[1] = matrixVector[1].substring(0,matrixVector[1].length()-2 ) + "};";
    
    /*  Save text file  */
    String fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exported.h";
    saveStrings( fileSavedIn, matrixVector );
    
    /*  Show success  */
    javax.swing.JOptionPane.showMessageDialog(null, "File Exported in " + fileSavedIn, "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
  
  }
  
}
