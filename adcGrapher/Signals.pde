class SignalDescriptor{
  int[][] signalDescriptorVector;    /* [0]Signal Tipe: Analog = 0, Digital = 1 -  [1]Signal Bytes  */
  final int signalType = 0, signalSize = 1;
  int numberOfSignals;
  /*
  final int maxNumberOfAnalogSignals = 3;
  final int maxNumberOfDigitalSignals = 5;
  AnalogSignal[] analogSignals;
  DigitalSignal[] digitalSignals;*/
  
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
  
}

class AnalogSignal {
   
  
  AnalogSignal(){
   }
}


class DigitalSignal {
   
  
  DigitalSignal(){
    
   }
}
