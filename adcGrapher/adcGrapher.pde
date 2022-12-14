
// Libraries
import processing.javafx.*;
import grafica.*;
//import java.util.Random;
//import java.util.ArrayList;
import java.util.*;
import java.lang.Math;

// Grafica objects
GPlot plot1, plot2;

// An Array of dataFiles (.csv) to be loaded with seeds data each one
DataFile[] dataFiles;
final int dataFilesMax = 1;  // This means 4 as max files to be loaded at the same time
public int dataFileCount;  // Counts the files alredy loaded
public int dataPointCounter = 0;
public boolean firstTimeStarted = true;

// Predefined Plot Colors= {  R,   G,   B,Yell,Cyan,Mage,}
int[] predefinedColorR = {  255,   0,   0, 255,   0, 255,};
int[] predefinedColorG = {    0, 200,   0, 210, 255,   0,};
int[] predefinedColorB = {    0,   0, 255,   0, 255, 255,};

// Define the coordinates where to plot
final int plotFromX = 0;
final int plotFromY = 0;
final int plotToX = 680;
final int plotToY = 680;

// Define the version SW
final String swVersion = "1.0";
boolean debug = true;

public PImage imgConfig, imgDelete, imgExport, imgAdd, imgDerivative;

void settings() {
  size(1600, 800, PConstants.FX2D );
  //smooth(4);
}

void setup() {
  
  frameRate(30);
  background(255);
  randomSeed(99);
  
  // Set title bar and icon for Windows app
  PImage titlebaricon = loadImage("data/icon.png"); 
  if (titlebaricon != null){
    surface.setIcon(titlebaricon);
  }
  surface.setTitle("ADC Grapher (v" + swVersion + ")" ); 
  
  //Load images for program
  imgConfig = loadImage("data/gear.png");
  imgConfig.filter(GRAY);
  imgDelete = loadImage("data/delete.png");
  imgDelete.filter(GRAY);
  imgExport = loadImage("data/export.png");
  imgExport.filter(GRAY);
  imgAdd = loadImage("data/add.png");
  imgAdd.filter(GRAY);
  imgDerivative = loadImage("data/derivative.png");
  imgDerivative.filter(GRAY);
  
  // Check for new Updates
  //checkUpdates();
  
  
  dataFiles = new DataFile[dataFilesMax];
  dataFileCount = 0;
  
  plotMode = 0;
  
  
  noLoop();
  PFont font = createFont("Consolas", 12);
  textFont(font);
}

public int plotMode = 0, drawDerivative = 0;
void draw() {
  
  background(255);  // clear the previus draw
  
  // Draw the Plots
  switch (plotMode) {
    
    case 1:   // Timeline view
      plot1.beginDraw();
      plot1.drawBackground();
      plot1.drawBox();
      plot1.drawYAxis();
      plot1.drawXAxis();
      plot1.drawTitle();
      plot1.getLayer("noPulso").drawPoints();
      plot1.getLayer("pulsoDescendente").drawPoints();
      plot1.getLayer("pulsoAscendente").drawPoints();
      plot1.getLayer("pulsoInconsistente").drawPoints();
      plot1.getLayer("interest").drawPoints();
      plot1.getLayer("fondo").drawLines();
      plot1.drawLabels();
      plot1.endDraw();
      
      plot2.setXLim( plot1.getXLim() );
      
      if ( drawDerivative == 1 ) {
        plot2.beginDraw();
        plot2.drawRightAxis();
        plot2.drawPoints();
        plot2.drawLines();
        plot2.drawLabels();
        plot2.drawGridLines(GPlot.HORIZONTAL);
        plot2.endDraw();
      }
      
      tint(150, 180);
      image(imgDelete, width-10-20 , height-10-16, 24, 24);
      image(imgExport, width-10-20-30 , height-10-16, 24, 24);
      image(imgDerivative, width-10-20-63 , height-10-16, 26, 24);
    break;
    
    default:  // Default view
      tint(150, 180);
      imageMode(CENTER);
      image(imgAdd, width/2, height/2, 128, 128);
      imageMode(CORNER);
    break;
  }
  // Show information text arround the window
  showInfoText();
}

