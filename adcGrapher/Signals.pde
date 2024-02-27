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
   boolean isUsed = false;
   int[] dataVector;
  
  AnalogSignal( int[] dataVector){
    isUsed = true;
    
    /* Reasigno este objeto al vector global para luego acceder globalmente */
    for( int i = 0; i < maxNumberOfAnalogSignals;i++) {
      if(analogSignals[i].isUsed == false) {
        analogSignals[i] = this;
      }
    }
    
    /* Guardo el vector de datos de la señal dentro de este objeto */
    this.dataVector = dataVector;
    
  }
}


class DigitalSignal {
   boolean isUsed;
  
  DigitalSignal(){
     isUsed = false;
  }
}
