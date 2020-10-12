# Compaq f95
#
#  CPU timer and other local code
#

$CAT << {end-timer} > $MYSIFDECPREC/config/timer
C
      REAL FUNCTION CPUTIM( DUM )
C
C  GIVES THE CPU TIME IN SECONDS.
C
C  THE REMAINING LINES SHOULD BE REPLACED BY A DEFINITION AND CALL
C  TO THE SYSTEM DEPENDENT CPU TIMING ROUTINE.
C
      REAL             ETIME, DUMMY( 2 )
C
C  OBTAIN THE CPU TIME.
C
      CPUTIM = ETIME( DUMMY )
      RETURN
C
C  END OF CPUTIM.
C
      END
{end-timer}
