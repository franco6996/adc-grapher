// Trend of the slope of a signal class

class Trend {
  int[] values;    /**<Values from which the slope is estimated.  */
  float slope;              /**<Coefficient of the slope.  */
  int slopeRate;            /**<Stores if coeff if increasing or decreasing  */
  final int VALUES_TO_ANALYZE = 4;

  Trend(int initialValue) {
    values = new int[VALUES_TO_ANALYZE];
      /* Init the vector with the set value */
    for (int i = 0; i < VALUES_TO_ANALYZE; i++) {
      values[i] = initialValue;
    }
  
    /* Set the coeff and it's rate as stable */
    slope = 0;
    slopeRate = 0;
  }


  void estimate(int newValue) {
  
      /* Update the vector from where the slope is estimated */
    for (int i = 0; i < (VALUES_TO_ANALYZE-1); i++) {
        values[i] = values[i+1];
    }
    values[ (VALUES_TO_ANALYZE-1) ] = newValue;

    /* Get the average of half the vector */
    float avg1 = 0;
    for (int i = 0; i < VALUES_TO_ANALYZE/2; i++) {
        avg1 += values[i];
    }
    avg1 /= (VALUES_TO_ANALYZE/2);

    /* Get the average of the other half */
    float avg2 = 0;
    for (int i = VALUES_TO_ANALYZE/2; i < VALUES_TO_ANALYZE; i++) {
        avg2 += values[i];
    }
    avg2 /= (VALUES_TO_ANALYZE/2);

    /* Get the new coeff */
    float coeff = (avg2 - avg1) / (VALUES_TO_ANALYZE/2);

    /* Calculate the rate comparing with the last known rate */
    if ( slope > coeff ) slopeRate = -1;   // Decreasing
    if ( slope < coeff ) slopeRate = 1;   // Increasing
    if ( slope == coeff ) slopeRate = 0;  // Stable

    /* Save the new coeff */
    slope = coeff;
  }

  /*******************************************************************************************************************************//**
   * @brief      Return the last coefficient of the slope that was estimated.
   * @return     int16_t  Coefficient of the slope. Negative if it is a descending flank, positive if it is an ascending flank.
   **********************************************************************************************************************************/
  float getSlope() {
    return slope;
  }
  
  /*******************************************************************************************************************************//**
   * @brief      Returns if the value of the coefficient is ascending o decreasing.
   * @return     uint8_t  If increasing = 1, decreasing = -1, stable = 0
   **********************************************************************************************************************************/
  int getSlopeRate() {
    return slopeRate;
  }
  
}
