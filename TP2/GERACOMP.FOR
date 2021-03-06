C                                                                       
C      ESTE PROGRAMA CALCULA OS COMPRIMENTOS E OS RUMOS SOBRE O PLANO   
C  CARTOGRAFICO A PARTIR DAS COORDENADAS COMPENSADAS DOS SEUS EXTREMOS. 
C      COM RECURSO 'A FUNCAO G05DDF  SIMULA ERROS  
C  NORMAIS SOBRE ESSES COMPRIMENTOS, TRANSFORMANDO-OS EM SEGUIDA NOS    
C  CORRESPONDENTES COMPRIMENTOS SOBRE O ELIPSOIDE.                      
C      CALCULA TAMBEM OS PESOS COM QUE ESSES COMPRIMENTOS DEVEM         
C  ENTRAR NA FUTURA COMPENSACAO. 
C                                       
       PROGRAM GERACOMP                                                                 
       IMPLICIT REAL*8(A-H,O-Z)
       REAL*4 G05DDF                                                    
C       CHARACTER*40 FICH1,FICH2
       EXTERNAL G05DDF
       DIMENSION AM(30),P(30)
       DATA AM,P/30*0.D0,30*0.D0/
       NIL=0
       pi=4*datan(1.D0)

C  LE NUMERO DE VERTICES DA REDE E SUAS COORDENADAS PLANAS
C       WRITE(6,'(a50)') 'NOME DO FICHEIRO DE COORDENADAS ?'
C       READ(5,'(a20)') FICH1
       OPEN(1,FILE='GERACOMP.IN',STATUS='OLD')
C       WRITE(6,'(a50)') 'NOME DO FICHEIRO DE SAIDA? '
C       READ(5,'(a20)') FICH2
C       OPEN(2,FILE=FICH2)
	 OPEN(3,FILE='GERACOMP.OUT')
       READ(1,*) N 
	 
C      CALCULO DA PRECISAO
C      LE PARAMETROS DE PRECISAO DO DISTANCIOMETRO: (A , B)
C      E A VARIANCIA DA UNIDADE DE PESO USADA NA COMPENSACAO.
C                                                                       
c       WRITE(6,'(a50)') 'PARAMETROS DO DISTANCIOMETRO (p e q)? '
       READ(1,*) A,B                                                    
c       WRITE(6,'(a50)') 'VARIANCIA DA UNIDADE DE PESO NA COMPENSACAO? '
       READ(1,*) VAR
C
C      LEITURA DA CONSTANTE MULTIPLICATIVA DA FORMULA
C      QUE DA' A CORRECCAO CARTOGRAFICA AOS COMPRIMENTOS
C                                                                       
c       WRITE(6,'(a50)') 'VALOR DE 1/(6*K0**2*(RO*N)) ? '
       READ(1,*) CONST	 
	                                                      
c       N=N1+N2
       DO 10 I=1, N
       READ(1,*) J,AM(I),P(I)
10     CONTINUE

	WRITE(3,'(6(A,5X))') 
	1 'VISADA', 'DIST.OBS', 'PRECIS.', 'DIST.ELIPS.', 'PESO', ' RUMO'
C
C      CICLO PARA CALCULO DE TODOS OS COMPRIMENTOS ENTRE
C      PARES DE PONTOS DA REDE
	 NC=0
       DO 40 I=1, N
	  DO 30 J= I+1, N
	  NC=NC+1		

	  AM1 = AM(J)-AM(I)
	  P1 = P(J)-P(I)
	  RUMO =(DATAN(AM1/P1))*180/3.1415927
	  IF (RUMO.LT.0.D0) RUMO=RUMO+360

C  COMPRIMENTO NO PLANO CARTOGRAFICO
	  D=DSQRT(AM1**2+P1**2)
C	  WRITE(2,100)I,J,D

	  SIGMA=DSQRT(A**2+B**2*D**2)
C	  WRITE(2,200) SIGMA
C  CHAMA A SUBROTINA G05DDF QUE GERA UM VALOR ALEATÓRIO ENTRE 0 E 1
	  RAND1= G05DDF(NIL)                                                                       
	  RAND2= G05DDF(NIL)
C  GERA UMA DISTRIBUICAO NORMAL          
	  z1=dsqrt(-2*dlog(rand1))*dsin(2*pi*rand2)
	  z2=dsqrt(-2*dlog(rand1))*dcos(2*pi*RAND2)
	 IF(NC.EQ.2) GOTO 55
	  ERNORM = z1 * SIGMA
	  COMPOB = D + ERNORM
C	  WRITE(2,300) COMPOB
	 IF(NC.EQ.1) GOTO 45
  55	 ERNORM = z2 * SIGMA
	   COMPOB = D + ERNORM
C	  WRITE(2,300) COMPOB
	  NC=0

C  CALCULA CORRECCAO CARTOGRAFICA A SUBTRAIR AO COMPRIMENTO PLANO
C  PARA O TRANSFORMAR EM ELIPSOIDAL

  45    CORREC = CONST*COMPOB*(AM(J)**2+AM(I)*AM(J)+AM(I)**2)
	  COMPEL = COMPOB - CORREC
C	  WRITE(2,400) COMPEL
	  PESO = VAR/(SIGMA**2)
C	  WRITE(2,500) PESO

C	  WRITE(2,600) RUMO
C	  WRITE(2,700)
	  WRITE(3,800) I,J,COMPOB,SIGMA,COMPEL,PESO,RUMO
30       CONTINUE
40     CONTINUE
       STOP
C100    FORMAT(2X,'  DISTANCIA ENTRE OS PONTOS',I2,' E',I3,' = ',F11.4/)
C200    FORMAT(2X,'  PRECISAO                  ',F10.4/)
C300    FORMAT(2X,'  COMPRIMENTO OBSERVADO     ',F11.4/)
C400    FORMAT(2X,'  COMPRIMENTO SOBRE O ELIPSOIDE   ',F11.4/)
C500    FORMAT(2X,'  VALOR DO PESO',F12.4/)
C600    FORMAT(2X,'  VALOR DO RUMO',F12.4/)
C700    FORMAT(//)
800    FORMAT(2(I2,2X),F12.4,F10.4,F16.4,F11.1,F11.4)
       END
       
       FUNCTION G05DDF(NIL)
C FUNCAO PARA A GERACAO DE NUMEROS PSEUDO-ALEATORIOS EM (0,1)
C SEGUNDO SENNE (1974, JOURNAL OF STOCHASTICS, VOL. 1,3,215-238)
C
C      FUNCTION G05DDF(NIL)
C DADOS FIXOS
      DATA M12 / 4096 /
      DATA F1/2.44140625E-4/,F2/5.96046448E-8/,F3/.145519152E-10/
      DATA J1/3823/, J2/4006/, J3/2903/
C DADOS INICIAIS EM SEGUIDA RECALCULADOS
      DATA I1 /3823/, I2/4006/, I3/2903/
C CALCULO DA CONGRUENCIA COM SEGMENTACAO DOS NUMEROS
      K3=I3*J3
      L3=K3/M12
      K2=I2*J3+I3*J2+L3
      L2=K2/M12
      K1=I1*J3+I2*J2+I3*J1+L2
      L1=K1/M12
      I1=K1-L1*M12
      I2=K2-L2*M12
      I3=K3-L3*M12
      G05DDF=F1*I1+F2*I2+F3*I3
      RETURN
      END
