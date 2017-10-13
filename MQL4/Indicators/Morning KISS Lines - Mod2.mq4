//-------------------------------------------------------------------
//   Name: Morning KISS Lines.mq4
//-------------------------------------------------------------------

#property indicator_chart_window

#define INDICATOR_NAME "Morning KISS Lines"
#define INDICATOR_VERSION "v0.1"

extern int       IndicatorNr=1;       // Nr of this indicator instance on the chart
extern int       NrOfDays=10;          // Nr of past days to draw the session channel for
extern int       BrokerTime=0;
// Indicator parameters
extern string    Info1="<< 06:30  >>";
extern bool      VLine1Show=true;     
extern int       VLine1Hour=07;       
extern bool      VLine1OnHour=true;  
extern color     VLine1Color=Gold;    
extern int       VLine1Style=2;       
extern int       VLine1Width=1;       
extern string    VLine1label="06:30";   

extern string    Info2="<<  FO  >>";
extern bool      VLine2Show=true;      
extern int       VLine2Hour=8;        
extern bool      VLine2OnHour=true;   
extern color     VLine2Color=Orange;     
extern int       VLine2Style=2;        
extern int       VLine2Width=1;        
extern string    VLine2label="FO";  

extern string    Info3="<<  07:30  >>";
extern bool      VLine3Show=true;     
extern int       VLine3Hour=8;        
extern bool      VLine3OnHour=true;    
extern color     VLine3Color=Gold;     
extern int       VLine3Style=2;        
extern int       VLine3Width=1;        
extern string    VLine3label="07:30";

extern string    Info4="<< LO  >>";
extern bool      VLine4Show=true;     
extern int       VLine4Hour=9;        
extern bool      VLine4OnHour=true;    
extern color     VLine4Color=Orange;     
extern int       VLine4Style=2;        
extern int       VLine4Width=1;        
extern string    VLine4label="LO";

extern string    Info5="<< 08:30  >>";
extern bool      VLine5Show=true;     
extern int       VLine5Hour=9;        
extern bool      VLine5OnHour=true;    
extern color     VLine5Color=Gold;     
extern int       VLine5Style=2;        
extern int       VLine5Width=1;        
extern string    VLine5label="08:30";

extern string    Info6="<<  09:00  >>";
extern bool      VLine6Show=true;     
extern int       VLine6Hour=10;        
extern bool      VLine6OnHour=true;    
extern color     VLine6Color=Gold;     
extern int       VLine6Style=2;        
extern int       VLine6Width=1;        
extern string    VLine6label="09:00";

extern string    Info7="<< 09:30  >>";
extern bool      VLine7Show=true;     
extern int       VLine7Hour=10;        
extern bool      VLine7OnHour=true;    
extern color     VLine7Color=Gold;     
extern int       VLine7Style=2;        
extern int       VLine7Width=1;        
extern string    VLine7label="09:30";

extern string    Info8="<< 10:00  >>";
extern bool      VLine8Show=true;     
extern int       VLine8Hour=11;        
extern bool      VLine8OnHour=true;    
extern color     VLine8Color=Gold;     
extern int       VLine8Style=2;        
extern int       VLine8Width=1;        
extern string    VLine8label="10:00";

extern string    Info9="<< 10:30  >>";
extern bool      VLine9Show=true;     
extern int       VLine9Hour=11;        
extern bool      VLine9OnHour=true;    
extern color     VLine9Color=Gold;     
extern int       VLine9Style=2;        
extern int       VLine9Width=1;        
extern string    VLine9label="10:30"; 

extern string    Info10="<< 11:00  >>";
extern bool      VLine10Show=true;     
extern int       VLine10Hour=12;       
extern bool      VLine10OnHour=true;   
extern color     VLine10Color=Gold;    
extern int       VLine10Style=2;       
extern int       VLine10Width=1;       
extern string    VLine10label="11:00";

extern string    Info11="<< 06:00  >>";
extern bool      VLine11Show=true;     
extern int       VLine11Hour=7;       
extern bool      VLine11OnHour=true;   
extern color     VLine11Color=Gold;    
extern int       VLine11Style=2;       
extern int       VLine11Width=1;       
extern string    VLine11label="06:00";

extern string    Info12="<< Tokyo Open  >>";
extern bool      VLine12Show=true;     
extern int       VLine12Hour=0;       
extern bool      VLine12OnHour=true;   
extern color     VLine12Color=FireBrick;    
extern int       VLine12Style=2;       
extern int       VLine12Width=1;       
extern string    VLine12label="Tokyo Open";

extern string    Info13="<< NY Open 1  >>";
extern bool      VLine13Show=true;     
extern int       VLine13Hour=14;       
extern bool      VLine13OnHour=true;   
extern color     VLine13Color=Green;    
extern int       VLine13Style=2;       
extern int       VLine13Width=1;       
extern string    VLine13label="NY Open 1";

