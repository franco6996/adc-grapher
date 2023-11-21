// Trend of the slope of a signal class

class PulseChecker {
  int[] last_values;    /**<Values from which the slope is estimated.  */
  float current_coeff;              /**<Coefficient of the slope.  */
  int coeff_tendency;            /**<Stores if coeff if increasing or decreasing  */
  
  int false_positive_pulse_detected = 0;
  
  final int SLOPE_VALUES_TO_ANALYZE = 4;
  final int SLOPE_COEFF_DECREASING = -1;
  final int SLOPE_COEFF_STABLE = 0;
  final int SLOPE_COEFF_INCREASING = 1;
  
  
  final int FSM_RESET = 0;      /**< Reset State, initial state  */
  final int FSM_NO_PULSE = 1;      /**< No pulse, the receiving signal is planar  */
  final int FSM_DESCENDING_FLANK = 2;  /**< Receiving signal is in a descending flank  */
  final int FSM_ASCENDING_FLANK = 3;
  
  int fsm_state = FSM_RESET;
  
  int slope_coeff_trigger = 80;      /**< Coefficient of the signal slope to trigger a change in the pulse received  */
  
  final int is_filter_enabled = 1;    /**< Flag to enable or disable the filter of the pulse  */
  final int filter_amplitude_max = 4000;  /**< Max value of ADC counts allowed to a pulse be considered as a seed  */
  final int filter_amplitude_min = 50;  /**< Min value of ADC counts allowed  */
  final int filter_width_max = 150;    /**< Max width of the pulse  allowed  to be considered as a seed */
  final int filter_width_min = 7;    /**< Min width of the pulse  allowed  */

  PulseChecker(int initialValue, int slope_coeff) {
    slope_coeff_trigger = slope_coeff;
    
    last_values = new int[SLOPE_VALUES_TO_ANALYZE];
      /* Init the vector with the set value */
    for (int i = 0; i < SLOPE_VALUES_TO_ANALYZE; i++) {
      last_values[i] = initialValue;
    }
  
    /* Set the coeff and it's rate as stable */
    current_coeff = 0;
    coeff_tendency = 0;
  }
  
  void slope_estimate(int value)
  {
    /* Update the vector from where the slope is estimated */
  for (int i = 0; i < (SLOPE_VALUES_TO_ANALYZE-1); i++) {
        last_values[i] = last_values[i+1];
    }
  last_values[ (SLOPE_VALUES_TO_ANALYZE-1) ] = value;

    /* Get the average of half the vector */
    int avg1 = 0;
    for (int i = 0; i < SLOPE_VALUES_TO_ANALYZE/2; i++) {
        avg1 += last_values[i];
    }
    avg1 /= (SLOPE_VALUES_TO_ANALYZE/2);

    /* Get the average of the other half */
    int avg2 = 0;
    for (int i = SLOPE_VALUES_TO_ANALYZE/2; i < SLOPE_VALUES_TO_ANALYZE; i++) {
        avg2 += last_values[i];
    }
    avg2 /= (SLOPE_VALUES_TO_ANALYZE/2);

    /* Get the new coeff */
    int new_coeff = 10 * (avg2 - avg1) / (SLOPE_VALUES_TO_ANALYZE/2);

    /* Calculate the rate comparing with the last known rate */
    if ( current_coeff > new_coeff )
    {
        coeff_tendency = SLOPE_COEFF_DECREASING;     // Slope coefficient is decreasing
    }
    else if ( current_coeff < new_coeff )
    {
      coeff_tendency = SLOPE_COEFF_INCREASING;     // Slope coefficient is increasing
    }
    else if ( current_coeff == new_coeff )
    {
      coeff_tendency = SLOPE_COEFF_STABLE;      // Slope coefficient is stable
    }

    /* Save the new coeff */
    current_coeff = new_coeff;
  }
  
  int run (int currentValue)
  {
    
    slope_estimate(currentValue);
    
    fsm_run( currentValue);
    
    return fsm_state;
  }
  
  void fsm_run( int adc_value)
  {
    
    if ( fsm_state > FSM_ASCENDING_FLANK )
    {
      fsm_state = FSM_RESET;
    }
    
    switch(fsm_state)
    {
        case FSM_RESET:
        {
          fsm_state = FSM_NO_PULSE;
          break;
        }
        case FSM_NO_PULSE:
        {
          /*  If a descending flank in the signal is detected  */
          if ( (current_coeff < (-slope_coeff_trigger) ) && (SLOPE_COEFF_DECREASING == coeff_tendency) )
          {
                fsm_state = FSM_DESCENDING_FLANK;
          }
          break;
        }
        case FSM_DESCENDING_FLANK:
        {
          /*  If an ascending flank is detected in the signal  */
          if ( (current_coeff > ((slope_coeff_trigger)/2) ) && (SLOPE_COEFF_INCREASING == coeff_tendency) )
          {
                fsm_state = FSM_ASCENDING_FLANK;
          }
          
          /*  Protect for false positives, if a pulse is flat for  40 ticks (4ms) the state machine will be reseted */
          if( (abs(current_coeff) <= 30) )
          {
            false_positive_pulse_detected++;
            if ( false_positive_pulse_detected == 30 )
            {
              false_positive_pulse_detected = 0;
              /* Reset the FSM */
              fsm_state = FSM_NO_PULSE;
            }
          }
          else
          {
            false_positive_pulse_detected = 0;
          }
          
          break;
        }
        case FSM_ASCENDING_FLANK:
        {
          /*  If a stable signal after an ascending flank is detected, it means that a correct pulse was detected */
          if ( (current_coeff < slope_coeff_trigger) && (SLOPE_COEFF_DECREASING == coeff_tendency) )
          {
      
            /*  Reset the FSM  */
              fsm_state = FSM_RESET;
          }
          break;
        }
      
    }
    
  }
  
  /* Get the costant values of each fsm state */
  int fsm_reset() { return FSM_RESET;} 
  int fsm_no_pulse() { return FSM_NO_PULSE;} 
  int fsm_descending_flank() { return FSM_DESCENDING_FLANK;} 
  int fsm_ascending_flank() { return FSM_ASCENDING_FLANK;} 
  
}