int helpNumber = 0;
int time = 0;
void showInfoText() {

  if ( millis() - time > 5000) {
    helpNumber ++;
    if ( plotMode == 0) {
      if ( helpNumber > 0 )  helpNumber = 0;
    }
    if ( plotMode == 1) {
      if ( helpNumber > 1 )  helpNumber = 0;
    }
    time = millis();
  }
  textAlign(LEFT);
  fill(0);
  if ( plotMode == 0) {
    switch ( helpNumber ) {
      case 0:
        text("Press 'n' to add a new file", 10, height-10);
      break;
    }
  }
  else if ( plotMode == 1) {
    switch ( helpNumber ) {
      case 0:
        text("Press 'Delete' to close the open file", 10, height-10);
      break;
      case 1:
        text("Press 'E' to export the file", 10, height-10);
      break;
    }
  }
  
  // Show FPS Counter if i'm in debug
  textAlign(LEFT);
  fill(150);
  if ( debug )
    text("FPS: " + nf(frameRate, 0, 2) , 10 , 10);
}

void loadingText() {
  fill(0);
  rect(width/2-100, height/2-40, 195, 60);
  
  textAlign(CENTER);
  fill(255);
  textSize(32);
  text("Loading...", width/2 , height/2);
  textSize(12);
}


void plot1SetConfig() {
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX*2-plotFromX+120, plotToY-plotFromY);
  
  // Set the plot title and the axis labels
  plot1.setTitleText("Timeline Representation of " + dataPointCounter + " Data Points");
  plot1.getXAxis().setAxisLabelText("Time [ms]");
  plot1.getYAxis().setAxisLabelText("ADC raw value");
  
  plot1.getYAxis().setLim(new float[] { 0, 4100});
  plot1.getYAxis().setNTicks( 10);
  plot1.getXAxis().setLim(new float[] { 0, 10});
  plot1.setFixedXLim(true);
  plot1.getXAxis().setNTicks( 10);
  
  // Set plot1 configs
  plot1.activatePointLabels();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
}

void plot2SetConfig() {
  // Create the second plot with the same dimensions
  plot2 = new GPlot(this);
  plot2.setPos(plot1.getPos());
  plot2.setMar(plot1.getMar());
  plot2.setDim(plot1.getDim());
  plot2.setAxesOffset(4);
  plot2.setTicksLength(4);
  
  plot2.getRightAxis().setAxisLabelText("ADC raw value derivative");
  
  // Make the right axis of the second plot visible
  plot2.getRightAxis().setDrawTickLabels(true);
  plot1.activatePointLabels();
}

void loadData(File selection) {
  if (selection == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "No file selected.", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
    loop();
    return;
  }
  String fileName = selection.getName(), fileNamePath = selection.getAbsolutePath();
  loadingText();
  
  // Initialize the new file
  dataFiles[dataFileCount] = new DataFile( fileName, fileNamePath );
  
  if (dataFileCount == 0 ) {
    plot1SetConfig();
    plot2SetConfig();
  }
  
  // Add Layers of the new file selected
  dataFiles[dataFileCount].plotData (plot1);
  dataFiles[dataFileCount].analyzeAndPlot();
  
  // Set the plot title
  plot1.setTitleText( dataPointCounter + " Data Points - "+ dataFiles[0].getSeedCount() + " semillas detectadas");
  plot1.setXLim(0, dataFiles[0].getRawDataQuantity()*0.1 );
  // Prepare for the next file
  dataFileCount++;
  
  plotMode = 1;
  
  loop();
  
  //plot1.setXLim(0,20);
  
  firstTimeStarted = false;
}


