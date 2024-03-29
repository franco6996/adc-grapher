
// Libraries
import processing.javafx.*;
import grafica.*;
//import java.util.Random;
//import java.util.ArrayList;
import java.util.*;
import java.lang.Math;

import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

// Grafica objects
GPlot plot1;
final public int plotMarkersMax = 30000;
public int[] plotMarkers = new int[plotMarkersMax];
public String[] plotMarkersText = new String[plotMarkersMax];
public int numberOfPlotMarkers = 0;
public boolean drawPlotMarkers = false;

// An Array of dataFiles (.csv) to be loaded with seeds data each one
DataFile[] dataFiles;
final int dataFilesMax = 1;  // This means 4 as max files to be loaded at the same time
public int dataFileCount;  // Counts the files alredy loaded
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
final String swVersion = "0.06";
boolean debug = true;

public PImage imgConfig, imgDelete, imgExport, imgAdd, imgM;

void settings() {
  size(1600, 800, PConstants.FX2D );
  
  //smooth(4);
}

void setup() {
  surface.setResizable(false);
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
  imgM = loadImage("data/m.png");
  imgM.filter(GRAY);
  
  // Check for new Updates
  thread("checkUpdates");
  
  dataFiles = new DataFile[dataFilesMax];
  dataFileCount = 0;
  
  plotMode = 0;
  
  
  //noLoop();
  PFont font = createFont("Consolas", 12);
  textFont(font);
  

}
int test = 0;
public int plotMode = 0;
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
      drawMarkers();
      
      /* Segun zoom aplicado dibujo capa de baja calidad */
      float[] xLim = plot1.getXLim();
      String layerToDraw;
      if(xLim[1] - xLim[0] < 3000)        
      {
        layerToDraw = "main"; 
      }
      else if (xLim[1] - xLim[0] < 13000)
      {
        layerToDraw = "lowQualy";
      }
      else
      {
        layerToDraw = "superLowQualy";
      }
      
      
      plot1.getLayer(layerToDraw).drawPoints();  
      plot1.getLayer(layerToDraw).drawLines();
      plot1.drawLabels();
      plot1.endDraw();
      
      /* Name of file*/
      textAlign(CENTER);
      fill(80);
      text("File: " + dataFiles[0].getFileName(), width/2, height-10);
      
      /* Icons */
      tint(150, 180);
      image(imgDelete, width-10-20 ,    height-10-16, 24, 24);
      image(imgExport, width-10-20-30 , height-10-16, 24, 24);
      image(imgM,      width-10-20-60 , height-10-16, 24, 24);
    break;
    
    default:  // Default view
      tint(150, 180);
      imageMode(CENTER);
      image(imgAdd, width/2, height/2, 128, 128);
      imageMode(CORNER);
      textAlign(CENTER);
      textSize(14);
      text("Load a '.txt' file that contains 16bits hexadecimal values", width/2, (height/2)+130);
      text("with no comma or separation", width/2, (height/2)+148);
    break;
  }
  
  // Show information text arround the window
  showInfoText();
}

