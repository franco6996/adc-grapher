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
    
    // Determine the number of int16 data point is contained by the rawData string
    rawDataQuantity = floor( rawData[0].length() / 4 );
    rawDataVector = new int[rawDataQuantity];
    Boolean invertHex = false;  // invierte la transformación de string hexa a entero.
    
    // Transformo un solo numero para confirmar inversion segun bits ADC
    String h0= rawData[0].substring(0,2);
    String h1= rawData[0].substring(2,4);
    if(unhex( h1 + h0 ) > 4096) invertHex = true;
    
    /*  Extract the data vector  */
    for (int i = 0; i < rawDataQuantity; i++) {
      int relativePos = i * 4;  // by 4 becouse the ADC are 16bit values ( ej. 0x5522 = 4 characters of the string rawData)
      String s0= rawData[0].substring(relativePos,relativePos+2);
      String s1= rawData[0].substring(relativePos+2,relativePos+4);
      
      int value;
      
      if( invertHex == true )  // si el valor es más grande que el ADC, tengo que invertir h1, h0
      {
        value = unhex( s0 + s1 );
      }
      else
      {
        value = unhex( s1 + s0 );
      } //<>//
      
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
      /* Añado el punto a la capa del plot */
      points.add(i*0.1, rawDataVector[i], "("+ i*0.1 +" , "+ rawDataVector[i] +") "+layerName);
    } //<>//
    
    plot1.addLayer(layerName, points);     // add points to the layer
    plot1.getLayer(layerName).setFontSize(14);
  }
  
  Boolean getMarkers()
  {
    Boolean fail = false;
    int coeff = 70;
    try
    {
      String coeff_s = javax.swing.JOptionPane.showInputDialog(null,"Set Slope Trigger Coeff (40-150)", 70);
    
      if(coeff_s.isBlank() || coeff_s.isEmpty() ) throw new Exception();
    
      coeff = int(coeff_s);
    
      if(coeff <= 0) throw new Exception();
    }
    catch (Exception e)
    {
      javax.swing.JOptionPane.showMessageDialog(
                    null,"Error de entrada.", "oops!",
                    javax.swing.JOptionPane.ERROR_MESSAGE | javax.swing.JOptionPane.OK_OPTION);
      fail = true;
    }
    
    if(fail) return fail;
    
    PulseChecker pcheck = new PulseChecker(rawDataVector[10],coeff); // preparo el algoritmo para dibujar la maquina de estado en el plot
    int current_fsm_status = 0;
    int last_fsm_status = 0;
    
    
      /* Ejecuto el algoritmo, si cambia de estado agrego un marcador en el grafico */
    numberOfPlotMarkers = 0;
    for (int i = 0; i < rawDataQuantity; i++) {
      current_fsm_status = pcheck.run( rawDataVector[i] );
      if( last_fsm_status != current_fsm_status)
      {
        last_fsm_status = current_fsm_status;
        
        /* Guardo la posicion del marcador para dibujarlo mas tarde */
        plotMarkers[numberOfPlotMarkers] = i;
        
        /* Guardo que texto mostrar junto al marcador*/
        switch(current_fsm_status)
        {
         case 0:
           plotMarkersText[numberOfPlotMarkers] = "RESET";
         break;
         case 1:
           plotMarkersText[numberOfPlotMarkers] = "NO PULSO";
         break;
         case 2:
           plotMarkersText[numberOfPlotMarkers] = "FLANCO DESCENDENTE";
         break;
         case 3:
           plotMarkersText[numberOfPlotMarkers] = "FLANCO ASCENDENTE";
         break;
        }
        
        numberOfPlotMarkers++;
        
        /* Seguridad por si me quedo sin espacio en el vector de marcadores */
        if( plotMarkersMax == numberOfPlotMarkers)
          break;
      }
    }
    
    return fail;
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

  int getRawDataQuantity() {
    return rawDataQuantity;
  }

  int getRawDataVectorIn(int position) {
    return rawDataVector[position];
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
    for (String t : timeStamps) {
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
    
    /* Creates the threads to make the conformation of string faster */
    for (int i = 0; i < numberOfThreadsToUse; i++) {
      threadsInUse[i] = 0;
    }
    for (int i = 0; i < numberOfThreadsToUse; i++) {
      thread("mThreadExport");
      while (threadsInUse[i] == 0)
      {
        delay(10);
      }
    }
    
    /*  Espero que todos los threads terminen, mientras actualizo la barra de carga */
    while (progressBarValue < 100)
    {
      int auxProgress = 0;
      for (int i = 0; i < numberOfThreadsToUse; i++) {
        auxProgress += threadsProgress[i];
      }
      progressBarValue = auxProgress / numberOfThreadsToUse;
      
      // no hace falta que este procesando esto continuamente
      try {
       Thread.sleep(100);
      } catch (InterruptedException e) {
        e.printStackTrace();
      } 
      
    }

    /* Concateno las string de los threads */
    
    matrixVector[1] += threadString[0] + threadString[1] + threadString[2] + threadString[3] + threadString[4] + threadString[5] + threadString[6] + threadString[7];
    
    /*  Add the end of the vector  */
    matrixVector[1] = matrixVector[1].substring(0,matrixVector[1].length()-2 ) + "};";
    
    /*  Save text file  */
    String fileSavedIn = fileNamePath.substring(0,fileNamePath.length()-4 ) + "_exported.h"; //<>//
    saveStrings( fileSavedIn, matrixVector );
    
    progressBarValue = 100;  // make sure the progress bar is closed
    
    /*  Show success  */
    javax.swing.JOptionPane.showMessageDialog(null, "File Exported in " + fileSavedIn, "Export File", javax.swing.JOptionPane.INFORMATION_MESSAGE);
    println("Archivo Exportado");
  }
  
}
