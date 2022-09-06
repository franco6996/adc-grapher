// A Seed class

class Seed {
  int item, timeStamp;
  int[] value = new int[101];
  boolean validSeed;
  
  // Create  the Seed
  Seed(int item_, int timeStamp_, int[] value_) {
    item = item_;            // # of seed
    timeStamp = timeStamp_;  // time stamp of min value of signal
    value = value_;          /* array of 101 elements, wich contains the value of ADC every 100us.
                                value[50] corresponds to the min of the signal */
    
    // if the seed contains a 0 value in the first ADC measure is invalid, it should contain the aprox DAC value
    if ( value[0] == 0 )
      validSeed = false;
    else
      validSeed = true;
  }
  
  // Prepare to Display the values from one Seed
  void addLayer( String fileName_ , int dataFileIndex_) {
    
    if (validSeed == false)  // if the seed is invalid, it will not be ploted.
      return;
    
    String layerName = fileName_ + "." + str(dataFileIndex_) + ">" + str(item); //Conform the plot layer name as 'csvFileName.#>itemNumber'
    int nPoints = value.length;                       // number of value points in cvs file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      points.add(i, value[i], "("+ i +","+ value[i] +") "+layerName);
    }
    plot1.addLayer(layerName, points);     // add points to the layer
    
    // Set layer Color
    int colorR, colorG, colorB, colorA;
    colorA = 160; // color Alpha is transparency: 255 = opaque , 0 = translucent
    if (dataFileCount < 1){  // If only have one file, set a random color
      colorR = int(random(10,255));
      colorG = int(random(10,255));
      colorB = int(random(10,255));
    }
    else {  // with multiple files select predefined colors up to 6
      colorR = predefinedColorR[ dataFileIndex_ ];
      colorG = predefinedColorG[ dataFileIndex_ ];
      colorB = predefinedColorB[ dataFileIndex_ ];
    }
    plot1.getLayer(layerName).setLineColor(color(colorR, colorG, colorB, colorA));
    plot1.getLayer(layerName).setPointColor(color(colorR, colorG, colorB, colorA));
    plot1.getLayer(layerName).setFontColor(50);
    plot1.getLayer(layerName).setFontSize(12);
    plot1.getLayer(layerName).setFontName("Consolas");
    plot1.getLayer(layerName).setLabelBgColor(220);
  }
  
  // Remove one leyer (one seed) from the plot
  void removeLayer ( String fileName_ , int dataFileIndex_) {
    
    if (validSeed == false)  // if the seed is invalid, no layer exist in the plot of itself.
      return;
    
    String layerName = fileName_ + "." + str(dataFileIndex_) + ">" + str(item); //Conform the plot layer name as 'csvFileName.#>itemNumber'
    plot1.removeLayer( layerName );
  }
  
  // Adds the values of the seed to the passed layer
  void addPointsToLayer(String layerName_, int zeroTime_) {
    if (validSeed == false) return; // if the seed is invalid, it will not be ploted.
      
    int nPoints = value.length;                       // number of value points in cvs file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    int timeWhereToPlot = timeStamp - zeroTime_;
    for (int i = 0; i < nPoints; i++) {
      int xPos = i + timeWhereToPlot - int(value.length / 2);
      points.add( xPos, value[i], "("+ xPos +","+ value[i] +") #"+item);
    }
    //plot3.addPoints( points, layerName_);     // add points to the desired layer
  }
  
  int getTimeStamp() {
    if (validSeed == false)  // if the seed is invalid, no layer exist in the plot of itself.
      return -1;
      
    return timeStamp;
  }
  
  // Returns the delta adc value between the first value of vector and the min
  int getDeltaV() {
    if (validSeed == false)
      return -1;
      
    int deltaV;
    deltaV = abs( value[0] - value[50] );
    
    return deltaV;
  }
  
  // Remove one leyer (one seed) from the plot
  boolean getValidSeed () {
    
    return validSeed;
  }
  
  // 
  String getNearPointAt ( String fileName_ , int dataFileIndex_, float mouseX_, float mouseY_) {
    
    if (validSeed == false)  // if the seed is invalid, no layer exist in the plot of itself.
      return null;
    
    String layerName = fileName_ + "." + str(dataFileIndex_) + ">" + str(item); //Conform the plot layer name as 'csvFileName.#>itemNumber'
    if ( plot1.getPointAt(mouseX_,mouseY_,layerName ) != null)
      return layerName;
    else
      return null;
  }
  
  void setInvalid () {
    validSeed = false;
  }
  
  int getItem() {
    return item;
  }
  
  void addSeedToTable( Table tableExport ) {
    if (validSeed == false)  // if the seed is invalid, not add the seed.
      return;
    /*  Add row containing the data of this seed  */
    TableRow newRow = tableExport.addRow();
    newRow.setInt("#", item);
    newRow.setInt("timeStamp", timeStamp);
    for (int i = 0; i<101; i++ ){
      newRow.setInt( str(i) , value[i]);
    }
  }
  
  String getDataOnString (){
    if (validSeed == false)  // if the seed is invalid, not add the seed.
      return null;
    
    /*  Conform the string  */
    String data = "{" + value[0];
    for (int i = 1; i<101; i++ ){
      data += "," + value[i];
    }
    data += "}";
    
    return data;
  }
}
