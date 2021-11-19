C      ALGORITHM 424, COLLECTED ALGORITHMS FROM ACM.
C      THIS WORK PUBLISHED IN COMMUNICATIONS FROM THE ACM
C      VOL. 15, NO. 5,      MAY, 1972, P. 353--355.
C
C Incorporates the changes suggested in the remarks
C GOOD: CACM 16,8 p490 -- August 1973.
C GEDDES: TOMS 5,2 p240 -- June 1979.

      REAL FUNCTION CCQUAD(F,A,B,TOLERR,LIMIT,ESTERR,USED,
     &  CSXFRM)

c*********************************************************************72
C
C  USING CLENSHAW-CURTIS QUADRATURE, THIS FUNCTION SUB-
C  PROGRAM ATTEMPTS TO INTEGRATE THE FUNCTION F FROM A TO B
C  TO AT LEAST THE REQUESTED RELATIVE ACCURACY TOLERR, WHILE
C  USING NO MORE THAN LIMIT FUNCTION EVALUATIONS.  IF THIS
C  CAN BE DONE, CCQUAD RETURNS THE VALUE OF THE INTEGRAL,
C  ESTERR RETURNS AN ESTIMATE OF THE ABSOLUTE ERROR ACTUALLY
C  COMMITTED, USED RETURNS THE NUMBER OF FUNCTION VALUES
C  ACTUALLY USED, AND CSXFRM(1),...,CSXFRM(USED) CONTAINS
C  N=USED-1 TIMES THE DISCRETE COSINE TRANSFORM, AS USUALLY
C  DEFINED, OF THE INTEGRAND IN THE INTERVAL.  IF THE
C  REQUESTED ACCURACY CANNOT BE OBTAINED WITH THE NUMBER OF
C  FUNCTION EVALUATIONS PERMITTED, THE LAST (AND PRESUMABLY
C  BEST) ANSWER OBTAINED IS RETURNED.
C
      IMPLICIT NONE
C
C  INPUT ARGUMENTS-
C
      REAL F,A,B,TOLERR
      INTEGER LIMIT
C  OUTPUT ARGUMENTS-
      REAL ESTERR,CSXFRM(LIMIT)
      INTEGER USED

      REAL PI,RT3,CENTRE,WIDTH,SHIFT,FUND,ANGLE,C,S
      REAL OLDINT,NEWINT
      REAL T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12
C  INSERT THE FOLLOWING STATEMENT TO TRACE PROGRAM FLOW.
C      REAL SCLINT,SCLERR
      INTEGER N,N2,N3,N_LESS_1,N_LESS_3,MAX,M_MAX,J,STEP
      INTEGER L(8),L1,L2,L3,L4,L5,L6,L7,L8
      INTEGER J1,J2,J3,J4,J5,J6,J7,J8,J_REV
      EQUIVALENCE (L(1),L1),(L(2),L2),(L(3),L3),(L(4),L4),
     &  (L(5),L5),(L(6),L6),(L(7),L7),(L(8),L8),(J8,J_REV)
      DATA PI,RT3/3.141592653589E0, 1.732050807568E0 /
      DATA M_MAX / 8 /
C
C  INITIALIZATION.
C
      CENTRE=(A+B)*.5E0
      WIDTH=(B-A)*.5E0
      MAX=MIN0(LIMIT,2*3**(M_MAX+1))
      DO 10 J=1,M_MAX
        L(J)=1
10    CONTINUE
C
C  COSINE TRANSFORM.
C  COMPUTE DOUBLE THE COSINE TRANSFORM WITH N=6.
C
      N=6
C
C  SAMPLE THE FUNCTION.
C
C*** The next two lines were changed as per remark
C*** by Geddes (TOMS 5,2 p240)
C     CSXFRM(1)=F(A)
C     CSXFRM(7)=F(B)
      CSXFRM(1)=F(B)
      CSXFRM(7)=F(A)
C*** The next line was changed as per remark
C*** by Geddes (TOMS 5,2 p240)
C     SHIFT=WIDTH*RT3*.5E0
      SHIFT=-WIDTH*RT3*.5E0
      CSXFRM(2)=F(CENTRE-SHIFT)
      CSXFRM(6)=F(CENTRE+SHIFT)
