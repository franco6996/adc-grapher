
import java.io.*;
SignalDescriptor getSignalPropierties (String currentPath) {
  // Busco el archivo con las propiedades de las señanles dentro de la misma carpeta
  currentPath = currentPath.substring(0, 1+currentPath.lastIndexOf("\\"));
  String propertiesPath = currentPath + "signals.properties";
  println(propertiesPath);
  
  Properties properties = new Properties();
  FileInputStream inputFile;
  try { inputFile = new FileInputStream(propertiesPath); } catch (Exception e) {inputFile = null; }
  
    // Si no existe, tomo el default dentro de la carpeta de instalacion del programa
    if (inputFile == null) {
      propertiesPath = sketchPath("") + "signals.properties";
      println("No se encuentra descriptor de señales, cargando default: " + propertiesPath);
      try { inputFile = new FileInputStream(propertiesPath); } catch (Exception e) {inputFile = null; }
      
      // Si el archivo default falla lo creo
      if (inputFile == null) {
        createSignalPropertiesFile();
        try { inputFile = new FileInputStream(propertiesPath); } catch (Exception e) {}
      }
      
    }
  
  // Cargo el archivo y extraigo sus propiedades creando el descriptor de señales
  try { properties.load(inputFile); } catch (Exception e) {println("Input Error!");}
  
  if( properties.getProperty("numberOfSignals") == null) {
      javax.swing.JOptionPane.showMessageDialog(
                    null,"Error de entrada.\nRevise archivo 'signals.properties'", "oops!",
                    javax.swing.JOptionPane.ERROR_MESSAGE | javax.swing.JOptionPane.OK_OPTION);
  }
  
  int numberOfSignals = int(properties.getProperty("numberOfSignals"));
  
  SignalDescriptor signalDescriptor = new SignalDescriptor(numberOfSignals);
  
  for(int x = 1; x <= numberOfSignals; x++){
    String signalSize = properties.getProperty("signal" + x + "Size");
    String signalType = properties.getProperty("signal" + x + "Type");
    String signalName = properties.getProperty("signal" + x + "Name");
    
    if( signalSize == null || signalType == null || signalName == null) {
      javax.swing.JOptionPane.showMessageDialog(
                    null,"Error de entrada.\nRevise archivo 'signals.properties'", "oops!",
                    javax.swing.JOptionPane.ERROR_MESSAGE | javax.swing.JOptionPane.OK_OPTION);
    }
    
    signalDescriptor.setSignal( x-1, signalType, int(signalSize) );
  }
  
  return signalDescriptor;
}

/*
 *  Writes to the program path the default signal descriptor file
 */
