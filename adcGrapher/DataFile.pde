class DataFile{
  // An array of Seed objects
  Seed[] seeds = new Seed[10000];
  int seedCount = 0;
  String[] rawData;
  int[] rawDataVector;
  int rawDataQuantity;
  String fileNamePath , fileName;
  int fileIndex; // indicate the order in wich the file was added
  float minSlope = 256, minPointValue = 0xFFFF, failsafe =0;
  int[] auxPoint, auxMinPoint;
  
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
  
  int getRawDataQuantity() {
    return rawDataQuantity;
  }
  
  int getSeedCount () {
    return seedCount;
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
          minSlope = -256;
          auxPoint = null;
          auxMinPoint = null;
          minPointValue = 0xFFFF;
          failsafe = 0;
          seeds[seedCount] = null;
          state = 0;
        break;
        case 0:  //noPulso
          
          
          /*  If i start a down flank in the signal is because i have a start of a pulse */
          if ( ( trend.getSlope() < -slopeTrigger ) && (trend.getSlopeRate()==-1) ) {
              //seedCount++;
              state = 1;
              /*  create a new seed and save the point  */
              seeds[seedCount] = new Seed( seedCount, i, rawDataVector[i], state, trend.getSlope());
              if (seedCount == 300 ) 
                print("\nSe alcanzó más de " + seedCount + " semillas.");
              if (seedCount == 1000 ) 
                print("\nSe alcanzó más de " + seedCount + " semillas.");
              if (seedCount == 5000 ) 
                print("\nSe alcanzó más de " + seedCount + " semillas.");
              if (seedCount == 10000 ) {
                print("\n\nSe alcanzó el numero máximo de semillas detectables! (" + seedCount + ")\n");
                i = rawDataQuantity; // saltea el resto del loop para no crashear
              } //<>//
              break;
          }
          
          /*  Add the data that not correspond to a pulse to the plot*/
          points.add(i*0.1, rawDataVector[i], "("+ i*0.1 +" , "+ rawDataVector[i] +")");
          
        break;
        case 1:  //flancoDescendente
          
          /*  Add this point to the seed  */
          seeds[seedCount].addPoint( i, rawDataVector[i], state, trend.getSlope() );
          
          /*  Guardo el punto mas bajo del pulso  */
           if ( rawDataVector[i] <  minPointValue ) {
             minPointValue = rawDataVector[i];
             if ( auxMinPoint == null) auxMinPoint = new int[2];
             auxMinPoint[1] = rawDataVector[i];
             auxMinPoint[0] = i;
           }
          
          /*  If i close to a zero slope  */
          if ( (trend.getSlope() > -slopeTrigger ) && (trend.getSlopeRate()==1) ) {
            state = 2;
           }
        break;
        case 2:  //inconsistente
          /* Añado el punto al objeto semilla  */
          seeds[seedCount].addPoint( i, rawDataVector[i], state, trend.getSlope() );
          
          /*  If i stay a lot in a zero slope, reset  */
          if ( (trend.getSlope() == 0 ) && (trend.getSlopeRate()==0) ) {
            failsafe++;
            if(failsafe > 5) {
              state = -1;
              break;
            }
          }
          
          /*  Guardo el punto mas bajo del pulso  */
           if ( rawDataVector[i] <  minPointValue ) {
             minPointValue = rawDataVector[i];
             if ( auxMinPoint == null) auxMinPoint = new int[2];
             auxMinPoint[1] = rawDataVector[i];
             auxMinPoint[0] = i;
           }
          
          /*  If i pass to an ascending pulse  */
          if ( (trend.getSlope() >= slopeTrigger/2 ) && (trend.getSlopeRate()==1) ) {
            seeds[seedCount].addPointOfInterest( auxMinPoint[0], auxMinPoint[1]);  //  Punto correspondiente al minimo del pulso
            
            /* Reseteo los buscadores del punto minimo y el que guarda el punto de interes  */
              minSlope = -256;
              auxPoint = null;
              auxMinPoint = null;
              minPointValue = 0xFFFF;
              
            state = 3;
            break;
           }
           
           /*  If i pass to a descending pulse  */
          if ( (trend.getSlope() < -slopeTrigger ) && (trend.getSlopeRate()==-1) ) {
            /*  Add the interest point  */
            if (auxPoint != null) seeds[seedCount].addPointOfInterest( auxPoint[0], auxPoint[1]);
            
            /* Reseteo los buscadores del punto minimo y el que guarda el punto de interes  */
              minSlope = -256;
              auxPoint = null;
              auxMinPoint = null;
              minPointValue = 0xFFFF;
            
            state = 1;
            break;
           }
           
           /*  Guardo auxiliarmente el punto con mas baja slope  */
           if ( trend.getSlope() > minSlope ) {
             minSlope = trend.getSlope();
             if ( auxPoint == null) auxPoint = new int[2];
             auxPoint[1] = rawDataVector[i];
             auxPoint[0] = i;
           }
           
        break;
        case 3:  //flancoAscendente
          /*  Añado el punto al objeto semilla  */
          seeds[seedCount].addPoint( i, rawDataVector[i], state, trend.getSlope() );
          
          /*  If i get a stable signal after a upwards flank, it means that the pulse was a seed */
          if ( (trend.getSlope() < slopeTrigger) && (trend.getSlopeRate()==-1) ) {
  
            seeds[seedCount].addPointOfInterest( i, rawDataVector[i] );  // last point of the seed
            seedCount++;
            state = 0;
            break;
          }
        break;
        default:
        state = -1;
        break;
      }
    }
    
    /*  Ploteo las semillas */
    GPointsArray p = new GPointsArray(1);
    plot1.addLayer("pulsoDescendente",p);
    plot1.addLayer("pulsoInconsistente",p);
    plot1.addLayer("pulsoAscendente",p);
    plot1.addLayer("interest",p);
    for ( int i = 0; i < seedCount ; i++) {
      seeds[i].plot (plot1);
      seeds[i].plotInterestPoints (plot1);
    }
    
    plot1.addLayer("noPulso", points);     // ploteo los puntos que no son pulsos de semilla
    
    /*  Personalizo las capas  */
    plot1.getLayer("noPulso").setFontSize(14);
    plot1.getLayer("noPulso").setLineColor(100);
    plot1.getLayer("noPulso").setPointColor(100);
    plot1.getLayer("pulsoDescendente").setFontSize(14);
    plot1.getLayer("pulsoDescendente").setLineColor(color(255,0,0));
    plot1.getLayer("pulsoDescendente").setPointColor(color(255,0,0));
    plot1.getLayer("pulsoInconsistente").setFontSize(14);
    plot1.getLayer("pulsoInconsistente").setLineColor(color(0,255,50));
    plot1.getLayer("pulsoInconsistente").setPointColor(color(0,255,50));
    plot1.getLayer("pulsoAscendente").setFontSize(14);
    plot1.getLayer("pulsoAscendente").setLineColor(color(255,180,0));
    plot1.getLayer("pulsoAscendente").setPointColor(color(255,180,0));
    plot1.getLayer("interest").setFontSize(14);
    plot1.getLayer("interest").setLineColor(color(0,0,255,200));
    plot1.getLayer("interest").setPointColor(color(0,0,255,200));
  }
  
  void plotData ( GPlot plot) {
    // Add one layer for every seed saved in file
    String layerName = fileName.substring(0,fileName.length()-4)  ; //Conform the plot layer name as 'csvFileName.#'
    int nPoints = rawDataQuantity;                       // number of value points in txt file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      points.add(i*0.1, rawDataVector[i], "("+ i*0.1 +" , "+ rawDataVector[i] +") "+layerName);
    }
    plot1.addLayer("fondo", points);     // add points to the layer
    plot1.getLayer("fondo").setFontSize(1);
    plot1.getLayer("fondo").setLineColor(color(80,150));
    plot1.getLayer("fondo").setPointColor(color(80,150));
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
      case 1:  /* Export in .csv format for seedAnalizer   */
          exportToSA();
      break;
      case 2:  /*  Export statistical data in a .csv format  */
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
    tableExport.addColumn("RMS");
    tableExport.addColumn("Vmedio");
    tableExport.addColumn("AreaDerivada");
    for ( int i=0 ; i < 6 ; i++ ){
      tableExport.addColumn( "Px" + str(i) );
      tableExport.addColumn( "Py" + str(i) );
    }
    
    /* Add seeds to table  */
    for ( int i = 0; i < seedCount; i++) {
      seeds[i].addSeedToTable( tableExport );
    }
    
    /*  Save table  */
    String fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exportedStats.csv";
    saveTable( tableExport, fileSavedIn );
    
    /*  Show success  */
    javax.swing.JOptionPane.showMessageDialog(null, "File Exported in " + fileSavedIn, "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
  }
  
  void exportToSA() {
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