extern string    Info14="<< NY Open 2  >>";
extern bool      VLine14Show=true;     
extern int       VLine14Hour=15;       
extern bool      VLine14OnHour=true;   
extern color     VLine14Color=Green;    
extern int       VLine14Style=2;       
extern int       VLine14Width=1;       
extern string    VLine14label="NY Open 2";

// Indicator data
bool mbRunOnce;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- Set Indicator Name
   IndicatorShortName(INDICATOR_NAME+IndicatorNr+"-"+INDICATOR_VERSION);   
   mbRunOnce=false;
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  // Clear objects
  for(int i=ObjectsTotal()-1; i>-1; i--)
    if (StringFind(ObjectName(i),INDICATOR_NAME+IndicatorNr)>=0)  ObjectDelete(ObjectName(i));
  return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int iNewBars;
  int iCountedBars;   
 
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1);
  iNewBars=Bars-iCountedBars;
  
  // Draw old sessions
  if (mbRunOnce==false || iNewBars>3) {
    if (VLine1Show==true) DrawPreviousVLine1();
    if (VLine2Show==true) DrawPreviousVLine2();
    if (VLine3Show==true) DrawPreviousVLine3();
    if (VLine4Show==true) DrawPreviousVLine4(); 
    if (VLine5Show==true) DrawPreviousVLine5(); 
    if (VLine6Show==true) DrawPreviousVLine6();
    if (VLine7Show==true) DrawPreviousVLine7();
    if (VLine8Show==true) DrawPreviousVLine8();
    if (VLine9Show==true) DrawPreviousVLine9();
    if (VLine10Show==true) DrawPreviousVLine10();
    if (VLine11Show==true) DrawPreviousVLine11();
    if (VLine12Show==true) DrawPreviousVLine12();
    if (VLine13Show==true) DrawPreviousVLine13();
    if (VLine14Show==true) DrawPreviousVLine14();
    mbRunOnce=true;
  } //endif  
  
    DrawCurrentVLines(iNewBars);
//----
   return(0);
  }
//+------------------------------------------------------------------+


int DrawCurrentVLines(int iNewTicks) {
  int iLineOnHour;
  int i;
  int iNrOfDays;

  for(i=0; i<=iNewTicks; i++) {
    if (VLine1Show==true && TimeHour(Time[i])==VLine1Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine1OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine1Width,VLine1Color,"Line1");
      if (StringLen(VLine1label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine1label,VLine1Color);
    }
    if (VLine2Show==true && TimeHour(Time[i])==VLine2Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine2OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine2Style,VLine2Width,VLine2Color,"Line2");
      if (StringLen(VLine2label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine2label,VLine2Color);
    }
    if (VLine3Show==true && TimeHour(Time[i])==VLine3Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine3OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine3Style,VLine3Width,VLine3Color,"Line3");
      if (StringLen(VLine3label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine3label,VLine3Color);
    }
    if (VLine4Show==true && TimeHour(Time[i])==VLine4Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine4OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine4Style,VLine4Width,VLine4Color,"Line4");
      if (StringLen(VLine4label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine4label,VLine4Color);
    }
    if (VLine5Show==true && TimeHour(Time[i])==VLine5Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine5OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine5Style,VLine5Width,VLine5Color,"Line5");
      if (StringLen(VLine5label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine5label,VLine5Color);
    }
    if (VLine6Show==true && TimeHour(Time[i])==VLine6Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine6OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine5Style,VLine5Width,VLine6Color,"Line6");
      if (StringLen(VLine6label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine6label,VLine6Color);
    }
    if (VLine7Show==true && TimeHour(Time[i])==VLine7Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine7OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine7Style,VLine7Width,VLine7Color,"Line7");
      if (StringLen(VLine7label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine7label,VLine7Color);
    }
    if (VLine8Show==true && TimeHour(Time[i])==VLine8Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine8OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine8Style,VLine8Width,VLine8Color,"Line8");
      if (StringLen(VLine8label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine8label,VLine8Color);
    }
    if (VLine9Show==true && TimeHour(Time[i])==VLine9Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine9OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine9Style,VLine9Width,VLine9Color,"Line9");
      if (StringLen(VLine9label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine9label,VLine9Color);
    }
    if (VLine10Show==true && TimeHour(Time[i])==VLine10Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine10OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine10Style,VLine10Width,VLine10Color,"Line5");
      if (StringLen(VLine10label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine10label,VLine10Color);
    }
    if (VLine11Show==true && TimeHour(Time[i])==VLine11Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine11OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine11Style,VLine11Width,VLine11Color,"Line5");
      if (StringLen(VLine11label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine11label,VLine11Color);
    }    
    if (VLine12Show==true && TimeHour(Time[i])==VLine12Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine12OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine12Style,VLine12Width,VLine12Color,"Line5");
      if (StringLen(VLine12label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine12label,VLine12Color);
    }    
    if (VLine13Show==true && TimeHour(Time[i])==VLine13Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine13OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine13Style,VLine13Width,VLine13Color,"Line5");
      if (StringLen(VLine13label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine13label,VLine13Color);
    }    
    if (VLine14Show==true && TimeHour(Time[i])==VLine14Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine14OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine14Style,VLine14Width,VLine14Color,"Line5");
      if (StringLen(VLine14label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine14label,VLine14Color);
    }         
  }
  return(0);
}


