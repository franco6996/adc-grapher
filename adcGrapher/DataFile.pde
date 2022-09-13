class DataFile{
  // An array of Seed objects
  Seed[] seeds = new Seed[300];
  int seedCount = 0;
  String[] rawData;
  int[] rawDataVector;
  int rawDataQuantity;
  String fileNamePath , fileName;
  int fileIndex; // indicate the order in wich the file was added
  float minSlope = 256;
  int[] auxPoint;
  
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
  
  
  void analyzeAndPlot () {
    
    GPointsArray points = new GPointsArray(rawDataQuantity);
    
    
    int state = 0; // Estado maquina: -1>reset , 0>noPulso , 1>flancoDescendente , 2>inconsistente , 3>flancoAscendente
    final int slopeTrigger = 10;
    Trend trend = new Trend( rawDataVector[0] ); 
    
    for (int i = 0 ; i < rawDataQuantity ; i++) {
      trend.estimate( rawDataVector[i] );
      switch (state) {
        case -1:  //reset
          minSlope = 256;
          auxPoint = null;
          state = 0;
        break;
        case 0:  //noPulso
          
          
          /*  If i start a down flank in the signal is because i have a start of a pulse */
          if ( ( trend.getSlope() < -slopeTrigger ) && (trend.getSlopeRate()==-1) ) {
              /*  create a new seed and save the point  */
              seeds[seedCount] = new Seed( rawDataVector[i], i); //<>//
              //seedCount++;
              state = 1;
              break;
          }
          
          /*  Add the data that not correspond to a pulse to the plot*/
          points.add(i*0.1, rawDataVector[i], "("+ i*0.1 +" , "+ rawDataVector[i] +")");
          
        break;
        case 1:  //flancoDescendente
          
          /*  Add this point to the seed  */
          seeds[seedCount].addPoint( rawDataVector[i], i , false);
          
          /*  If i close to a zero slope  */
          if ( (trend.getSlope() > -slopeTrigger ) && (trend.getSlopeRate()==1) ) {
            state = 2;
           }
        break;
        case 2:  //inconsistente
          /*  If i pass to an ascending pulse  */
          if ( (trend.getSlope() >= 0 ) && (trend.getSlopeRate()==1) ) {
            /*  Add this point to the seed  */
            seeds[seedCount].addPoint( rawDataVector[i], i , true);  // lowest point in the signal
            if ( auxPoint != null ){
              minSlope = 256;
              auxPoint = null;
            }
            state = 3;
            break;
           }
           /*  If i pass to a descending pulse  */
          if ( (trend.getSlope() < -slopeTrigger ) && (trend.getSlopeRate()==-1) ) {
            /*  Add this point to the seed  */
            seeds[seedCount].addPoint( rawDataVector[i], i , false);
            /*  Add the interest point  */ //<>//
            if ( auxPoint != null ){
              minSlope = 256;
              seeds[seedCount].addPoint( auxPoint[0], auxPoint[1] , true);
              auxPoint = null;
            }
            state = 1;
            break;
           }
           
           /*  Guardo auxiliarmente el punto con mas baja slope  */
           if ( trend.getSlope() < minSlope ) {
             minSlope = trend.getSlope();
             auxPoint = new int[2];
             auxPoint[0] = rawDataVector[i];
             auxPoint[1] = i;
           }
           
           /*  Añado este ultimo punto*/
           seeds[seedCount].addPoint( rawDataVector[i], i , false);
        break;
        case 3:  //flancoAscendente
        /*  If i get a stable signal after a upwards flank, it means that the pulse was a seed */
        if ( (trend.getSlope() < slopeTrigger) && (trend.getSlopeRate()==-1) ) {

          seeds[seedCount].addPoint( rawDataVector[i], i , true);  // last point of the seed
          seedCount++; //<>//
          state = 0;
          break;
        }
        
        seeds[seedCount].addPoint( rawDataVector[i], i , false);
        
        break;
        default:
        state = -1;
        break;
      }
    }
    
    plot1.addLayer("noPulso", points);     // add points to the layer
    plot1.getLayer("noPulso").setFontSize(14);
    plot1.getLayer("noPulso").setLineColor(80);
    plot1.getLayer("noPulso").setPointColor(80);
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
          if( rawDataQuantity > 2000 ) {
            /*  Show wait info  */
            javax.swing.JOptionPane.showMessageDialog(null, "In a moment your file will be exported", "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
          }
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
    for (String t : timeStamps) {
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
    
    for (int i = 0; i < numberOfPointsData; i++) {
      matrixVector[1] += rawDataVector[i] + ", ";
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
