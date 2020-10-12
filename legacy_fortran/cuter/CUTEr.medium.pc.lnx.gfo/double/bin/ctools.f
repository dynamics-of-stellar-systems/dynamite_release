C
C MATLAB gateway routine to constrained CUTE tools
C
      SUBROUTINE  MEXFUNCTION( NLHS, PLHS, NRHS, PRHS )
      INTEGER*4   NLHS, NRHS
      INTEGER*4   PLHS( * ), PRHS( * )
C
      INTEGER*4   MXCREATEFULL, MXGETPR
C      INTEGER*4   MXGETM, MXGETN
      REAL*8      MXGETSCALAR
C
C  Parameters which may be changed by the user.
C
      INTEGER*4        NMAX  , MMAX
CCUS  PARAMETER      ( NMAX =2000, MMAX =2000 )
CBIG  PARAMETER      ( NMAX =2000, MMAX =2000 )
      PARAMETER      ( NMAX = 100, MMAX = 100 )
CTOY  PARAMETER      ( NMAX =  10, MMAX =  10 )
      INTEGER*4        NNZMAX, NNZIMAX
      PARAMETER      ( NNZMAX = 10*NMAX, NNZIMAX = NMAX/10 )
      INTEGER*4        INPUT , IOUT
      PARAMETER      ( INPUT = 55, IOUT = 6 )
C
C  End of Parameters which may be changed by the user.
C
      CHARACTER*64     PRBDAT
      CHARACTER*10     PNAME
      CHARACTER*10     XNAMES( NMAX )
      CHARACTER*10     GNAMES( MMAX )
      INTEGER*4        NVAR, NCON, NNZSH, NNZSCJ, NNZA, NNZB, NNZGCI
      INTEGER*4        EQUATN( MMAX ), LINEAR( MMAX )
      INTEGER*4        JCOLA ( NMAX + 1 ), JCOLB( NMAX + 1 )
      INTEGER*4        IRNSH ( NNZMAX ), ICNSH ( NNZMAX ),
     *                 INDVAR( NNZMAX ), INDFUN( NNZMAX ),
     *                 IROWA ( NNZMAX )
      INTEGER*4        IROWB ( NMAX ), INDVARI( NNZIMAX ),
     *                 ONES( NMAX+1 )
      REAL*8           F
      REAL*8           X( NMAX ), BL( NMAX ), BU( NMAX ), G( NMAX ),
     *                 P( NMAX ), Q ( NMAX ), B ( NMAX )
      REAL*8           V( MMAX ), CL( MMAX ), CU( MMAX ), C( MMAX )
      REAL*8           CJAC( NMAX*MMAX )
      REAL*8           DH( NMAX*NMAX ), DHI( NMAX * NMAX )
      REAL*8           SH   ( NNZMAX ), SCJAC( NNZMAX ), A( NNZMAX ),
     *                 SGCI( NNZIMAX )
      LOGICAL          GRAD, GOTH, EFIRST, LFIRST, NVFRST, JTRANS,
     *                 GRLAGF
C
C  Common block to store problem dimensions.
C
      COMMON / SIZE /  NVAR, NCON
C
C  Local variables
C
      INTEGER*4        PR, IR, JC, IERR, IPTR, N, NN, NP1, LC1, LC2,
     *                 I, J, PR2, PR3, M, NNZ
      REAL*8           WORKN( NMAX*10 ), WORKM( MMAX*10 )
      INTEGER*4        IVARTY( NMAX )
      REAL*8           IVARTY_real( NMAX )
      CHARACTER*7      TOOL, TSETUP, TNAMES, TFN, TGR, TOFG, TSGR,
     *                 TCFG, TSCFG, TDH, TGRDH, TSH, TSGRSH, TPROD,
     *                 TCFSG, TCIFG, TDIMEN, TDIMSH, TDIMSJ, TVARTY,
     *                 TCIFSG, TSCIFG, TIDH, TISH, TSH1
      CHARACTER*150    MSG
      REAL*8           CI, GCI( NMAX ), N_real, M_real, NNZ_real
C
C  External functions
C
      CHARACTER*100  NULLSTR, UPPER
      LOGICAL        EQUAL
C
C  Check for at least one input argument,
C  which is the name of the tool to be called.
C
      IF ( NRHS .EQ. 0 ) THEN
         MSG = 'CTOOLS REQUIRES AT LEAST ONE INPUT ARGUMENT.'
         CALL MEXERRMSGTXT( MSG )
      END IF
C
C  Get name of unconstrained tool being called.
C  Null-terminate this name and convert it to upper case.
C
      IERR = MXGETSTRING( PRHS( 1 ), TOOL, 6 )
      IF ( IERR .EQ. 0 ) THEN
         TOOL = NULLSTR( TOOL )
         TOOL = UPPER  ( TOOL )
      ELSE
         MSG = 'ERROR COPYING TOOL NAME FROM FIRST INPUT ARGUMENT.'
         CALL MEXERRMSGTXT( MSG )
      END IF
C
C  Set up tool names.
C
      TSETUP = NULLSTR( 'CSETUP' )
      TNAMES = NULLSTR( 'CNAMES' )
      TFN    = NULLSTR( 'CFN' )
      TGR    = NULLSTR( 'CGR' )
      TOFG   = NULLSTR( 'COFG' )
      TSGR   = NULLSTR( 'CSGR' )
      TCFG   = NULLSTR( 'CCFG' )
      TSCFG  = NULLSTR( 'CSCFG' )
      TCFSG  = NULLSTR( 'CCFSG' )
      TDH    = NULLSTR( 'CDH' )
      TGRDH  = NULLSTR( 'CGRDH' )
      TSH    = NULLSTR( 'CSH' )
      TSH1   = NULLSTR( 'CSH1' )
      TSGRSH = NULLSTR( 'CSGRSH' )
      TPROD  = NULLSTR( 'CPROD' )
      TCIFG  = NULLSTR( 'CCIFG' )
      TCIFSG  = NULLSTR( 'CCIFSG' )
      TSCIFG  = NULLSTR( 'CSCIFG' )
      TDIMEN  = NULLSTR( 'CDIMEN' )
      TDIMSH  = NULLSTR( 'CDIMSH' )
      TDIMSJ  = NULLSTR( 'CDIMSJ' )
      TVARTY  = NULLSTR( 'CVARTY' )
      TIDH  = NULLSTR( 'CIDH' )
      TISH  = NULLSTR( 'CISH' )
