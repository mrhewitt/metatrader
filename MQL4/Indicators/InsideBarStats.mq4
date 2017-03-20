//+------------------------------------------------------------------+
//|                                               BollingerStats.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include "../Include/detectXXX.mqh"
#include "../Include/Statistics.mqh"

// empty to do all basic swing pairs, futures to do TBILLS, bund etc (used on Window Demo)
input string CustomSymbols = "";        // FUTURES or empty

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int stats_file=0;

void process(string symbol) {

   int total_id = 0;
   int total_idf = 0;
   int total_idf_comp = 0;
   int total_ibo = 0;
   int total_ibo_bull = 0;
   int total_ibo_bear = 0;
   int total_ibe = 0;
   int total_ibe_bear = 0;
   int total_ibe_bull = 0;
    
   for ( int i = iBars(symbol,PERIOD_D1)-1; i > 1 ; i-- ) {
   
      if ( detectInsideBar(symbol,PERIOD_D1,i) ) {
         total_id++;   
      }
      
      if ( isInsideBarFailure(symbol,PERIOD_D1,i) ) {
         total_idf++;
      }
      
      if ( isInsideBarFailure(symbol,PERIOD_D1,i) && isIDFComplete(symbol,PERIOD_D1,i) ) {
         total_idf_comp++;
      }
      
      int x = detectIBOutsideClose(symbol,PERIOD_D1,i);
      if ( x != TRADE_ARROW_NONE ) {
        total_ibo++; 
        if ( x == TRADE_ARROW_BUY ) {
          total_ibo_bull++;
         } else {
          total_ibo_bear++;
      }
      }
      
      x = detectIBEngulf(symbol,PERIOD_D1,i);
      if ( x != TRADE_ARROW_NONE ) {
        total_ibe++;
        if ( x == TRADE_ARROW_BUY ) {
          total_ibe_bull++;
         } else {
          total_ibe_bear++;
         }
      }
      
   }
   
   double pID = (double)total_id/(double)iBars(symbol,PERIOD_D1);
   double pIDF = total_id == 0 ? 0 : (double)total_idf/(double)total_id;
   double pIDFC = total_idf == 0 ? 0 : (double)total_idf_comp/(double)total_idf;

   double pIBO = total_ibo == 0 ? 0 : (double)total_ibo/(double)total_id;
   double pIBO_Bull = total_ibo == 0 ? 0 : (double)total_ibo_bull/(double)total_ibo;
   double pIBO_Bear = total_ibo == 0 ? 0 : (double)total_ibo_bear/(double)total_ibo;
 
   double pIBE = total_ibe == 0 ? 0 : (double)total_ibe/(double)total_id;
   double pIBE_Bull = total_ibe == 0 ? 0 : (double)total_ibe_bull/(double)total_ibe;
   double pIBE_Bear = total_ibe == 0 ? 0 : (double)total_ibe_bear/(double)total_ibe;
     
   FileWriteString(stats_file, symbol + ";"+(string)iBars(symbol,PERIOD_D1)+";"+(string)total_idf+";" + (string)pID + ";" + (string)pIDF + ";" + (string)pIDFC+";" + (string)pIBO + ";" + (string)pIBO_Bull + ";" + (string)pIBO_Bear+";" + (string)pIBE + ";" + (string)pIBE_Bull + ";" + (string)pIBE_Bear + "\r\n");   
}

void run() {
 
   FileDelete("Data//inside-day.csv");
   stats_file = FileOpen("Data//inside-day.csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
   FileWriteString(stats_file, "Instr;Days;Total;%ID;%IDF;%IDF Comp;%Outer;%Outer Up;%Outer Down;%Engulf;%Engulf Up;%Engulf Down\r\n");   
   
   if ( CustomSymbols == "" ) {
      process("AUDUSD");
      process("GBPUSD");
      process("GBPJPY");
      process("EURGBP");
      process("EURUSD");
      process("EURJPY");
      process("USDCAD");
      process("USDJPY");
      process("NZDUSD");
      process("GOLD");
      process("SILVER");
      process("WTI"); 
   } else {
      process("10TBILL"); 
      process("5TBILL"); 
      process("2TBILL"); 
      process("US30"); 
      process("US100"); 
      process("USINDX"); 
      process("GER30"); 
      process("EU50"); 
      process("EURBUND"); 
   }
   
   FileClose(stats_file);
}

int OnInit()
{
//--- indicator buffers mapping
   
   ObjectsDeleteAll( 0);
   
   
   // % inside day
   // % idf
   // % idf completion
   // % running
   // if run % bearish
   // if run % bullish
   // % engulfed
   // if engulfed % bull engulf
   // if engulfed % bear engulf
   // if close low 30% % run bear
   // if close high 30% % run bullish 
   // range ran
   
   run();
return(INIT_SUCCEEDED);


   for ( int i = iBars(Symbol(),PERIOD_D1)-1; i > 1 ; i-- ) {
     /* if ( detectIBOutsideClose(Symbol(),PERIOD_D1,i) ) {
         ArrowDownCreate("ad"+i,iTime(Symbol(),PERIOD_D1,i),iHigh(Symbol(),PERIOD_D1,i));
      }
      
      if ( isInsideBarFailure(Symbol(),PERIOD_D1,i) ) {
         ArrowDownCreate("ad"+i,iTime(Symbol(),PERIOD_D1,i),iHigh(Symbol(),PERIOD_D1,i),clrAliceBlue);
      }*/
      int x = detectIBEngulf(Symbol(),PERIOD_D1,i);
      if ( x != TRADE_ARROW_NONE ) {
        // ArrowDownCreate("ad"+i,iTime(Symbol(),PERIOD_D1,i),iHigh(Symbol(),PERIOD_D1,i));
        if ( x == TRADE_ARROW_BUY ) {
          ArrowUpCreate("adg"+i,Symbol(),i-1);
         } else {
         ArrowDownCreate("adg"+i,Symbol(),i-1);
      }
      }


   } 

   
//---
   return(INIT_SUCCEEDED);

  }



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
