class SignalDescriptor{
  int[][] signalDescriptorVector;    /* [0]Signal Tipe: Analog = 0, Digital = 1 -  [1]Signal Bytes  */
  final int signalType = 0, signalSize = 1;
  int numberOfSignals;
  
  SignalDescriptor(int _numberOfSignals) {
    numberOfSignals = _numberOfSignals;
    signalDescriptorVector = new int[_numberOfSignals][2];
  }
  
  void setSignal(int _signalIndex, String _signalType, int _numberOfBytes) {
    if (_signalType.equals("digital") == true)
      signalDescriptorVector[_signalIndex][signalType] = 0;
    else
      signalDescriptorVector[_signalIndex][signalType] = 1;
    
    signalDescriptorVector[_signalIndex][signalSize] = _numberOfBytes;
  }
  
  String getSignalType (int _signalIndex) {
    if( signalDescriptorVector[_signalIndex][signalType] == 0)
      return "digital";
    else
      return "analog";
  }
  
  int getSignalSize (int _signalIndex) {
    return signalDescriptorVector[_signalIndex][signalSize];
  }
  
  int getSignalQuantity () {
    return numberOfSignals;
  }
  
  int getSignalsSize () {
    int totalBytes = 0;
    for(int i = 0; i < numberOfSignals; i++) {
      totalBytes += signalDescriptorVector[i][signalSize];
    }
    
    return totalBytes;
  }
  
}

class AnalogSignal {
  boolean isUsed = false;  // object in use
  int objectNumber;        // number assigned to this object
  int[] dataVector;
   
  /* Nombre capas donde guardo la info segun su calidad */
  String layerName;
  String lq_layerName;
  String slq_layerName;
  String ulq_layerName;
  
  AnalogSignal( int[] dataVector){
    isUsed = true;
    
    /* Reasigno este objeto al vector global para luego acceder globalmente */
    for( int i = 0; i < maxNumberOfAnalogSignals;i++) {
      if(analogSignals[i] == null) {
        analogSignals[i] = this;
        objectNumber = i;
        break;
      }
      else if ( i == (maxNumberOfAnalogSignals - 1)) {    // si estan todos ocupados
        javax.swing.JOptionPane.showMessageDialog(null, "Max number of analog signals reached", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
        return;
      }
    }
    
    /* Guardo el vector de datos de la señal dentro de este objeto */
    this.dataVector = dataVector;
    
    /* Creo 3 capas para guardar la info, una de cada calidad */
    layerName = "Analog_" + str(objectNumber);
    lq_layerName = "lowQualy" + layerName;
    slq_layerName = "superLowQualy" + layerName;
    ulq_layerName = "ultraLowQualy" + layerName;
    
    /* Divisor de resolución de capas */
    int lq_scale = 4;
    int slq_scale = 64;
    int ulq_scale = 512;
    
    GPointsArray points = new GPointsArray(dataVector.length);  // points of plot
    GPointsArray lowQualyPoints = new GPointsArray(dataVector.length/lq_scale);  // points for low qualy layer
    GPointsArray superLowQualyPoints = new GPointsArray(dataVector.length/slq_scale);  // points for super low qualy layer
    GPointsArray ultraLowQualyPoints = new GPointsArray(dataVector.length/ulq_scale);  // points for super low qualy layer
    
    /* Añado los datos a sus respectivas capas */
    for (int i = 0; i < dataVector.length; i++) {
      /* Añado el punto a la capa del plot */
      points.add(i*0.1, dataVector[i], "("+ i*0.1 +" , "+ dataVector[i] +")");
      
      if( i % lq_scale == 0 )  //every lq_scale points save one for the low qualy layer
      {
        lowQualyPoints.add(i*0.1, dataVector[i]);
      }
      if( i % slq_scale == 0 )  //every slq_scale points save one for the super low qualy layer
      {
        superLowQualyPoints.add(i*0.1, dataVector[i]);
      }
      if( i % ulq_scale == 0 )  //every slq_scale points save one for the super low qualy layer
      {
        ultraLowQualyPoints.add(i*0.1, dataVector[i]);
      }
    }
    
    /* Add the layers to the plot */
    
    // Main Layer
    plot1.addLayer(layerName, points);
    plot1.getLayer(layerName).setPointColor(color(255,0,0));
    plot1.getLayer(layerName).setFontSize(14);
    
    // Low Qualy Layer
    plot1.addLayer(lq_layerName, lowQualyPoints);
    plot1.getLayer(lq_layerName).setFontSize(14);
    plot1.getLayer(lq_layerName).setPointColor(color(255,0,0));
    plot1.getLayer(lq_layerName).setPointSize(5);
    
    // Super Low Qualy Layer
    plot1.addLayer(slq_layerName, superLowQualyPoints);
    plot1.getLayer(slq_layerName).setFontSize(14);
    plot1.getLayer(slq_layerName).setPointColor(color(255,0,0));
    plot1.getLayer(slq_layerName).setPointSize(4);
    
    // Ultra Low Qualy Layer
    plot1.addLayer(ulq_layerName, ultraLowQualyPoints);
    plot1.getLayer(ulq_layerName).setFontSize(14);
    plot1.getLayer(ulq_layerName).setPointColor(color(255,0,0));
    plot1.getLayer(ulq_layerName).setPointSize(3);
    
  }
  
  /* Draws this signal to the plot */
  void draw( int quality) {
    
    switch(quality) {
      case 0:    // ful Res
        plot1.getLayer(layerName).drawPoints();  
        plot1.getLayer(layerName).drawLines();
        break;
      case 1:    // low Qualy
        plot1.getLayer(lq_layerName).drawPoints();  
        plot1.getLayer(lq_layerName).drawLines();
        break;
      case 2:    // super low Qualy
        plot1.getLayer(slq_layerName).drawPoints();  
        plot1.getLayer(slq_layerName).drawLines();
        break; 
      case 3:    // ultra low Qualy
        //plot1.getLayer(ulq_layerName).drawPoints();  
        plot1.getLayer(ulq_layerName).drawLines();
        break; 
    }
      
  }
  
  int getSignalLength() {
    return dataVector.length; 
  }
  
}


class DigitalSignal {
  boolean isUsed = false;  // object in use
  int objectNumber;        // number assigned to this object
  int[] dataVector;
   