C
C  Call the requested tool.
C
      IF ( EQUAL( TOOL, TSETUP ) ) THEN
C
C  Check for proper number of arguments.
C
         IF ( NRHS .NE. 1 .AND. NRHS .NE. 2 ) THEN
            MSG = 'CSETUP REQUIRES EITHER ZERO OR ONE INPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 6 .AND. NLHS .NE. 8 ) THEN
            MSG = 'CSETUP RETURNS EITHER SIX OR EIGHT OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Set EFIRST, LFIRST, and NVFRST based on input arguments (if any).
C
         EFIRST = .FALSE.
         LFIRST = .FALSE.
         NVFRST = .FALSE.
         IF ( NRHS .EQ. 2 ) THEN
            IPTR = PRHS( 2 )
            CALL GETVEC( IPTR, WORKN, 3, NN )
            IF ( NINT( WORKN( 1 ) ) .NE. 0 ) EFIRST = .TRUE.
            IF ( NINT( WORKN( 2 ) ) .NE. 0 ) LFIRST = .TRUE.
            IF ( NINT( WORKN( 3 ) ) .NE. 0 ) NVFRST = .TRUE.
         END IF
C
C  Build data input file name.
C
         PRBDAT = 'OUTSDIF.d'
C
C  Open the relevant file.
C
         OPEN ( INPUT, FILE = PRBDAT, FORM = 'FORMATTED',
     *          STATUS = 'OLD' )
         REWIND INPUT
C
C  Set up the problem data structures.
C
         CALL CSETUP( INPUT , IOUT  , NVAR, NCON, X , BL, BU, NMAX,
     *                EQUATN, LINEAR, V , CL, CU, MMAX,
     *                EFIRST, LFIRST, NVFRST )
