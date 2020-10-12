# Sun f77
#
#  CPU timer and other local code
#

$CAT << {end-timer} > $MYCUTERPREC/config/timer
C
      REAL FUNCTION CPUTIM( DUM )
C
C  GIVES THE CPU TIME IN SECONDS.
C
C  THE REMAINING LINES SHOULD BE REPLACED BY A DEFINITION AND CALL
C  TO THE SYSTEM DEPENDENT CPU TIMING ROUTINE.
C
      REAL             DUM, ETIME, DUMMY( 2 )
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
