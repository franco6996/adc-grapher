# ADC Grapher

## Introduction

This software is intended to represent in a graph the raw values of a microcontroller ADC.

## How to use

The input needs to be a .txt file with an hexadecimal representation of 16bit ADC values.

## Compile

Use Processing IDE to compile the source. The Grafica library is nedeed.

## Export App

1 - Using the Processing IDE, go to File > Export Application. This will generate a new folder, you can delete de 'source' folder inside it.

2 - The generated .exe has a generic icon. To change it go inside the folder 'data > icon replacer' and follow instructions.

3 - This app uses a modified version of the grafica library that processing do not auto include on export. To add the modified library on to the exported app:

	3.1 - Execute the app once through the processing IDE (clic on play).
	
	3.2 - Go to %temp%/processing/ folder. Inside search for  a temp folder (something like 'adcGrapherxxxxxxtemp') and then a 'grafica' folder. The will be some .class files. You will uses these in the next step.
	
	3.3 - Go to the exported application, open the lib/grafica.jar file with a tool like 7zip or winrar. You need to replace the files inside the grafica folder of the .jar with the ones searched in the last step.