C
C  Copy X.
C
         PLHS( 1 ) = MXCREATEFULL( NVAR, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( X, PR, NVAR )
C
C  Copy BL.
C
         PLHS( 2 ) = MXCREATEFULL( NVAR, 1, 0 )
         PR = MXGETPR( PLHS( 2 ) )
         CALL MXCOPYREAL8TOPTR( BL, PR, NVAR )
C
C  Copy BU.
C
         PLHS( 3 ) = MXCREATEFULL( NVAR, 1, 0 )
         PR = MXGETPR( PLHS( 3 ) )
         CALL MXCOPYREAL8TOPTR( BU, PR, NVAR )
C
C  Copy V.
C
         PLHS( 4 ) = MXCREATEFULL( NCON, 1, 0 )
         PR = MXGETPR( PLHS( 4 ) )
         CALL MXCOPYREAL8TOPTR( V, PR, NCON )
C
C  Copy CL.
C
         PLHS( 5 ) = MXCREATEFULL( NCON, 1, 0 )
         PR = MXGETPR( PLHS( 5 ) )
         CALL MXCOPYREAL8TOPTR( CL, PR, NCON )
C
C  Copy CU.
C
         PLHS( 6 ) = MXCREATEFULL( NCON, 1, 0 )
         PR = MXGETPR( PLHS( 6 ) )
         CALL MXCOPYREAL8TOPTR( CU, PR, NCON )
C
C  If eight output arguments are required, copy EQUATN and LINEAR.
C
         IF ( NLHS .EQ. 8 ) THEN
            DO 100 I = 1, NCON
               WORKM( I ) = DFLOAT( EQUATN( I ) )
  100       CONTINUE
            PLHS( 7 ) = MXCREATEFULL( NCON, 1, 0 )
            PR = MXGETPR( PLHS( 7 ) )
            CALL MXCOPYREAL8TOPTR( WORKM, PR, NCON )
            DO 110 I = 1, NCON
               WORKM( I ) = DFLOAT( LINEAR( I ) )
  110       CONTINUE
            PLHS( 8 ) = MXCREATEFULL( NCON, 1, 0 )
            PR = MXGETPR( PLHS( 8 ) )
            CALL MXCOPYREAL8TOPTR( WORKM, PR, NCON )
         END IF
C
     CLOSE( INPUT )
C
      ELSE IF ( EQUAL( TOOL, TNAMES ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 1 .AND. NRHS .NE. 3 ) THEN
            MSG = 'CNAMES REQUIRES ZERO OR TWO INPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 3 ) THEN
            MSG = 'CNAMES RETURNS THREE OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Get number of variable and constraint names requested.
C
         N = NVAR
         M = NCON
         IF ( NRHS. EQ. 3 ) THEN
            N = NINT( MXGETSCALAR( PRHS( 2 ) ) )
            IF ( N .LT. 1 .OR. N .GT. NVAR ) THEN
               MSG = 'INVALID NUMBER OF VARIABLE NAMES REQUESTED.'
               CALL MEXERRMSGTXT( MSG )
            END IF
            M = NINT( MXGETSCALAR( PRHS( 3 ) ) )
            IF ( M .LT. 1 .OR. M .GT. NCON ) THEN
               MSG = 'INVALID NUMBER OF CONSTRAINT NAMES REQUESTED.'
               CALL MEXERRMSGTXT( MSG )
            END IF
         END IF
         CALL CNAMES( NVAR, NCON, PNAME, XNAMES, GNAMES )
C
C  Copy PNAME, XNAMES, and GNAMES.
C  First convert XNAMES and GNAMES to REAL*8 arrays.
C
         PLHS( 1 ) = MXCREATESTRING( PNAME )
         CALL CNVCHR( XNAMES, N, 10, WORKN )
         CALL CNVCHR( GNAMES, M, 10, WORKM )
         PLHS( 2 ) = MXCREATEFULL( N, 10, 0 )
         NN = N*10
         PR = MXGETPR( PLHS( 2 ) )
         CALL MXCOPYREAL8TOPTR( WORKN, PR, NN )
         PLHS( 3 ) = MXCREATEFULL( M, 10, 0 )
         NN = M*10
         PR = MXGETPR( PLHS( 3 ) )
         CALL MXCOPYREAL8TOPTR( WORKM, PR, NN )
C
      ELSE IF ( EQUAL( TOOL, TFN ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 2 ) THEN
            MSG = 'CFN REQUIRES CURRENT ITERATE AS INPUT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 2 ) THEN
            MSG = 'CFN RETURNS TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Get the objective function value.
C
         CALL CFN( N, NCON, X, F, NCON, C )
C
C  Copy F.
C
         PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( F, PR, 1 )
C
C  Copy C.
C
         PLHS( 2 ) = MXCREATEFULL( NCON, 1, 0 )
         PR = MXGETPR( PLHS( 2 ) )
         CALL MXCOPYREAL8TOPTR( C, PR, NCON )
C
      ELSE IF ( EQUAL( TOOL, TGR ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .LT. 2 .OR. NRHS .GT. 4 ) THEN
            MSG = 'CGR REQUIRES ONE, TWO, OR THREE INPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 2 ) THEN
            MSG = 'CGR RETURNS TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Set defaults for GRLAGF and JTRANS.
C
         JTRANS = .FALSE.
         GRLAGF = .FALSE.
C
C  Copy third input argument (if given) into V.
C  Set default for GRLAGF to .TRUE. in this case.
C
         M = NCON
         IF ( NRHS .GE. 3 ) THEN
            IPTR = PRHS( 3 )
            CALL GETVEC( IPTR, V, NCON, M )
            GRLAGF = .TRUE.
         END IF
C
C  Adjust JTRANS and GRLAGF based on fourth input argument, if any.
C
         IF ( NRHS .EQ. 4 ) THEN
            IPTR = PRHS( 4 )
            CALL GETVEC( IPTR, WORKN, 2, NN )
            IF ( NINT( WORKN( 1 ) ) .NE. 0 ) JTRANS = .TRUE.
            IF ( NINT( WORKN( 2 ) ) .NE. 0 ) GRLAGF = .TRUE.
         END IF
C
C  Set dimensions of CJAC based on JTRANS.
C
         IF ( .NOT. JTRANS ) THEN
            LC1 = M
            LC2 = N
         ELSE
            LC1 = N
            LC2 = M
         END IF
C
C  Get the gradient of the objective and constraint functions.
C
         CALL CGR( N, M, X, GRLAGF, M, V, G, JTRANS, LC1, LC2, CJAC )
C
C  Copy G.
C
         PLHS( 1 ) = MXCREATEFULL( N, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( G, PR, N )
C
C  Copy CJAC.
C
         NN = LC1*LC2
         PLHS( 2 ) = MXCREATEFULL( LC1, LC2, 0 )
         PR = MXGETPR( PLHS( 2 ) )
         CALL MXCOPYREAL8TOPTR( CJAC, PR, NN )
C
      ELSE IF ( EQUAL( TOOL, TSGR ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .LT. 2 .OR. NRHS .GT. 4 ) THEN
            MSG = 'CSGR REQUIRES ONE, TWO, OR THREE INPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 2 ) THEN
            MSG = 'CSGR RETURNS TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Set defaults for GRLAGF and JTRANS.
C
         JTRANS = .FALSE.
         GRLAGF = .FALSE.
C
C  Copy third input argument (if given) into V.
C  Set default for GRLAGF to .TRUE. in this case.
C
         M = NCON
         IF ( NRHS .GE. 3 ) THEN
            IPTR = PRHS( 3 )
            CALL GETVEC( IPTR, V, NCON, M )
            GRLAGF = .TRUE.
         END IF
C
C  Adjust GRLAGF based on fourth input argument, if any.
C  Since CSGR combines the objective or Lagrangian gradient
C  with the constraint gradients in a single sparse matrix,
C  JTRANS is ignored here and handled in the MATLAB function.
C
         IF ( NRHS .EQ. 4 ) THEN
            IPTR = PRHS( 4 )
            CALL GETVEC( IPTR, WORKN, 2, NN )
            IF ( NINT( WORKN( 2 ) ) .NE. 0 ) GRLAGF = .TRUE.
         END IF
C
C  Get the gradient of the objective or Lagrangian and constraint functions.
C
         CALL CSGR( N, M, GRLAGF, M, V, X, NNZSCJ, NNZMAX, SCJAC,
     *              INDVAR, INDFUN )
C
C  Make sure NNZMAX is big enough.
C
         IF ( NNZSCJ .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE JACOBIAN EXCEEDS DECLARE
     *D SIZE OF SPARSE JACOBIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Convert from the CUTE sparse matrix to a MATLAB sparse matrix
C  and vector.  (The CUTE subroutine CSGR combines the gradient of
C  the objective or Lagrangian function and the gradients of the
C  general constraint functions in the single sparse matrix SCJAC.)
C  Put the MATLAB sparse Jacobian matrix in A, IROWA, and JCOLA.
C  Put the MATLAB sparse gradient vector of the objective or
C  Lagrangina function in B, IROWB, and JCOLB.
C
         CALL CNVSAB( N, NNZSCJ, SCJAC, INDFUN, INDVAR, NNZA, A, IROWA,
     *                JCOLA, NNZB, B, IROWB, JCOLB )
C
C  Copy the sparse gradient of the objective or Lagrangian function.
C
         PLHS( 1 ) = MXCREATESPARSE( 1, N, NNZB, 0 )
         IPTR = PLHS( 1 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( B, PR, NNZB )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWB, IR, NNZB )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLB, JC, NP1 )
C
C  Copy the sparse constraint Jacobian.
C
         PLHS( 2 ) = MXCREATESPARSE( M, N, NNZA, 0 )
         IPTR = PLHS( 2 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( A, PR, NNZA )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZA )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NP1 )
C
      ELSE IF ( EQUAL( TOOL, TOFG ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 2 ) THEN
            MSG = 'COFG REQUIRES CURRENT ITERATE AS INPUT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 .AND. NLHS .NE. 2 ) THEN
            MSG = 'COFG RETURNS ONE OR TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Decide if the gradient is required.
C
         GRAD = .FALSE.
         IF ( NLHS .EQ. 2 ) GRAD = .TRUE.
C
C  Get the value of the objective function, and possibly its gradient.
C
         CALL COFG( N, X, F, G, GRAD )
C
C  Copy F.
C
         PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( F, PR, 1 )
C
C  Copy G, if it is required.
C
         IF ( GRAD ) THEN
            PLHS( 2 ) = MXCREATEFULL( N, 1, 0 )
            PR = MXGETPR( PLHS( 2 ) )
            CALL MXCOPYREAL8TOPTR( G, PR, N )
         END IF
C
      ELSE IF ( EQUAL( TOOL, TCFG ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 2 .AND. NRHS .NE. 3 ) THEN
            MSG = 'CCFG REQUIRES CURRENT ITERATE AS INPUT.  THE JTRANS F
     *LAG IS OPTIONAL.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 .AND. NLHS .NE. 2 ) THEN
            MSG = 'CCFG RETURNS ONE OR TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Decide if the Jacobian is required.  If yes, decide if its transpose
C  is required.
C
         GRAD = .FALSE.
         JTRANS = .FALSE.
         IF ( NLHS .EQ. 2 ) GRAD = .TRUE.
         IF ( GRAD .AND. NRHS .EQ. 3 ) THEN
            I = NINT( MXGETSCALAR( PRHS( 3 ) ) )
            IF ( I .NE. 0 ) JTRANS = .TRUE.
         END IF
C
C  Set row and column dimensions of CJAC based on JTRANS.
C
         IF ( .NOT. JTRANS ) THEN
            LC1 = NCON
            LC2 = N
         ELSE
            LC1 = N
            LC2 = NCON
         END IF
C
C  Get the values of the constraint functions, and possibly their gradients.
C
         CALL CCFG( N, NCON, X, NCON, C, JTRANS, LC1, LC2, CJAC, GRAD )
C
C  Copy C.
C
         PLHS( 1 ) = MXCREATEFULL( NCON, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( C, PR, NCON )
C
C  Copy CJAC, if it is required.
C
         IF ( GRAD ) THEN
            NN = LC1*LC2
            PLHS( 2 ) = MXCREATEFULL( LC1, LC2, 0 )
            PR = MXGETPR( PLHS( 2 ) )
            CALL MXCOPYREAL8TOPTR( CJAC, PR, NN )
         END IF
C
      ELSE IF ( EQUAL( TOOL, TSCFG ) .OR. EQUAL( TOOL, TCFSG ) ) THEN
C
C  CSCFG has been superseded by CCFSG -- we keep it for compatibility
C
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 2 .AND. NRHS .NE. 3 ) THEN
            MSG = TOOL//' REQUIRES CURRENT ITERATE AS INPUT.  THE JTRANS
     *FLAG IS OPTIONAL.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 .AND. NLHS .NE. 2 ) THEN
            MSG = TOOL//' RETURNS ONE OR TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Decide if the Jacobian is required.  If yes, decide if its transpose
C  is required.
C
         GRAD = .FALSE.
         JTRANS = .FALSE.
         IF ( NLHS .EQ. 2 ) GRAD = .TRUE.
         IF ( GRAD .AND. NRHS .EQ. 3 ) THEN
            I = NINT( MXGETSCALAR( PRHS( 3 ) ) )
            IF ( I .NE. 0 ) JTRANS = .TRUE.
         END IF
C
C  Set row and column dimensions of CJAC based on JTRANS.
C
         IF ( .NOT. JTRANS ) THEN
            LC1 = NCON
            LC2 = N
         ELSE
            LC1 = N
            LC2 = NCON
         END IF
C
C  Get the values of the constraint functions, and possibly their gradients.
C
         CALL CCFSG( N, NCON, X, NCON, C, NNZSCJ, NNZMAX, SCJAC,
     *               INDVAR, INDFUN, GRAD )
C
C  Copy C.
C
         PLHS( 1 ) = MXCREATEFULL( NCON, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( C, PR, NCON )
C
C  Copy CJAC, if it is required.
C
         IF ( GRAD ) THEN
C
C  Convert from the CUTE sparse matrix to a MATLAB sparse matrix.
C  Put the MATLAB sparse matrix in A, IROWA, and JCOLA.
C  The roles of INDFUN and INDVAR are reversed if JTRANS is .TRUE.
C
            IF ( .NOT. JTRANS ) THEN
               CALL CNVSPR( LC2, NNZSCJ, SCJAC, INDFUN, INDVAR,
     *                      A, IROWA, JCOLA )
            ELSE
               CALL CNVSPR( LC2, NNZSCJ, SCJAC, INDVAR, INDFUN,
     *                      A, IROWA, JCOLA )
            END IF
C
C  Copy the sparse Jacobian.
C
            PLHS( 2 ) = MXCREATESPARSE( LC1, LC2, NNZSCJ, 0 )
            IPTR = PLHS( 2 )
            PR = MXGETPR( IPTR )
            CALL MXCOPYREAL8TOPTR( A, PR, NNZSCJ )
            IR = MXGETIR( IPTR )
            CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZSCJ )
            NN = LC2 + 1
            JC = MXGETJC( IPTR )
            CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NN )
         END IF
C
      ELSE IF ( EQUAL( TOOL, TDH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CDH REQUIRES CURRENT ESTIMATE OF SOLUTION AND LAGRANG
     *E MULTIPLIERS AS INPUT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CDH RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second and third input arguments into X and V, respectively.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
*        Philip Gill 30-Apr-2007: Test for the unconstrained case
     IF( NCON .GT. 0 ) THEN
            IPTR = PRHS( 3 )
            CALL GETVEC( IPTR, V, NCON, M )
     ENDIF
*Old     IPTR = PRHS( 3 )
*Old     CALL GETVEC( IPTR, V, NCON, M )
C
C  Get the dense Hessian of the Lagrangian evaluated at X and V.
C
         CALL CDH( N, M, X, M, V, N, DH )
C
C  Copy H.
C
         PLHS( 1 ) = MXCREATEFULL( N, N, 0 )
         NN = N*N
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( DH, PR, NN )
C
      ELSE IF ( EQUAL( TOOL, TGRDH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 .AND. NRHS .NE. 4 ) THEN
            MSG = 'CGRDH REQUIRES CURRENT ESTIMATE OF SOLUTION AND LAGRA
     *NGE MULTIPLIERS AS INPUT.  THE OPTIONS VECTOR IS OPTIONAL.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 3 ) THEN
            MSG = 'CGRDH RETURNS THREE OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second and third input arguments into X and V, respectively.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
         IPTR = PRHS( 3 )
         CALL GETVEC( IPTR, V, NCON, M )
C
C  Adjust JTRANS and GRLAGF based on fourth input argument, if any.
C
         JTRANS = .FALSE.
         GRLAGF = .FALSE.
         IF ( NRHS .EQ. 4 ) THEN
            IPTR = PRHS( 4 )
            CALL GETVEC( IPTR, WORKN, 2, NN )
            IF ( NINT( WORKN( 1 ) ) .NE. 0 ) JTRANS = .TRUE.
            IF ( NINT( WORKN( 2 ) ) .NE. 0 ) GRLAGF = .TRUE.
         END IF
C
C  Set dimensions of CJAC based on JTRANS.
C
         IF ( .NOT. JTRANS ) THEN
            LC1 = M
            LC2 = N
         ELSE
            LC1 = N
            LC2 = M
         END IF
C
C  Get the dense Hessian of the Lagrangian evaluated at X and V.
C
         CALL CGRDH( N, M, X, GRLAGF, M, V, G, JTRANS, LC1, LC2, CJAC,
     *               N, DH )
C
C  Copy G.
C
         PLHS( 1 ) = MXCREATEFULL( N, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( G, PR, N )
C
C  Copy CJAC.
C
         NN = LC1*LC2
         PLHS( 2 ) = MXCREATEFULL( LC1, LC2, 0 )
         PR = MXGETPR( PLHS( 2 ) )
         CALL MXCOPYREAL8TOPTR( CJAC, PR, NN )
C
C  Copy H.
C
         NN = N*N
         PLHS( 3 ) = MXCREATEFULL( N, N, 0 )
         PR = MXGETPR( PLHS( 3 ) )
         CALL MXCOPYREAL8TOPTR( DH, PR, NN )
C
      ELSE IF ( EQUAL( TOOL, TSH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CSH REQUIRES CURRENT ESTIMATE OF SOLUTION AND LAGRANG
     *E MULTIPLIERS AS INPUT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CSH RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second and third input arguments into X and V, respectively.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
     IF( NCON .GT. 0 ) THEN
            IPTR = PRHS( 3 )
            CALL GETVEC( IPTR, V, NCON, M )
     ENDIF
C
C  Get the sparse Hessian of the Lagrangian evaluated at X and V.
C
         CALL CSH( N, M, X, M, V, NNZSH, NNZMAX, SH, IRNSH, ICNSH )
C
C  Make sure NNZMAX is big enough.
C
         IF ( NNZSH .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Remove any zeros and count how many nonzeros there are in the
C  combined lower and upper triangular parts
C
         J = 0
         NNZ = 0
         DO 111 I = 1, NNZSH
           IF ( SH( I ) .NE. 0.0D+0 ) THEN
             J = J + 1
             NNZ = NNZ + 1
             IF ( IRNSH( I ) .NE. ICNSH( I ) ) NNZ = NNZ + 1
             IRNSH( J ) = IRNSH( I )
             ICNSH( J ) = ICNSH( I )
             SH( J ) = SH( I )
           END IF
  111    CONTINUE
         NNZSH = J
         IF ( NNZ .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Include both lower and upper triangular parts (for Matlab)
C
         J = NNZSH
         DO 112 I = 1, NNZSH
           IF ( IRNSH( I ) .NE. ICNSH( I ) ) THEN
             J = J + 1
             IRNSH( J ) = ICNSH( I )
             ICNSH( J ) = IRNSH( I )
             SH( J ) = SH( I )
           END IF
  112    CONTINUE
         NNZSH = J
C
C  Convert from the CUTE sparse matrix to a MATLAB sparse matrix.
C  Put the MATLAB sparse matrix in A, IROWA, and JCOLA.
C
         CALL CNVSPR( N, NNZSH, SH, IRNSH, ICNSH, A, IROWA, JCOLA )
C
C  Copy the sparse Hessian.
C
         PLHS( 1 ) = MXCREATESPARSE( N, N, NNZSH, 0 )
         IPTR = PLHS( 1 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( A, PR, NNZSH )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZSH )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NP1 )
C
      ELSE IF ( EQUAL( TOOL, TSH1 ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CSH1 REQUIRES CURRENT ESTIMATE OF SOLUTION AND LAGRAN
     *GE MULTIPLIERS AS INPUT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CSH1 RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second and third input arguments into X and V, respectively.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
     IF( NCON .GT. 0 ) THEN
            IPTR = PRHS( 3 )
            CALL GETVEC( IPTR, V, NCON, M )
     ENDIF
C
C  Get the sparse Hessian of the contrained part of the
C  Lagrangian evaluated at X and V.
C
         CALL CSH1( N, M, X, M, V, NNZSH, NNZMAX, SH, IRNSH, ICNSH )
C
C  Remove any zeros and count how many nonzeros there are in the
C  combined lower and upper triangular parts
C
         J = 0
         NNZ = 0
         DO 113 I = 1, NNZSH
           IF ( SH( I ) .NE. 0.0D+0 ) THEN
             J = J + 1
             NNZ = NNZ + 1
             IF ( IRNSH( I ) .NE. ICNSH( I ) ) NNZ = NNZ + 1
             IRNSH( J ) = IRNSH( I )
             ICNSH( J ) = ICNSH( I )
             SH( J ) = SH( I )
           END IF
  113    CONTINUE
         NNZSH = J
         IF ( NNZ .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Include both lower and upper triangular parts (for Matlab)
C
         J = NNZSH
         DO 114 I = 1, NNZSH
           IF ( IRNSH( I ) .NE. ICNSH( I ) ) THEN
             J = J + 1
             IRNSH( J ) = ICNSH( I )
             ICNSH( J ) = IRNSH( I )
             SH( J ) = SH( I )
           END IF
  114    CONTINUE
         NNZSH = J
C
C  Make sure NNZMAX is big enough.
C
         IF ( NNZSH .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Convert from the CUTE sparse matrix to a MATLAB sparse matrix.
C  Put the MATLAB sparse matrix in A, IROWA, and JCOLA.
C
         CALL CNVSPR( N, NNZSH, SH, IRNSH, ICNSH, A, IROWA, JCOLA )
C
C  Copy the sparse Hessian.
C
         PLHS( 1 ) = MXCREATESPARSE( N, N, NNZSH, 0 )
         IPTR = PLHS( 1 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( A, PR, NNZSH )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZSH )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NP1 )
C
      ELSE IF ( EQUAL( TOOL, TSGRSH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 .AND. NRHS .NE. 4 ) THEN
            MSG = 'CSGRSH REQUIRES CURRENT ESTIMATE OF SOLUTION AND LAGR
     *ANGE MULTIPLIERS AS INPUT.  THE OPTIONS VECTOR IS OPTIONAL.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 3 ) THEN
            MSG = 'CGRDH RETURNS THREE OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second and third input arguments into X and V, respectively.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
         IPTR = PRHS( 3 )
         CALL GETVEC( IPTR, V, NCON, M )
C
C  Adjust GRLAGF based on fourth input argument, if any.
C  Since CSGR combines the objective or Lagrangian gradient
C  with the constraint gradients in a single sparse matrix,
C  JTRANS is ignored here and handled in the MATLAB function.
C
         GRLAGF = .FALSE.
         IF ( NRHS .EQ. 4 ) THEN
            IPTR = PRHS( 4 )
            CALL GETVEC( IPTR, WORKN, 2, NN )
            IF ( NINT( WORKN( 2 ) ) .NE. 0 ) GRLAGF = .TRUE.
         END IF
C
C  Get the gradient of the objective or Lagrangian and constraint functions,
C  and get the sparse Hessian of the Lagrangian evaluated at X and V.
C
         CALL CSGRSH( N, M, X, GRLAGF, M, V, NNZSCJ, NNZMAX, SCJAC,
     *                INDVAR, INDFUN, NNZSH, NNZMAX, SH, IRNSH, ICNSH )
C
C  Make sure NNZMAX is big enough for the sparse Jacobian and Hessian.
C
         IF ( NNZSCJ .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE JACOBIAN EXCEEDS DECLARE
     *D SIZE OF SPARSE JACOBIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NNZSH .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Remove any zeros and count how many nonzeros there are in the
C  combined lower and upper triangular parts
C
         J = 0
         NNZ = 0
         DO 115 I = 1, NNZSH
           IF ( SH( I ) .NE. 0.0D+0 ) THEN
             J = J + 1
             NNZ = NNZ + 1
             IF ( IRNSH( I ) .NE. ICNSH( I ) ) NNZ = NNZ + 1
             IRNSH( J ) = IRNSH( I )
             ICNSH( J ) = ICNSH( I )
             SH( J ) = SH( I )
           END IF
  115    CONTINUE
         NNZSH = J
         IF ( NNZ .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Include both lower and upper triangular parts (for Matlab)
C
         J = NNZSH
         DO 116 I = 1, NNZSH
           IF ( IRNSH( I ) .NE. ICNSH( I ) ) THEN
             J = J + 1
             IRNSH( J ) = ICNSH( I )
             ICNSH( J ) = IRNSH( I )
             SH( J ) = SH( I )
           END IF
  116    CONTINUE
         NNZSH = J
C
C  Convert from the CUTE sparse matrix to a MATLAB sparse matrix
C  and vector.  (The CUTE subroutine CSGR combines the gradient of
C  the objective or Lagrangian function and the gradients of the
C  general constraint functions in the single sparse matrix SCJAC.)
C  Put the MATLAB sparse Jacobian matrix in A, IROWA, and JCOLA.
C  Put the MATLAB sparse gradient vector of the objective or
C  Lagrangina function in B, IROWB, and JCOLB.
C
         CALL CNVSAB( N, NNZSCJ, SCJAC, INDFUN, INDVAR, NNZA, A, IROWA,
     *                JCOLA, NNZB, B, IROWB, JCOLB )
C
C  Copy the sparse gradient of the objective or Lagrangian function.
C
         PLHS( 1 ) = MXCREATESPARSE( 1, N, NNZB, 0 )
         IPTR = PLHS( 1 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( B, PR, NNZB )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWB, IR, NNZB )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLB, JC, NP1 )
C
C  Copy the sparse constraint Jacobian.
C
         PLHS( 2 ) = MXCREATESPARSE( M, N, NNZA, 0 )
         IPTR = PLHS( 2 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( A, PR, NNZA )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZA )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NP1 )
C
C  Convert from the CUTE sparse Hessian to a MATLAB sparse matrix.
C  Put the MATLAB sparse matrix in A, IROWA, and JCOLA.
C
         CALL CNVSPR( N, NNZSH, SH, IRNSH, ICNSH, A, IROWA, JCOLA )
C
C  Copy the sparse Hessian.
C
         PLHS( 3 ) = MXCREATESPARSE( N, N, NNZSH, 0 )
         IPTR = PLHS( 3 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( A, PR, NNZSH )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZSH )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NP1 )
C
      ELSE IF ( EQUAL( TOOL, TPROD ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 4 .AND. NRHS .NE. 5 ) THEN
            MSG = 'CPROD REQUIRES CURRENT ESTIMATE OF SOLUTION AND LAGRANG
     *E MULTIPLIERS AND ANOTHER VECTOR AS INPUT.  THE GOTH FLAG IS OPTIONA
     *L.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CPROD RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy second, third, and fourth input arguments into X, V, and P,
C  respectively.  Make sure X and P are the same length.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
         IPTR = PRHS( 3 )
         CALL GETVEC( IPTR, V, NCON, M )
         IPTR = PRHS( 4 )
         CALL GETVEC( IPTR, P, NVAR, NN )
         IF ( N .NE. NN ) THEN
            MSG = 'CURRENT ITERATE AND VECTOR TO BE MULTIPLIED MUST HAVE
     * SAME LENGTH.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Check for setting of GOTH flag.
C
         GOTH = .FALSE.
         IF ( NRHS .EQ. 4 ) THEN
            I = NINT( MXGETSCALAR( PRHS( 5 ) ) )
            IF ( I .NE. 0 ) GOTH = .TRUE.
         END IF
C
C  Get the product of the Hessian of the Lagrangian with P.
C
         CALL CPROD( N, M, GOTH, X, M, V, P, Q )
C
C  Copy Q.
C
         PLHS( 1 ) = MXCREATEFULL( N, 1, 0 )
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( Q, PR, N )
C
      ELSE IF ( EQUAL( TOOL, TCIFG ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CCIFG REQUIRES X AND CONSTRAINT INDEX AS INPUT'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( (NLHS .NE. 1) .AND. (NLHS .NE. 2) ) THEN
            MSG = 'CCIFG RETURNS ONE OR TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy first input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Copy second input argument into I.
C
     I = NINT( MXGETSCALAR( PRHS( 3 ) ) )
C
C  Check consistency of constraint index
C
     IF( (I .LT. 1) .OR. (I .GT. NCON) ) THEN
        MSG = 'CCIFG: INVALID CONSTRAINT INDEX.'
            CALL MEXERRMSGTXT( MSG )
     END IF
C
C  Decide if we want to evaluate the gradient or not
C  and make room for output.
C
     IF( NLHS .EQ. 2 ) THEN
        CALL CCIFG( N, I, X, CI, GCI, .TRUE. )
        PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
        PR2 = MXGETPR( PLHS( 1 ) )
        PLHS( 2 ) = MXCREATEFULL( N, 1, 0 )
        PR3 = MXGETPR( PLHS( 2 ) )
        CALL MXCOPYREAL8TOPTR( CI,  PR2, 1 )
        CALL MXCOPYREAL8TOPTR( GCI, PR3, N )
     ELSE
        CALL CCIFG( N, I, X, CI, GCI, .FALSE. )
        PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
        PR2 = MXGETPR( PLHS( 1 ) )
        CALL MXCOPYREAL8TOPTR( CI,  PR2, 1 )
     ENDIF

      ELSE IF ( EQUAL( TOOL, TSCIFG ) .OR. EQUAL( TOOL, TCIFSG ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CCIFSG REQUIRES X AND CONSTRAINT INDEX AS INPUT'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( (NLHS .NE. 1) .AND. (NLHS .NE. 2) ) THEN
            MSG = 'CCIFSG RETURNS ONE OR TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  CSCIFG has been superseded by CCIFSG and is included for compatibility.
C
C
C  Copy first input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Copy second input argument into I.
C
     I = NINT( MXGETSCALAR( PRHS( 3 ) ) )
C
C  Check consistency of constraint index
C
     IF( (I .LT. 1) .OR. (I .GT. NCON) ) THEN
        MSG = 'CCIFSG: INVALID CONSTRAINT INDEX.'
            CALL MEXERRMSGTXT( MSG )
     END IF
C
C  Decide if we want to evaluate the gradient or not
C  and make room for output.
C
     IF( NLHS .EQ. 2 ) THEN
        CALL CCIFSG( NVAR, I, X, CI, NNZGCI, NNZIMAX, SGCI,
     *                   INDVARI, .TRUE. )
C
C  Copy CI
C
        PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
        PR = MXGETPR( PLHS( 1 ) )
        CALL MXCOPYREAL8TOPTR( CI,  PR, 1 )
C
C  Make sure NNZIMAX is big enough.
C
            IF ( NNZGCI .GT. NNZIMAX ) THEN
               MSG = 'NUMBER OF NONZEROS IN SPARSE GRADIENT EXCEEDS
     *          DECLARED SIZE OF SPARSE GRADIENT IN MEX-FILE.'
               CALL MEXERRMSGTXT( MSG )
            END IF
C
C  Substract one to indices because Matlab uses C array storage
C
        DO 117 J = 1, NNZGCI
           INDVARI( J ) = INDVARI( J ) - 1
  117       CONTINUE
C
C  Set column indices for the vector, still using C arrays
C
        ONES( 1 ) = 0
            DO 118 J = 2, NVAR
               ONES( J ) = -1
  118       CONTINUE
        ONES( NVAR + 1 ) = NNZGCI
C
C      Make room for the sparse vector SGCI
C
            PLHS( 2 ) = MXCREATESPARSE( 1, NVAR, NNZGCI, 0 )
        PR3 = PLHS( 2 )
C
C      Copy the values of SGCI
C
            PR2 = MXGETPR( PR3 )
            CALL MXCOPYREAL8TOPTR( SGCI, PR2, NNZGCI )
C
C      Copy the row indices
C
            IR = MXGETIR( PR3 )
            CALL MXCOPYINTEGER4TOPTR( INDVARI, IR, NNZGCI )
C
C      Copy the column indices
C
            JC = MXGETJC( PR3 )
            CALL MXCOPYINTEGER4TOPTR( ONES, JC, NVAR+1 )

     ELSE
        CALL CCIFSG( N, I, X, CI, NNZGCI, NNZIMAX, SGCI,
     *                   INDVARI, .FALSE. )
        PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
        PR = MXGETPR( PLHS( 1 ) )
        CALL MXCOPYREAL8TOPTR( CI, PR, 1 )
     ENDIF



      ELSE IF ( EQUAL( TOOL, TDIMEN ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 1 ) THEN
            MSG = 'CDIMEN REQUIRES NO INPUT INPUT ARGUMENTS'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 2 ) THEN
            MSG = 'CDIMEN RETURNS TWO OUTPUT ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Build data input file name.
C
         PRBDAT = 'OUTSDIF.d'
C
C  Open the relevant file.
C
         OPEN ( INPUT, FILE = PRBDAT, FORM = 'FORMATTED',
     *          STATUS = 'OLD' )
     REWIND INPUT
C
C  Call CDIMEN
C
     CALL CDIMEN( INPUT, N, M )

     N_real = N
     M_real = M

     PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
     PR = MXGETPR( PLHS( 1 ) )
     CALL MXCOPYREAL8TOPTR( N_real, PR, 1 )
     PLHS( 2 ) = MXCREATEFULL( 1, 1, 0 )
     PR2 = MXGETPR( PLHS( 2 ) )
     CALL MXCOPYREAL8TOPTR( M_real, PR2, 1 )

     CLOSE( INPUT )

      ELSE IF ( EQUAL( TOOL, TDIMSH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 1 ) THEN
            MSG = 'CDIMSH DOES NOT REQUIRE AN INPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CDIMSH RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Call CDIMSH
C
     CALL CDIMSH( NNZ )

     NNZ_real = NNZ

     PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
     PR = MXGETPR( PLHS( 1 ) )
     CALL MXCOPYREAL8TOPTR( NNZ_real, PR, 1 )

      ELSE IF ( EQUAL( TOOL, TDIMSJ ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 1 ) THEN
            MSG = 'CDIMSJ DOES NOT REQUIRE AN INPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CDIMSJ RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Call CDIMSJ
C
     CALL CDIMSJ( NNZ )

     NNZ_real = NNZ

     PLHS( 1 ) = MXCREATEFULL( 1, 1, 0 )
     PR = MXGETPR( PLHS( 1 ) )
     CALL MXCOPYREAL8TOPTR( NNZ_real, PR, 1 )

      ELSE IF ( EQUAL( TOOL, TVARTY ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 1 ) THEN
            MSG = 'CVARTY DOES NOT REQUIRE AN INPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CVARTY RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Call CVARTY
C
     CALL CVARTY( NVAR, IVARTY )
C
C  Convert to real
C
     N_real = NVAR
     DO 121 i = 1, NVAR
       IVARTY_real( i ) = IVARTY( i )
  121    CONTINUE
C
C  Make room for output
C
     PLHS( 1 ) = MXCREATEFULL( NVAR, 1, 0 )
     PR  = MXGETPR( PLHS( 1 ) )
C
C  Copy IVARTY
C
     CALL MXCOPYREAL8TOPTR( IVARTY_real, PR, NVAR )

      ELSE IF ( EQUAL( TOOL, TIDH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CIDH TAKES CURRENT POINT AND CONSTRAINT
     * INDEX AS ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CIDH RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy first input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Copy second input argument into I.
C
     I = NINT( MXGETSCALAR( PRHS( 3 ) ) )
C
C  Check consistency of constraint index. I=0 -> objective function.
C
     IF( (I .LT. 0) .OR. (I .GT. NCON) ) THEN
        MSG = 'CIDH: INVALID CONSTRAINT INDEX.'
            CALL MEXERRMSGTXT( MSG )
     END IF
C
C  Call CIDH
C
     CALL CIDH( NVAR, X, I, N, DHI )
C
C  Copy DHI.
C
         PLHS( 1 ) = MXCREATEFULL( N, N, 0 )
         NN = N*N
         PR = MXGETPR( PLHS( 1 ) )
         CALL MXCOPYREAL8TOPTR( DHI, PR, NN )

      ELSE IF ( EQUAL( TOOL, TISH ) ) THEN
C
C  Check number of input and output arguments.
C
         IF ( NRHS .NE. 3 ) THEN
            MSG = 'CISH TAKES CURRENT POINT AND CONSTRAINT
     * INDEX AS ARGUMENTS.'
            CALL MEXERRMSGTXT( MSG )
         END IF
         IF ( NLHS .NE. 1 ) THEN
            MSG = 'CISH RETURNS ONE OUTPUT ARGUMENT.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Copy first input argument into X.
C
         IPTR = PRHS( 2 )
         CALL GETVEC( IPTR, X, NVAR, N )
C
C  Copy second input argument into I.
C
     I = NINT( MXGETSCALAR( PRHS( 3 ) ) )
C
C  Check consistency of constraint index. I=0 -> objective function.
C
     IF( (I .LT. 0) .OR. (I .GT. NCON) ) THEN
        MSG = 'CISH: INVALID CONSTRAINT INDEX.'
            CALL MEXERRMSGTXT( MSG )
     END IF
C
C  Call CISH
C
     CALL CISH( NVAR, X, I, NNZSH, NNZMAX, SH, IRNSH, ICNSH )
C
C  Make sure NNZMAX is big enough.
C
         IF ( NNZSH .GT. NNZMAX ) THEN
            MSG = 'CISH: NUMBER OF NONZEROS IN SPARSE HESSIAN
     * EXCEEDS DECLARED SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Remove any zeros and count how many nonzeros there are in the
C  combined lower and upper triangular parts
C
         J = 0
         NNZ = 0
         DO 120 I = 1, NNZSH
           IF ( SH( I ) .NE. 0.0D+0 ) THEN
             J = J + 1
             NNZ = NNZ + 1
             IF ( IRNSH( I ) .NE. ICNSH( I ) ) NNZ = NNZ + 1
             IRNSH( J ) = IRNSH( I )
             ICNSH( J ) = ICNSH( I )
             SH( J ) = SH( I )
           END IF
  120    CONTINUE
         NNZSH = J
         IF ( NNZ .GT. NNZMAX ) THEN
            MSG = 'NUMBER OF NONZEROS IN SPARSE HESSIAN EXCEEDS DECLARED
     * SIZE OF SPARSE HESSIAN IN MEX-FILE.'
            CALL MEXERRMSGTXT( MSG )
         END IF
C
C  Include both lower and upper triangular parts (for Matlab)
C
         J = NNZSH
         DO 122 I = 1, NNZSH
           IF ( IRNSH( I ) .NE. ICNSH( I ) ) THEN
             J = J + 1
             IRNSH( J ) = ICNSH( I )
             ICNSH( J ) = IRNSH( I )
             SH( J ) = SH( I )
           END IF
  122    CONTINUE
         NNZSH = J
C
C  Convert from the CUTE sparse matrix to a MATLAB sparse matrix.
C  Put the MATLAB sparse matrix in A, IROWA, and JCOLA.
C
         CALL CNVSPR( N, NNZSH, SH, IRNSH, ICNSH, A, IROWA, JCOLA )
C
C  Copy the sparse Hessian.
C
         PLHS( 1 ) = MXCREATESPARSE( N, N, NNZSH, 0 )
         IPTR = PLHS( 1 )
         PR = MXGETPR( IPTR )
         CALL MXCOPYREAL8TOPTR( A, PR, NNZSH )
         IR = MXGETIR( IPTR )
         CALL MXCOPYINTEGER4TOPTR( IROWA, IR, NNZSH )
         NP1 = N + 1
         JC = MXGETJC( IPTR )
         CALL MXCOPYINTEGER4TOPTR( JCOLA, JC, NP1 )

      ELSE
         MSG = 'REQUESTED UNCONSTRAINED TOOL DOES NOT EXIST:  '//TOOL
         CALL MEXERRMSGTXT( MSG )
      END IF
      RETURN
      END
