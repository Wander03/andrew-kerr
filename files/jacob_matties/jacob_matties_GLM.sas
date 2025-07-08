FILENAME REFFILE '/home/u59498461/Jacob Matties/BalanceData-JM.xlsx';

PROC IMPORT DATAFILE=REFFILE
    
    DBMS=XLSX
    
    OUT=WORK.BalanceData;
    
    GETNAMES=YES;
    
    SHEET="Results";

RUN;

PROC DATASETS LIBRARY=WORK;
    
    MODIFY BalanceData;
    
    RENAME '3D RMS Accel. (24 s) [m/s^2]'n = RMS_Accel
           'Phone Position'n = PhonePosition
           'Participant'n = Subject;

RUN;

/* Data exploration */
PROC MEANS DATA=WORK.BalanceData;

    CLASS PhonePosition Stance;

    VAR Subject;

RUN;

PROC SORT DATA=WORK.BalanceData;

    BY Subject;

RUN;

/* Mixed model analysis */
PROC GLIMMIX DATA=WORK.BalanceData plots = residualpanel;

    CLASS Subject PhonePosition Stance;
    
    MODEL RMS_Accel = PhonePosition Stance PhonePosition*Stance /
    
          DIST=GAMMA LINK=LOG;
          
    RANDOM INTERCEPT / SUBJECT=Subject;
    
    LSMEANS PhonePosition*Stance / plot=meanplot(sliceby = stance join cl ilink) ilink;
    SLICE   PhonePosition*Stance / Sliceby = PhonePosition ADJUST = tukey lines;

	OUTPUT OUT=GLMM_out PREDICTED=Predicted RESIDUAL=Residual;
	
    ODS OUTPUT FitStatistics=FitStats;

RUN;
