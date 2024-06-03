class DataFile{
  
  String[] rawData;
  byte[] rawDataBytes;
  int[] rawDataVector;
  int rawDataQuantity;
  String fileNamePath , fileName;
  int fileIndex; // indicate the order in wich the file was added
  
  SignalDescriptor signalsInFile; // Quantity and order of the signals contained in the file
  
  // Initialize the file
  DataFile (String file, String filePath, SignalDescriptor _signalsInFile) {
    fileIndex = dataFileCount;
    signalsInFile = _signalsInFile;
    // Get the name of the selected file
    fileNamePath = filePath;
    fileName = file;
    
    /*  Get if the file has the apropiated file extension */
    String ext = (fileName.substring( fileName.lastIndexOf(".")+1 , fileName.length() )).toLowerCase();
    final int bin_ext = 0;
    final int txt_ext = 1;
    int ext_decode = -1;;
    if( ext.equals("txt") == true) ext_decode = txt_ext;
    if( ext.equals("bin") == true) ext_decode = bin_ext;
    
    switch( ext_decode) {
      case bin_ext:
        /* Process the .bin file that contains raw data in bytes */
        rawDataBytes = loadBytes(fileNamePath);
        
        int fileSize = rawDataBytes.length;
        int signalVectorSize = rawDataBytes.length/signalsInFile.getSignalsSize();
        
        
        if( signalVectorSize > 18000000) {    // Si mi archivo contiene mas de 18 Mega muestras lo limito (media hora a 100us por muestra)
          signalVectorSize = 18000000;
          fileSize = signalVectorSize * signalsInFile.getSignalsSize();
        }
        
        this.rawDataQuantity = signalVectorSize;  // almaceno el numero de muestras del archivo
        
        /* Vector de diferentes señales en archivo */
        int[][] signals = new int[signalsInFile.getSignalQuantity()][signalVectorSize];  // lugar donde guardo las señales ya convertidas, en el orden del signalDescriptor
        
        /* Recorro el vector de datos leidos del archivo, en saltos de bytes segun la cantidad de señales */
        int _index = 0;
        for(int _pos = 0; _pos < fileSize; _pos += signalsInFile.getSignalsSize()) {
          int _byteProcessed = 0;
          /* Procesamiento para cada señale en el tramo */
          for(int _signal = 0; _signal < signalsInFile.getSignalQuantity(); _signal ++) {
            /* Procesamiento para forma de guardado big-endian */
            for( int b = 0; b < signalsInFile.getSignalSize(_signal); b++) {
              // Guardo valor correspondiente a X _signal en la posicion correspondiente 
              signals[_signal][_index] = (signals[_signal][_index] << 8) | int(rawDataBytes[_pos + _byteProcessed]);
              _byteProcessed++;
            }
            /* Procesamiento para forma de guardado little-endian */
            boolean littleEndian = true;
            if( littleEndian == true) {
              int _signalSize = signalsInFile.getSignalSize(_signal);
              byte[] a = new byte[_signalSize];
              for(int x = 0; x < _signalSize ; x++) {  // guardo todos los bytes por separado
                a[x] = byte( (signals[_signal][_index]) >> (8*x) );
              }
              signals[_signal][_index] = 0;  // reseteo el valor de la muestra
              for(int x = 0; x < _signalSize ; x++) {  // los almaceno reordenados
                signals[_signal][_index] = signals[_signal][_index] << 8 | int(a[x]);
              }
            }
          }
          _index++;
        }
        
        /* En este punto ya tengo todas las señales cargadas en 'signals[][]' */
        
        /* Inicializo todas las señales del archivo */
        for(int _signal = 0; _signal < signalsInFile.getSignalQuantity(); _signal ++) {
        
          if ( true == "analog".equals(signalsInFile.getSignalType(_signal)) ) {
            AnalogSignal newSignal = new AnalogSignal(signals[_signal]);
          }
          else {
            DigitalSignal newSignal = new DigitalSignal(signals[_signal]);
          }
        }
      
      break;
      
      case txt_ext:
        // Load .txt file
        rawData = loadStrings(fileNamePath);
        // Determine the number of int16 data point is contained by the rawData string
        this.rawDataQuantity = floor( rawData[0].length() / 4 );
        rawDataVector = new int[rawDataQuantity];
        Boolean invertHex = false;  // invierte la transformación de string hexa a entero.
        
        // Transformo un solo numero para confirmar inversion segun bits ADC
        String h0= rawData[0].substring(0,2);
        String h1= rawData[0].substring(2,4);
        if(unhex( h1 + h0 ) > 4096) invertHex = true;
        
        //  Extract the data vector  
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
          }
          
          rawDataVector[i] = value;
        }
        AnalogSignal newSignal = new AnalogSignal(rawDataVector);
      break;
      
      default:
      javax.swing.JOptionPane.showMessageDialog(null, "File extension decoder missing!", "File Decoder Error", javax.swing.JOptionPane.ERROR_MESSAGE);
    }
    
  }
  
  // Returns the name of the original file loaded to this dataFile object
  String getFileName () {
    return fileName;
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
  
  int getFileIndex() {
    return fileIndex;
  }

  int getRawDataQuantity() {
    return rawDataQuantity;
  }
  
}