C*** The next line was changed as per remark
C*** by Geddes (TOMS 5,2 p240)
C     SHIFT=WIDTH*.5E0
      SHIFT=-WIDTH*.5E0
      CSXFRM(3)=F(CENTRE-SHIFT)
      CSXFRM(5)=F(CENTRE+SHIFT)
      CSXFRM(4)=F(CENTRE)
C  EVALUATE THE FACTORED N=6 COSINE TRANSFORM.
      T1=CSXFRM(1)+CSXFRM(7)
      T2=CSXFRM(1)-CSXFRM(7)
      T3=2.E0*CSXFRM(4)
      T4=CSXFRM(2)+CSXFRM(6)
      T5=(CSXFRM(2)-CSXFRM(6))*RT3
      T6=CSXFRM(3)+CSXFRM(5)
      T7=CSXFRM(3)-CSXFRM(5)
      T8=T1+2.E0*T6
      T9=2.E0*T4+T3
      T10=T2+T7
      T11=T1-T6
      T12=T4-T3
      CSXFRM(1)=T8+T9
      CSXFRM(2)=T10+T5
      CSXFRM(3)=T11+T12
      CSXFRM(4)=T2-2.E0*T7
      CSXFRM(5)=T11-T12
      CSXFRM(6)=T10-T5
      CSXFRM(7)=T8-T9
      USED=7
C  GO TO INTEGRAL COMPUTATION, BUT FIRST COMPUTE INTEGRAL FOR N=2.
      GO TO 200
C
C  COMPUTE REFINED APPROXIMATION.
C  SAMPLE FUNCTION AT INTERMEDIATE POINTS IN DIGIT REVERSED
C  ORDER.  AS THE SEQUENCE IS GENERATED, COMPUTE THE FIRST
C  (RADIX FOUR TRANSFORM) PASS OF THE FAST FOURIER TRANSFORM.
C
100   DO 110 J=2,M_MAX
        L(J-1)=L(J)
110   CONTINUE
      L(M_MAX)=3*L(M_MAX-1)
      J=USED
      FUND=PI/FLOAT(3*N)
      DO 120 J1=1,L1,1
        DO 120 J2=J1,L2,L1
          DO 120 J3=J2,L3,L2
            DO 120 J4=J3,L4,L3
              DO 120 J5=J4,L5,L4
                DO 120 J6=J5,L6,L5
                  DO 120 J7=J6,L7,L6
                    DO 120 J8=J7,L8,L7
C*** The next line was changed as per remark
C*** by Good (CACM 16,8 p490)
C                     ANGLE=FUND*FLOAT(3*J_REV-2)
                      ANGLE=FUND*FLOAT(3*J8-2)
C*** The next line was changed as per remark
C*** by Geddes (TOMS 5,2 p240)
C                     SHIFT=WIDTH*COS(ANGLE)
                      SHIFT=-WIDTH*COS(ANGLE)
                      T1=F(CENTRE-SHIFT)
                      T3=F(CENTRE+SHIFT)
C*** The next line was changed as per remark
C*** by Geddes (TOMS 5,2 p240)
C                     SHIFT=WIDTH*SIN(ANGLE)
                      SHIFT=-WIDTH*SIN(ANGLE)
                      T2=F(CENTRE+SHIFT)
                      T4=F(CENTRE-SHIFT)
                      T5=T1+T3
                      T6=T2+T4
                      CSXFRM(J+1)=T5+T6
                      CSXFRM(J+2)=T1-T3
                      CSXFRM(J+3)=T5-T6
                      CSXFRM(J+4)=T2-T4
                      J=J+4
120   CONTINUE
C  DO RADIX 3 PASSES OF FAST FOURIER TRANSFORM.
      N2=2*N
      STEP=4
150   J1=USED+STEP
      J2=USED+2*STEP
      CALL R3PASS(N2,STEP,N2-2*STEP,CSXFRM(USED+1),
     *  CSXFRM(J1+1),CSXFRM(J2+1))
      STEP=3*STEP
      IF (STEP .LT. N) GO TO 150
