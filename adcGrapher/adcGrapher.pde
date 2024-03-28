
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

/* Signals in*/
public final int maxNumberOfAnalogSignals = 3;
public final int maxNumberOfDigitalSignals = 5;
public AnalogSignal[] analogSignals = new AnalogSignal[maxNumberOfAnalogSignals];
public DigitalSignal[] digitalSignals = new DigitalSignal[maxNumberOfDigitalSignals];

GPlot[] digitalPlots = new GPlot[maxNumberOfDigitalSignals];  // Digital Plots

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
final String swVersion = "0.07";
boolean debug = true;

public PImage imgConfig, imgDelete, imgExport, imgAdd, imgM;

void settings() {
  size(1600, 800, PConstants.FX2D );
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
  imgAdd = loadImage("data/add.png");
  imgAdd.filter(GRAY);
  
  // Check for new Updates
  thread("checkUpdates");
  
  dataFiles = new DataFile[dataFilesMax];
  dataFileCount = 0;
  
  plotMode = 0;
  
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
      if( analogSignals[0] != null) plot1.drawYAxis();
      plot1.drawXAxis();
      plot1.drawTitle();
      
      /* Segun zoom aplicado dibujo capa de baja calidad */
      float[] xLim = plot1.getXLim();
      int qualy;
      if(xLim[1] - xLim[0] < 3000)        
      {
        qualy = 0;   // full Res
      }
      else if (xLim[1] - xLim[0] < 13000)
      {
        qualy = 1;  // low Qualy
      }
      else if (xLim[1] - xLim[0] < 100000)
      {
        qualy = 2;  // super Low Qualy
      }
      else
      {
        qualy = 3;  // ultra Low Qualy
      }
      
      /* Call each analog signal to draw itself*/
      for(int signal = 0; signal < maxNumberOfAnalogSignals; signal++) {
        if( analogSignals[signal] != null && analogSignals[signal].isUsed)  analogSignals[signal].draw(qualy);
      }
      
      plot1.drawLabels();
      plot1.endDraw();
      
      /* Call each digital signal to draw itself*/
      for(int signal = 0; signal < maxNumberOfDigitalSignals; signal++) {
        if( digitalSignals[signal] != null && digitalSignals[signal].isUsed) digitalSignals[signal].draw(qualy);
      }
      
      /* Name of file*/
      textAlign(CENTER);
      fill(80);
      text("File: " + dataFiles[0].getFileName(), width/2, height-10);
      
      /* Quality used to show */
      textAlign(RIGHT);
      fill(150);
      text("Quality: " + qualy , width-10 , 10);
      
      /* Icons */
      tint(150, 180);
      image(imgDelete, width-10-20 ,    height-10-16, 24, 24);
      //image(imgExport, width-10-20-30 , height-10-16, 24, 24);
      //image(imgM,      width-10-20-60 , height-10-16, 24, 24);
    break;
    
    default:  // Default view
      tint(150, 180);
      imageMode(CENTER);
      image(imgAdd, width/2, height/2, 128, 128);
      imageMode(CORNER);
      textAlign(CENTER);
      textSize(14);
      text("Load a '.txt' or '.bin' file that contains ", width/2, (height/2)+130);
      text("a number of signals recorded represented by 'signals.properties'", width/2, (height/2)+148);
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


void plotSetConfig() {
  /* Plot 1: Analog Signals */
  
  // Create a new plot and set its position on the screen
  plot1 = new GPlot(this);
  plot1.setPos(plotFromX, plotFromY);
  plot1.setDim( plotToX*2-plotFromX+120, plotToY-plotFromY);
  
  // Set the plot title and the axis labels
  plot1.setTitleText("Timeline Representation of Signals");
  plot1.getXAxis().setAxisLabelText("Time [ms]");
  plot1.getYAxis().setAxisLabelText("ADC raw value");
  
  plot1.getYAxis().setLim(new float[] { 0, 4100});
  plot1.getYAxis().setNTicks( 10);
  
  plot1.getXAxis().setNTicks( 15);
  
  // Set plot1 configs
  plot1.activatePointLabels(RIGHT);
  plot1.activateZooming(1.2, CENTER, CENTER);
  plot1.activatePanning();
  
  /* Init all the digital plots with empty data */
  for(int i = 0; i < maxNumberOfDigitalSignals; i++) {
    digitalPlots[i] = new GPlot(this);
  }
  
}

void loadData(File selection) {
  if (selection == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "No file selected.", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
    loop();
    return;
  }
  String fileName = selection.getName(), fileNamePath = selection.getAbsolutePath();
  
  /*  Get if the file has the apropiated file extension */
  String ext = (fileName.substring( fileName.lastIndexOf(".")+1, fileName.length() )).toLowerCase();
  
  if(ext.equals("bin")==false && ext.equals("txt")==false) {
    javax.swing.JOptionPane.showMessageDialog(null, "Incompatible file extension.", "File Input Error", javax.swing.JOptionPane.WARNING_MESSAGE);
    return;
  }
  
  loadingText();
  
  /* Cargar descriptor de señales en archivo*/
  SignalDescriptor signalsInFile = getSignalPropierties( fileNamePath);
  
  /* Start the plot*/
  if (dataFileCount == 0 ) plotSetConfig();
  
  // Initialize the new file
  dataFiles[dataFileCount] = new DataFile( fileName, fileNamePath, signalsInFile);
  
  /* Auto zoom for the first file loaded only */
  if (dataFileCount == 0 ) {
    int b = dataFiles[0].getRawDataQuantity()/10;
    float[] a = {0, (float)b};
    //plot1.getXAxis().setLim(a);
    plot1.setXLim(a);
  } 
  
  // Prepare for the next file
  dataFileCount++;
  
  plotMode = 1;
  
  loop();
  
  firstTimeStarted = false;
}

void addFile() {
  if ( dataFileCount >= dataFilesMax ) {
    javax.swing.JOptionPane.showMessageDialog(null, "Max number of files reached.", "File Input Error", javax.swing.JOptionPane.INFORMATION_MESSAGE);
  } else {
    noLoop();
    File start1 = new File(sketchPath("")+"/*");
    selectInput("Select a .txt file to representate", "loadData", start1);
  }
}

void deleteFile () {
 if ( dataFileCount == 0 ) return;
 
 noLoop();
 
 dataFiles[0] = null;
 plot1 = null;
 
 /* Delete each analog signal */
  for(int signal = 0; signal < maxNumberOfAnalogSignals; signal++) {
    if( analogSignals[signal] != null )  analogSignals[signal] = null;
  }
      
  /* Delete each digital signal */
  for(int signal = 0; signal < maxNumberOfDigitalSignals; signal++) {
    if( digitalSignals[signal] != null )  digitalSignals[signal] = null;
  }
 
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

    case 'C':  // digital signal pulse counter
    String counterOutput = new String();
    
    /* Call each digital signal to return counter value */
    for(int signal = 0; signal < maxNumberOfDigitalSignals; signal++) {
      if( digitalSignals[signal] != null && digitalSignals[signal].isUsed) {
        
        counterOutput +=  "\nDigital CH" + str(signal+1) + ": " + digitalSignals[signal].getPulseCount();
        
      }
    }
    javax.swing.JOptionPane.showMessageDialog(null, counterOutput, "Digital Pulse Counter", javax.swing.JOptionPane.INFORMATION_MESSAGE);
    break;

    // Move digital signals
    case '1':
      if( digitalSignals[0] != null && digitalSignals[0].isUsed) digitalSignals[0].applyPlotOffset();
    break;
    case '2':
      if( digitalSignals[1] != null && digitalSignals[1].isUsed) digitalSignals[1].applyPlotOffset();
    break;
    case '3':
      if( digitalSignals[2] != null && digitalSignals[2].isUsed) digitalSignals[2].applyPlotOffset();
    break;
    case '4':
      if( digitalSignals[3] != null && digitalSignals[3].isUsed) digitalSignals[3].applyPlotOffset();
    break;
    case '5':
      if( digitalSignals[4] != null && digitalSignals[4].isUsed) digitalSignals[4].applyPlotOffset();
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