  /* Nombre capas donde guardo la info segun su calidad */
  String layerName;
  String lq_layerName;
  String slq_layerName;
  
  DigitalSignal( int[] dataVector){
    isUsed = true;
    
    /* Reasigno este objeto al vector global para luego acceder globalmente */
    for( int i = 0; i < maxNumberOfDigitalSignals;i++) {
      if(digitalSignals[i] == null) {
        digitalSignals[i] = this;
        objectNumber = i;
        break;
      }
      else if ( i == (maxNumberOfDigitalSignals - 1)) {    // si estan todos ocupados
        javax.swing.JOptionPane.showMessageDialog(null, "Max number of digital signals reached", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
        return;
      }
    }
    
    /* Guardo el vector de datos de la señal dentro de este objeto */
    this.dataVector = dataVector;
    
    /* Creo capa para guardar la info */
    layerName = "Digital_" + str(objectNumber);
    
    GPointsArray points = new GPointsArray(dataVector.length);  // points of plot
    
    /* Añado los datos a su respectivas capa según los cambios de señal */
    int x = 0;
    int lastValue = dataVector[x] > 0 ? 1 : 0;    // (dataVector[x] > 0 ? 1 : 0) paso de valores a digital 1 o 0.
    points.add(x*0.1, lastValue);
    
    while (x < dataVector.length) {  // recorro todo el vector solo añadiendo punto cuando hay una diferencia
      
      /* Si hay un cambio de dato grafico el actual y el anterior*/
      if( (dataVector[x] > 0 ? 1 : 0) != lastValue ) {
        /* Añado el punto a la capa del plot */
        points.add( (x-1)*0.1, lastValue);
        points.add(x*0.1, (dataVector[x] > 0 ? 1 : 0) );
        
        lastValue = (dataVector[x] > 0 ? 1 : 0);
      }
      
      x++;
    }
    points.add((x-1)*0.1, (dataVector[x-1] > 0 ? 1 : 0));
    
    /* Add the layers to the plot */
    
    /* Plot 2: Digital Signals */
    // Create a new plot and set its position on the screen
    int plotHigh = (plotToY-plotFromY)/maxNumberOfDigitalSignals;
    digitalPlots[objectNumber].setPos(plotFromX, plotFromY + plotHigh * (maxNumberOfDigitalSignals-1) - objectNumber * plotHigh);
    digitalPlots[objectNumber].setDim( plotToX*2-plotFromX+120, plotHigh);
    
    // Set the plot title and the axis labels
    digitalPlots[objectNumber].getRightAxis().setAxisLabelText("Digital CH" + str(objectNumber));
    digitalPlots[objectNumber].getRightAxis().getAxisLabel().setOffset(10);
    
    //plot.setXLim(new float[] { 0, dataFiles[dataFileCount].getRawDataQuantity() /10 });
    //plot.setFixedXLim(true);
    
    // Set plot configs
    digitalPlots[objectNumber].activatePointLabels();
    digitalPlots[objectNumber].getRightAxis().setDrawTickLabels(true);  // make the axis of this plot visible
    
    /* Add points to the plot */
    
    digitalPlots[objectNumber].addLayer(layerName, points);
    digitalPlots[objectNumber].getLayer(layerName).setFontSize(14);
    
    /* Set Axis limits */
    digitalPlots[objectNumber].getRightAxis().setLim(new float[] { -0.1, 1.1});
    digitalPlots[objectNumber].getRightAxis().setNTicks( 1);
    digitalPlots[objectNumber].getRightAxis().setFixedTicks(true);
    
    digitalPlots[objectNumber].getYAxis().setLim(new float[] { -0.1, 1.1});
    digitalPlots[objectNumber].getYAxis().setNTicks(1);
    digitalPlots[objectNumber].getYAxis().setFixedTicks(true);
    digitalPlots[objectNumber].setFixedYLim(true);
    
    //digitalPlots[objectNumber].setFixedYLim(true);
    
    /* Set colors */
    digitalPlots[objectNumber].getLayer(layerName).setLineColor(color(0,0,255));
    digitalPlots[objectNumber].getLayer(layerName).setPointColor(color(0,0,255));
    digitalPlots[objectNumber].getLayer(layerName).setPointSize(3);
    
  }
  
  /* Draws this signal to the plot */
  void draw( int quality) {  // quality not used in digital, it will draw the minimun amount of points possibles
      digitalPlots[objectNumber].setXLim(plot1.getXLim());
      //digitalPlots[objectNumber].getYAxis().setLim(new float[] { -0.1, 1.1});
      
      digitalPlots[objectNumber].beginDraw();
      digitalPlots[objectNumber].drawRightAxis();
      //digitalPlots[objectNumber].getLayer(layerName).drawPoints();  
      digitalPlots[objectNumber].getLayer(layerName).drawLines();
      digitalPlots[objectNumber].endDraw();
   }
  
}