void createSignalPropertiesFile(){
  println("Sigal Properties file not exist. Creating a default one.");
  String[] signalPropertiesFile = new String[18];
  
  /* Write text default */
  signalPropertiesFile[0] = "#########################################################################";
  signalPropertiesFile[1] = "# This file sets the input file data format of multiple signals";
  signalPropertiesFile[2] = "#";
  signalPropertiesFile[3] = "# Signal number must be in the order stored inside the input file";
  signalPropertiesFile[4] = signalPropertiesFile[0];
  
  signalPropertiesFile[5] = "";
  
  signalPropertiesFile[6] = "# Total number of signals in the file.";
  signalPropertiesFile[7] = "numberOfSignals=2";
  
  signalPropertiesFile[8] = "";
  
  signalPropertiesFile[9] = "# Signal 1";
  signalPropertiesFile[10] = "signal1Name=adcSignal";
  signalPropertiesFile[11] = "signal1Size=2";
  signalPropertiesFile[12] = "signal1Type=analog";
  
  signalPropertiesFile[13] = "";
  
  signalPropertiesFile[14] = "# Signal 2";
  signalPropertiesFile[15] = "signal2Name=digitalSignal";
  signalPropertiesFile[16] = "signal2Size=1";
  signalPropertiesFile[17] = "signal2Type=digital";
  
  saveStrings("signals.properties",signalPropertiesFile);
}

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
  
  /* Divisor de resolución de capas */
  int lq_scale = 4;
  int slq_scale = 64;
  int ulq_scale = 512;
  
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
    
    GPointsArray points = new GPointsArray(dataVector.length);  // points of plot //<>//
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
    
    /* Los limites de los margenes estan directamente relacionado a la ubicacion de los puntos.
          Por como hago la escala de tiempo, el punto de indice 0 corresponde a la posicion en x del plano cero, y el punto indice 1 correcponde
          a la posicion x 0,1 */
    float[] xLim = plot1.getXLim();
    int indexA = int(xLim[0]) * 10;
    int indexB = int(xLim[1] * 10);
    
    switch(quality) {
      case 0:    // ful Res
        plot1.getLayer(layerName).drawPoints(indexA, indexB);
        plot1.getLayer(layerName).drawLines( true, indexA, indexB);
        break;
      case 1:    // low Qualy
        plot1.getLayer(lq_layerName).drawPoints(indexA/lq_scale, indexB/lq_scale); 
        plot1.getLayer(lq_layerName).drawLines( false, indexA/lq_scale, indexB/lq_scale);
        break;
      case 2:    // super low Qualy
        plot1.getLayer(slq_layerName).drawPoints(indexA/slq_scale, indexB/slq_scale);  
        plot1.getLayer(slq_layerName).drawLines( false, indexA/slq_scale, indexB/slq_scale);
        break; 
      case 3:    // ultra low Qualy
        plot1.getLayer(ulq_layerName).drawPoints(indexA/ulq_scale, indexB/ulq_scale);
        plot1.getLayer(ulq_layerName).drawLines( false, indexA/ulq_scale, indexB/ulq_scale);
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
  int pulseCounter = 0;    // contador de pulsos digitales (flanco ascendente)
  
  float plotOffset = 0;              // offset of the plot position
  boolean movingOffset = false;    // dictate if the plot is in panning mode
  float[] xLimitClone;              // clone of the X limit when calculating offset
   
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
      
      int currentValue = dataVector[x] > 0 ? 1 : 0;
      
      /* Si hay un cambio de dato grafico el actual y el anterior*/
      if( currentValue != lastValue ) {
        /* Añado el punto a la capa del plot */
        points.add( (x-1)*0.1, lastValue);
        points.add(x*0.1, currentValue );
        
        // Si el cambio fue de flanco ascendente sumo al contador de pulsos
        if( currentValue > lastValue ) {
          this.pulseCounter++;
        }
        
        lastValue = currentValue;
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
    digitalPlots[objectNumber].getRightAxis().setAxisLabelText("Digital CH" + str(objectNumber+1));
    digitalPlots[objectNumber].getRightAxis().getAxisLabel().setOffset(10);
    
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
    
    /* Set colors */
    digitalPlots[objectNumber].getLayer(layerName).setLineColor(color(0,0,255));
    digitalPlots[objectNumber].getLayer(layerName).setPointColor(color(0,0,255));
    digitalPlots[objectNumber].getLayer(layerName).setPointSize(3);
    
  }
  
  /* Draws this signal to the plot */
  void draw( int quality) {  // quality not used in digital, it will draw the minimun amount of points possibles
      
      // Draw the plot in the same position that the analog one, plus an offset
      if( !movingOffset ) {
        float[] xLim = plot1.getXLim();
        xLim[0] = xLim[0] + plotOffset;
        xLim[1] = xLim[1] + plotOffset;
        digitalPlots[objectNumber].setXLim( xLim );
      }
      digitalPlots[objectNumber].setYLim(new float[] { -0.1, 1.1});
      
      digitalPlots[objectNumber].beginDraw();
      digitalPlots[objectNumber].drawRightAxis();
      //digitalPlots[objectNumber].getLayer(layerName).drawPoints();  
      digitalPlots[objectNumber].getLayer(layerName).drawLines();
      digitalPlots[objectNumber].endDraw();
   }
  
  // Get the quantity of pulses detected in ascendent flank
  int getPulseCount () {
    return pulseCounter;
  }
  
  void applyPlotOffset() {
    if(movingOffset) {
      stopMovingPlotSignal();
    }
    else {
      startMovingPlotSignal();
    }
  }
  
  void startMovingPlotSignal() {
    this.movingOffset = true;
    
    plot1.deactivatePanning();  // deactivate the principal panning
    plot1.deactivateZooming();  // deactivate the principal zoom so no deformation occour
    
    xLimitClone = digitalPlots[objectNumber].getXLim();  // clone the actual limit
    
    // activate the panning of this plot for the user to move
    digitalPlots[objectNumber].activatePanning();
    
    // put a different color so the user can notise
    digitalPlots[objectNumber].getLayer(layerName).setLineColor(color(0,180,0));
    
  }
  
  void stopMovingPlotSignal() {
    
    //deactivate the panning
    digitalPlots[objectNumber].deactivatePanning();
    
    float[] currentLimit = digitalPlots[objectNumber].getXLim();  // get the current limit after user movement
    
    this.plotOffset = this.plotOffset + currentLimit[0] - xLimitClone[0];  // whit only one axis valua already can calc the offset becouse there is no zoom
    
    // return original color
    digitalPlots[objectNumber].getLayer(layerName).setLineColor(color(0,0,255));
    
    this.movingOffset = false;
    
    //reactivate zoom and panning in principal plot if this is the only signal panning
    for(int signal = 0; signal < maxNumberOfDigitalSignals; signal++) {
      if( digitalSignals[signal] != null && digitalSignals[signal].isUsed && digitalSignals[signal].isApplingPlotOffset() )      return;
    }
    plot1.activateZooming(1.2, CENTER, CENTER);
    plot1.activatePanning();
    // warning: code added after this may be not runned becouse RETURN is performed before
  }
  
  boolean isApplingPlotOffset() {
    return movingOffset;
  }
  
}