void exportFile (int numberExport) {
  if ( dataFileCount == 0 ) return;
  
  /*  Ask what type of file to export  */
  String[] options = {"1","2","3"};
  int format = javax.swing.JOptionPane.showOptionDialog(null,"Select the format to export the file:\n1-Vector in a C code format (.h)\n2-SeedAnalizer format (.csv)\n3-Statistical Data (.csv)", "Export File",
  javax.swing.JOptionPane.DEFAULT_OPTION, javax.swing.JOptionPane.INFORMATION_MESSAGE,
  null, options, options[0]);
  
  
  if ( format != -1 ) {
    /*  Export indicated File  */
    dataFiles[ numberExport ].exportToFile( format );
  }
  else {
    /*  Show error  */
    javax.swing.JOptionPane.showMessageDialog(null, "Error exporting the file!", "Export File", javax.swing.JOptionPane.ERROR_MESSAGE);
  }
  
}

public String timeStampsFilePath;
public boolean timeStampsFilePathLoaded;
public void setTimeStampsFile( File selection ) {
    if (selection == null) {
      javax.swing.JOptionPane.showMessageDialog(null, "No file selected.", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
      loop();
      return;
    }
    timeStampsFilePath = selection.getAbsolutePath();
    timeStampsFilePathLoaded = true;
}

void deleteFile () {
 if ( dataFileCount == 0 ) return;
 
 noLoop();
 
 dataFiles[0] = null;
 plot1 = null;
 plot2 = null;
 
 plotMode = 0;
 dataFileCount = 0;
 loop();
}


void mouseClicked() {
  
  if ( mouseButton == LEFT) {
    // If i press in add image
    if (mouseX >= width/2-64 && mouseX <= width/2+64 && mouseY >= height/2-64 && mouseY <= height/2+64 && plotMode == 0)
      addFile();
    
    if (mouseX >=  width-10-20 && mouseX <=  width && mouseY >=  height-10-16 && mouseY <=  height && plotMode == 1)
      deleteFile();
      
    if (mouseX >=  width-10-20-30 && mouseX <=  width-10-20-6 && mouseY >=  height-10-16 && mouseY <=  height && plotMode == 1)
      exportFile(0);
      
    if (mouseX >=  width-10-20-63 && mouseX <=  width-10-20-37 && mouseY >=  height-10-16 && mouseY <=  height && plotMode == 1) {
      if (drawDerivative == 1) drawDerivative = 0;
      else drawDerivative = 1;
    }
  }
  
  //image(imgExport, width-10-20-30 , height-10-16, 24, 24);
  //image(imgDerivative, width-10-20-63 , height-10-16, 26, 24);
}

void addFile() {
  if ( dataFileCount >= dataFilesMax ) {
    javax.swing.JOptionPane.showMessageDialog(null, "Max number of files reached.", "File Input Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
  } else {
    noLoop();
    File start1 = new File(sketchPath("")+"/*.txt");
    selectInput("Select a .txt file to representate", "loadData", start1);
  }
}

// Pressing 'n' will bring the window to select a new file to add to the plot
void keyReleased() {
  switch (key) {
    case 'N':
      if (plotMode != 0) return;
      addFile();
    break;
    case DELETE:
      deleteFile();
    break;
    case 'E':
      exportFile(0);
    break;
  }
}

void keyPressed() {
  switch (key) {
    case CODED:
      if (plotMode != 1) return;
      float[] yLim = plot1.getYLim();
      switch (keyCode) {
        case UP:
          if ( yLim[0] < 100 ) yLim[0]=50;
          if ( yLim[1] > 4000) yLim[1]=4050;
          plot1.setYLim ( yLim[0]-50 , yLim[1]+50);
        break;
        case DOWN:
          if ( yLim[1] - yLim[0] < 200 ) {
            yLim[0] -= 50;
            yLim[1] += 50;
          }
          plot1.setYLim ( yLim[0]+50 , yLim[1]-50);
        break;
      }
    break;
  }
}

// This function calls the main sketch code but with a uiScale parameter to work well on scaled displays in exported apps.
public static void main(String[] args) {
  
    System.setProperty("sun.java2d.uiScale", "1.0");
    System.setProperty("prism.allowhidpi","false");
    String[] mainSketch = concat(new String[] { adcGrapher.class.getCanonicalName() }, args);
    PApplet.main(mainSketch);
    
}
