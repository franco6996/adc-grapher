// A Seed class

class Seed {
  int item, timeStamp;
  int[] value = new int[101];
  boolean validSeed;
  float rmsValue;
  float avgValue, areaDerivada;
  
  private class Point {
  int x, y, type;
  float slope;
    Point(int x_ , int y_, int type_, float slope_){
      x = x_;
      y = y_;
      type = type_;
      slope = slope_;
    }
    
    int getX() {
      return x;
    }
    int getY() {
      return y;
    }
    int getType() {
      return type;
    }
    float getSlope() {
      return slope;
    }
  }
  Point[] points = new Point[1000];
  int pointsCount = 0;
  Point[] interestPoints = new Point[5];
  int interestPointsCount = 0;
  
  // Create  the Seed
  Seed(int item_, int time_, int value_, int type_, float slope_) {
    points[pointsCount] = new Point( time_ , value_, type_, slope_);
    interestPoints[interestPointsCount] = points[pointsCount];
    interestPointsCount++;
    pointsCount++;
    item = item_;
    timeStamp = time_;
    validSeed = true;
  }
  
  void addPoint(int time_, int value_, int type_, float slope_) {
    if (pointsCount == 10000 ) {
      print("\n\nSe alcanzó el numero máximo de puntos de datos por semilla! (" + pointsCount + ")\n");
      return; // no guarda el punto
    }
    
    points[pointsCount] = new Point( time_ , value_, type_, slope_);
    pointsCount++;
    
    if (pointsCount == 100 ) 
      print("\nSe alcanzó más de " + pointsCount + " puntos de datos en la semilla " + item); //<>//
    
  }
  
  int[] getPoint(int pointNumber_){
    int[] rtn = new int[3];
    rtn[0] = points[pointNumber_].getX();
    rtn[1] = points[pointNumber_].getY();
    rtn[2] = points[pointNumber_].getType();
    return rtn;
  }
  
  int getPointQuantity() {
    return pointsCount;
  }
  
  void addPointOfInterest(int x_, int y_) {
    interestPoints[interestPointsCount] = new Point( x_ , y_, 0, 0);
    interestPointsCount++;
  }
  
  int[] getPointOfInterest(int pointNumber_){
    int[] rtn = new int[3];
    rtn[0] = interestPoints[pointNumber_].getX();
    rtn[1] = interestPoints[pointNumber_].getY();
    rtn[2] = interestPoints[pointNumber_].getType();
    return rtn;
  }
  
  int getPointOfInterestQuantity() {
    return interestPointsCount;
  }
  
  void plot (GPlot plot_) {
    
    GPointsArray p1 = new GPointsArray(pointsCount);  // points of plot
    GPointsArray p2 = new GPointsArray(pointsCount);  // points of plot
    GPointsArray p3 = new GPointsArray(pointsCount);  // points of plot
    GPointsArray pd = new GPointsArray(pointsCount);  // points of plot
    for ( int i = 0; i < pointsCount ; i++ ){
      if ( points[i].getType() == 1 )
      p1.add(points[i].getX()*0.1, points[i].getY(), "("+ points[i].getX()*0.1 +","+ points[i].getY() +") Seed #" + item + " s:"+  points[i].getSlope() );
      if ( points[i].getType() == 2 )
      p2.add(points[i].getX()*0.1, points[i].getY(), "("+ points[i].getX()*0.1 +","+ points[i].getY() +") Seed #" + item + " s:"+  points[i].getSlope() );
      if ( points[i].getType() == 3 )
      p3.add(points[i].getX()*0.1, points[i].getY(), "("+ points[i].getX()*0.1 +","+ points[i].getY() +") Seed #" + item + " s:"+  points[i].getSlope() );
      
      pd.add(points[i].getX()*0.1, points[i].getSlope(), "(" + points[i].getSlope() + ")" );
    }
    plot_.getLayer("pulsoDescendente").addPoints(p1);
    plot_.getLayer("pulsoInconsistente").addPoints(p2);
    plot_.getLayer("pulsoAscendente").addPoints(p3);
  }
  
  void plotInterestPoints (GPlot plot_){
    GPointsArray p = new GPointsArray(interestPointsCount);  // points of plot
    for ( int i = 0; i < interestPointsCount ; i++ ){
      p.add(interestPoints[i].getX()*0.1, interestPoints[i].getY());
    }
    plot_.getLayer("interest").addPoints(p);
  }
  
  
  void calcRMSValue() {
    float sum = 0, rms = 0;
    
    /*  Sumatoria de los cuadrados de todos los puntos  */
    for( int i = 0; i < pointsCount ; i++) {
      sum += pow( points[i].getY(), 2 );
    }
    sum /= pointsCount;
    
    rms = sqrt( sum );
    
    rmsValue = rms;
    
  }
  
  void calcAvgValue() {
    float sum = 0, avg = 0;
    
    /*  Sumatoria de los cuadrados de todos los puntos  */
    for( int i = 0; i < pointsCount ; i++) {
      sum += points[i].getY();
    }
    avg = sum / pointsCount;
    
    avgValue = avg;
  }
  
  void calcAreaDerivada () {
    float area = 0;
    
    /*  Sumatoria de los cuadrados de todos los puntos  */
    for( int i = 0; i < pointsCount-1 ; i++) {
      area += ( points[i].getSlope() + points[i+1].getSlope() ) / 2;
    }
    
    areaDerivada = area;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////
  // Prepare to Display the values from one Seed
  void addLayer( String fileName_ , int dataFileIndex_) {
    
    if (validSeed == false)  // if the seed is invalid, it will not be ploted.
      return;
    
    String layerName = fileName_ + "." + str(dataFileIndex_) + ">" + str(item); //Conform the plot layer name as 'csvFileName.#>itemNumber'
    int nPoints = value.length;                       // number of value points in cvs file
    GPointsArray points = new GPointsArray(nPoints);  // points of plot
    for (int i = 0; i < nPoints; i++) {
      points.add(i, value[i]/*, "("+ i +","+ value[i] +") "+layerName*/);
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
      
    calcRMSValue();
    calcAvgValue();
    calcAreaDerivada();
      
    /*  Add row containing the data of this seed  */
    TableRow newRow = tableExport.addRow();
    newRow.setInt("#", item);
    newRow.setInt("timeStamp", timeStamp);
    newRow.setFloat("RMS", rmsValue);
    newRow.setFloat("Vmedio", avgValue);
    newRow.setFloat("AreaDerivada", areaDerivada);
    
    for (int i = 0; i < interestPointsCount; i++ ){
      newRow.setInt( "Px"+str(i) , interestPoints[i].getX() );
      newRow.setInt( "Py"+str(i) , interestPoints[i].getY() );
      
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
