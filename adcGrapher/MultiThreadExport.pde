/* Multi-thread export in .h	*/

final int numberOfThreadsToUse = 8;
volatile  int[] threadsInUse = new int[numberOfThreadsToUse];
int[] threadsProgress = new int[numberOfThreadsToUse];
String threadString[] = {"","","","","","","",""};

void mThreadExport ( ) {
	/* Get this number of thread*/
	int thisThreadIs = -1;
	int j = 0;
	while (thisThreadIs == -1) {

		if ( threadsInUse[j] == 0){
			thisThreadIs = j;
			threadsInUse[j] = 1;
      println("New Thread in use (" + j + ")");
		}
		j++;
	}
	
	/* Clear the string to use*/
	threadString[thisThreadIs] = "";

	/* Get the quantity of data point per thread*/
	int totalDataPoints = dataFiles[0].getRawDataQuantity();
	int thisThreadDataPoints = totalDataPoints / numberOfThreadsToUse;
	int thisThreadStartsIn = thisThreadDataPoints * thisThreadIs;

	if( thisThreadIs == (numberOfThreadsToUse-1) ) {
		thisThreadDataPoints = totalDataPoints - thisThreadStartsIn;
	}

	/* Cargo la string con los datos */
    for (int i = 0; i < thisThreadDataPoints; i++) {
      threadString[thisThreadIs] += dataFiles[0].getRawDataVectorIn(thisThreadStartsIn+i) + ", ";
      threadsProgress[thisThreadIs] = 100*i/thisThreadDataPoints;  // update the progress
    }

    /* Check this thread as completed */
    threadsProgress[thisThreadIs] = 100;
    //threadsInUse[thisThreadIs] = 0;
}