C
C  COMBINE RESULTS.
C
C  FIRST DO J=0 AND J=N.
C
      T1=CSXFRM(1)
      T2=CSXFRM(USED+1)
      CSXFRM(1)=T1+2.E0*T2
      CSXFRM(USED+1)=T1-T2
      T1=CSXFRM(N+1)
      T2=CSXFRM(N2+2)
      CSXFRM(N+1)=T1+T2
      CSXFRM(N2+2)=T1-2.E0*T2
C  NOW DO REMAINING VALUES OF J.
      N3=3*N
      N_LESS_1=N-1
      DO 180 J=1,N_LESS_1
        J1=N+J
        J2=N3-J
        ANGLE=FUND*FLOAT(J)
        C=COS(ANGLE)
        S=SIN(ANGLE)
        T1=C*CSXFRM(J1+2)-S*CSXFRM(J2+2)
        T2=(S*CSXFRM(J1+2)+C*CSXFRM(J2+2))*RT3
        CSXFRM(J1+2)=CSXFRM(J+1)-T1-T2
        CSXFRM(J2+2)=CSXFRM(J+1)-T1+T2
        CSXFRM(J+1)=CSXFRM(J+1)+2.E0*T1
180   CONTINUE
C  NOW UNSCRAMBLE.
      T1=CSXFRM(N2+1)
      T2=CSXFRM(N2+2)
      DO 190 J=1,N_LESS_1
        J1=USED+J
        J2=N2+J
        CSXFRM(J2)=CSXFRM(J1)
        CSXFRM(J1)=CSXFRM(J2+2)
190   CONTINUE
      CSXFRM(N3)=T1
      CSXFRM(N3+1)=T2
      N=N3
      USED=N+1
C
C  GO TO INTEGRAL COMPUTATION.
C
      GO TO 210
C
C  INTEGRAL EVALUATION.
C  INTEGRAL ESTIMATES ARE NOT SCALED BY WIDTH*N/2
C  UNTIL FUNCTION CCQUAD RETURNS.
C
C  WHEN N=6, EVALUATE INTEGRAL FOR N=2.
C
200   OLDINT=(T1+2.E0*T3)/3.E0
C
C  EVALUATE NEW ESTIMATE OF INTEGRAL.
C
210   N_LESS_3=N-3
      NEWINT=.5E0*CSXFRM(USED)/FLOAT(1-N**2)
      DO 220 J=1,N_LESS_3,2
        J_REV=N-J
        NEWINT=NEWINT+CSXFRM(J_REV)/FLOAT(J_REV*(2-J_REV))
220   CONTINUE
      NEWINT=NEWINT+.5E0*CSXFRM(1)
C
C  TEST IF DONE.
C  TEST IF ESTIMATED ERROR ADEQUATE.
      ESTERR=ABS(OLDINT*3.E0-NEWINT)
C
C  INSERT THE FOLLOWING FOUR STATEMENTS TO TRACE PROGRAM FLOW.
C     SCLINT=WIDTH*NEWINT/FLOAT(N/2))
C     SCLERR=WIDTH*(OLDINT*3.E0-NEWINT)/FLOAT(N/2)
C     WRITE(6,900) N,SCLINT,SCLERR
C900  FORMAT ( 3H N=,I5,23H INTEGRAL ESTIMATED AS ,E15.8,
C    *  7H ERROR ,E15.8 )
      IF ( ABS(NEWINT)*TOLERR .GE. ESTERR ) GO TO 400
C  IF ESTIMATED ERROR TOO LARGE, REFINE SAMPLING IF PERMITTED.
      OLDINT=NEWINT
      IF (3*N+1 .LE. MAX ) GO TO 100
C  IF REFINEMENT NOT PERMITTED, OR IF ESTIMATED ERROR
C  SATISFACTORY, RESCALE ANSWERS AND RETURN.
C  INSERT THE FOLLOWING TWO STATEMENTS TO TRACE PROGRAM FLOW.
C     WRITE (6,910)
C 910 FORMAT ( 25H REFINEMENT NOT PERMITTED )
400   CCQUAD=WIDTH*NEWINT/FLOAT(N/2)
      ESTERR=WIDTH*ESTERR/FLOAT(N/2)

      RETURN
      END
      SUBROUTINE R3PASS(N2,M,LENGTH,X0,X1,X2)