void drawMarkers()
{
  if ( drawPlotMarkers == true)
  {
    float yMarkerPos1 =  plot1.getYLim()[0]+0.7*(plot1.getYLim()[1]-plot1.getYLim()[0])/2;
    float yMarkerPos2 =  plot1.getYLim()[0]+0.85*(plot1.getYLim()[1]-plot1.getYLim()[0])/2;
    float yMarkerPos3 =  plot1.getYLim()[0]+(plot1.getYLim()[1]-plot1.getYLim()[0])/2;
    float yMarkerPos4 =  plot1.getYLim()[0]+1.15*(plot1.getYLim()[1]-plot1.getYLim()[0])/2;
    for(int i=0; i< numberOfPlotMarkers; i++)
    {
      plot1.drawVerticalLine(plotMarkers[i]*0.1, 180, 2);  // dibujo la linea de marcador 
      if(plotMarkersText[i] == "RESET")
        plot1.drawAnnotation(plotMarkersText[i], plotMarkers[i]*0.1+0.01,yMarkerPos2, LEFT, CENTER); // le pongo el texto almacenado 
      else if(plotMarkersText[i] == "NO PULSO")
        plot1.drawAnnotation(plotMarkersText[i], plotMarkers[i]*0.1+0.01,yMarkerPos1, LEFT, CENTER); // le pongo el texto almacenado
      else if(plotMarkersText[i] == "FLANCO ASCENDENTE")
        plot1.drawAnnotation(plotMarkersText[i], plotMarkers[i]*0.1+0.01,yMarkerPos3, LEFT, CENTER); // le pongo el texto almacenado
      else
        plot1.drawAnnotation(plotMarkersText[i], plotMarkers[i]*0.1+0.01,yMarkerPos4, LEFT, CENTER); // le pongo el texto almacenado
    }
    
  }
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
      if ( helpNumber > 3 )  helpNumber = 0;
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
      case 2:
        text("Press 'M' to show markers of the pulses", 10, height-10);
      break;
      case 3:
        text("Press the Arrow Keys to expand or contract the graph", 10, height-10);
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
  plot1.setTitleText("Timeline Representation of " + nfc(dataFiles[0].getRawDataQuantity()) + " Data Points");
  plot1.getXAxis().setAxisLabelText("Time [ms]");
  plot1.getYAxis().setAxisLabelText("ADC raw value");
  
  plot1.getYAxis().setLim(new float[] { 0, 4100});
  plot1.getYAxis().setNTicks( 10);
  
  plot1.getXAxis().setNTicks( 10);
  plot1.setXLim(new float[] { 0, dataFiles[dataFileCount].getRawDataQuantity() /10 });
  plot1.setFixedXLim(true);
  
  // Set plot1 configs
  plot1.activatePointLabels();
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
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
  
  if (dataFileCount == 0 ) plot1SetConfig();
  
  // Add Layers of the new file selected
  dataFiles[dataFileCount].plotData( plot1 );
  
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
  String[] options = {".h",".csv"};
  int format = javax.swing.JOptionPane.showOptionDialog(null,"Select the format to export the file:\n-Vector in a C code format (.h)\n-SeedAnalizer format (.csv)", "Export File",
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
      
    if (mouseX >=  width-10-20-60 && mouseX <=  width-10-20-36 && mouseY >=  height-10-16 && mouseY <=  height && plotMode == 1)
    {
      if(drawPlotMarkers==false)
      {
        Boolean rtn_error = dataFiles[0].getMarkers();
        if( rtn_error == false) drawPlotMarkers = true;
      }
      else
      {
        drawPlotMarkers = false;
      }
    }
  }
  
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
    case 'M':
      if(drawPlotMarkers==false)
      {
        Boolean rtn_error = dataFiles[0].getMarkers();
        if( rtn_error == false) drawPlotMarkers = true;
      }
      else
      {
        drawPlotMarkers = false;
      }
      
    break;
  }
}

void keyPressed() {
  switch (key) {
    case CODED:
      if (plotMode != 1) return;  // si no tengo grafico activo salgo
      float[] yLim = plot1.getYLim();
      float[] xLim = plot1.getXLim();
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
        case LEFT:  // contraigo el grafico
          if ( xLim[0] < 100 ) xLim[0]=50;
          plot1.setXLim ( xLim[0]-50 , xLim[1]+50);
        break;
        case RIGHT:  // expando
          if ( xLim[1] - xLim[0] < 50 ) {
            break;
          }
          
          if ( xLim[1] - xLim[0] < 1000 ) {
            plot1.setXLim ( xLim[0]+15 , xLim[1]-15);
          }
          else
          {
            plot1.setXLim ( xLim[0]+50 , xLim[1]-50);
          }
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

/* Automatically called at user exit */
public void exit() {
    super.exit();
    System.exit(0);
}