int DrawPreviousVLine1() {
  int iLineOnHour;
  int i;
  int iNrOfDays;
  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine1Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine1OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine1Width,VLine1Color,"VLine1");
      if (StringLen(VLine1label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine1label,VLine1Color);
      iNrOfDays++;  
    }    
    i++;
  }
  return(0);
}

int DrawPreviousVLine2() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine2Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine2OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine2Style,VLine2Width,VLine2Color,"VLine2");
      if (StringLen(VLine2label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine2label,VLine2Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine3() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine3Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine3OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine3Style,VLine3Width,VLine3Color,"VLine3");
      if (StringLen(VLine3label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine3label,VLine3Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine4() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine4Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine4OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine4Style,VLine4Width,VLine4Color,"VLine4");
      if (StringLen(VLine4label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine4label,VLine4Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine5() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine5Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine5OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine5Style,VLine5Width,VLine5Color,"VLine5");
      if (StringLen(VLine5label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine5label,VLine5Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine6() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine6Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine6OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine6Style,VLine6Width,VLine6Color,"VLine6");
      if (StringLen(VLine5label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine6label,VLine6Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine7() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine7Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine7OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine7Style,VLine7Width,VLine7Color,"VLine7");
      if (StringLen(VLine7label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine7label,VLine7Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine8() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine8Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine8OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine8Style,VLine8Width,VLine8Color,"VLine8");
      if (StringLen(VLine8label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine8label,VLine8Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine9() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine9Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine9OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine9Style,VLine9Width,VLine9Color,"VLine9");
      if (StringLen(VLine9label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine9label,VLine9Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}   

int DrawPreviousVLine10() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine10Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine10OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine10Width,VLine10Color,"VLine10");
      if (StringLen(VLine10label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine10label,VLine10Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}

int DrawPreviousVLine11() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine11Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine11OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine11Width,VLine11Color,"VLine11");
      if (StringLen(VLine11label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine11label,VLine11Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}

int DrawPreviousVLine12() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine12Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine12OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine12Width,VLine12Color,"VLine12");
      if (StringLen(VLine12label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine12label,VLine12Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}

int DrawPreviousVLine13() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine13Hour + BrokerTime && TimeMinute(Time[i])==0) {
      if (VLine13OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine13Width,VLine13Color,"VLine13");
      if (StringLen(VLine13label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine13label,VLine13Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}

int DrawPreviousVLine14() {
  int iLineOnHour;
  int i;
  int iNrOfDays;  
  
  // Set the closing bar. On hour bar or on previous bar.    
  // Draw asian session for old data
  i=0;iNrOfDays=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==VLine14Hour + BrokerTime && TimeMinute(Time[i])==30) {
      if (VLine14OnHour==True) iLineOnHour=0; else iLineOnHour=1;
      DrawLine(Time[i+iLineOnHour],VLine1Style,VLine14Width,VLine14Color,"VLine14");
      if (StringLen(VLine14label)>0) DrawTextLabel(Time[i+iLineOnHour],VLine14label,VLine14Color);
      iNrOfDays++;  
    }
    i++;
  }
  return(0);
}

//-----------------------------------------------------------------------------
// function: DrawLine()
// Description: Draw a horizontal line at specific price
//----------------------------------------------------------------------------- 
int DrawLine(double tTime, int iLineStyle, int iLineWidth, color cLineColor, string sId) {
  string sLineId;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+IndicatorNr+"_"+sId+"_"+TimeToStr(tTime,TIME_DATE );
  
  // Draw line
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);
  ObjectCreate(sLineId, OBJ_TREND, 0, tTime, 0, tTime, 10); 
  //ObjectCreate(sLineId, OBJ_VLINE, 0, tTime, 0); 
  ObjectSet(sLineId, OBJPROP_STYLE, iLineStyle);     
  ObjectSet(sLineId, OBJPROP_WIDTH, iLineWidth);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSet(sLineId, OBJPROP_COLOR, cLineColor);    
  return(0);
}

//-----------------------------------------------------------------------------
// function: DrawTextLabel()
// Description: Draw a text label for a line
//-----------------------------------------------------------------------------
int DrawTextLabel(double tTime, string sLabel, color cLineColor) {
  double tTextPos=0;
  string sLineLabel="";
  string sLineId;
  color cTextColor;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+IndicatorNr+"_"+sLabel+"_"+TimeToStr(tTime,TIME_DATE );
  
  //Set position of text label
  tTextPos=WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())/12;
  //PrintD("tTextPos: "+tTextPos);
  // Draw or text label  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, tTextPos);    
  ObjectSet(sLineId, OBJPROP_ANGLE, 90);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSetText(sLineId, sLabel , 8, "Arial", cLineColor);
 
  return(0);
}