c*********************************************************************72
C
C  RADIX 3 PASS FOR FAST FOURIER TRANSFORM OF REAL SEQUENCE
C  OF LENGTH N2.
C
C  THE NOTATION OF REFERENCES 2 AND 3 IS USED IN THIS
C  SUBROUTINE.
C  M IS THE LENGTH OF THE TRANSFORM ALREADY ACCOMPLISHED.
C  I.E., THE NUMBER OF DISTINCT VALUES OF THE FREQUENCY INDEX
C  C HAT OF THESE TRANSFORMS, AND THE SPACING OF THE
C  SEQUENCES TO BE TRANSFORMED.  EXPLICIT USE IS MADE OF THE
C  FACT THAT M IS EVEN AND NOT LESS THAN 4.
C
      IMPLICIT NONE

      INTEGER N2,M,LENGTH
      REAL X0(LENGTH),X1(LENGTH),X2(LENGTH)

      INTEGER HALF_M,M3,K,K0,K1,J,J0,J1
      REAL TWOPI,HAFRT3,RSUM,RDIFF,RSUM2,ISUM,IDIFF,IDIFF2
      REAL FUND,ANGLE,C1,S1,C2,S2,R0,R1,R2,I0,I1,I2
      DATA TWOPI, HAFRT3 / 6.283185307E0, .866025403E0 /
      HALF_M=(M-1)/2
      M3=M*3
      FUND=TWOPI/FLOAT(M3)
C  DO ALL TRANSFORMS FOR C HAT = 0, I.E., TWIDDLE FACTOR UNITY.
      DO 10 K=1,N2,M3
        RSUM=(X1(K)+X2(K))
        RDIFF=(X1(K)-X2(K))*HAFRT3
        X1(K)=X0(K)-RSUM*.5E0
        X2(K)=RDIFF
        X0(K)=X0(K)+RSUM
10    CONTINUE
C  DO ALL TRANSFORMS FOR C HAT = CAP C/2, I.E., TWIDDLE FACTOR.
C  E(B/6)
      J=M/2+1
      DO 20 K=J,N2,M3
        RSUM=(X1(K)+X2(K))*HAFRT3
        RDIFF=(X1(K)-X2(K))
        X1(K)=X0(K)-RDIFF
        X2(K)=RSUM
        X0(K)=X0(K)+RDIFF*.5E0
20    CONTINUE
C  DO ALL TRANSFORMS FOR REMAINING VALUES OF C HAT.  OBSERVE
C  THAT C HAT AND CAP C-C HAT MUST BE PAIRED.
C  CHOOSE A FREQUENCY INDEX.
      DO 40 J=1,HALF_M
        J0=J+1
        J1=M-J+1
C  COMPUTE THE TWIDDLE FACTOR.
        ANGLE=FUND*FLOAT(J)
        C1=COS(ANGLE)
        S1=SIN(ANGLE)
        C2=C1**2-S1**2
        S2=2.E0*S1*C1
C  CHOOSE THE REPLICATION.
        DO 30 K0=J0,N2,M3
          K1=K0-J0+J1
C  OBTAIN TWIDDLED VALUES.
          R0=X0(K0)
          I0=X0(K1)
          R1=C1*X1(K0)-S1*X1(K1)
          I1=S1*X1(K0)+C1*X1(K1)
          R2=C2*X2(K0)-S2*X2(K1)
          I2=S2*X2(K0)+C2*X2(K1)
C  COMPUTE TRANSFORMS AND RETURN IN PLACE.
          RSUM=R1+R2
          RDIFF=(R1-R2)*HAFRT3
          RSUM2=R0-.5E0*RSUM
          ISUM=I1+I2
          IDIFF=(I1-I2)*HAFRT3
          IDIFF2=I0-.5E0*ISUM
          X0(K0)=R0+RSUM
          X0(K1)=RSUM2+IDIFF
          X1(K0)=RSUM2-IDIFF
          X1(K1)=RDIFF+IDIFF2
          X2(K0)=RDIFF-IDIFF2
          X2(K1)=I0+ISUM
30      CONTINUE
40    CONTINUE

      RETURN
      END
