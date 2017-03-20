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

#define CT_ALL 1
#define CT_ENGULF 2
#define CT_25P 3 
#define CT_50P 4
#define CT_75P 5
#define CT_1ATR 6
#define CT_15ATR 7
#define CT_2ATR 8
#define CT_SWING 9
#define CT_INVSWING 10
#define CT_TOUCHEXT 11
#define CT_CLOSEEXT 12
#define CT_ID 13



// empty to do all basic swing pairs, futures to do TBILLS, bund etc (used on Window Demo)
input string CustomSymbols = "";        // FUTURES or empty

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int total = 0;
int HH = 0;
int HHHC = 0;
int BULL = 0;
int ID = 0;

string buy = "";
int stats_file = 0;

void runBars(string type, int closeType, string symbol) {

   int barType = ( type == "sell" ? TRADE_ARROW_SELL : TRADE_ARROW_BUY );
   HH = 0;
   HHHC = 0;
   BULL = 0;
   ID = 0;
   total = 0;

   int last = TRADE_ARROW_NONE;
   for ( int i = iBars(symbol,PERIOD_D1)-21; i > 1 ; i-- ) {
      
      int e = detectEngulf(symbol,PERIOD_D1,i);
         if ( e != TRADE_ARROW_NONE ) {
         if ( e == TRADE_ARROW_SELL ) {
        //    ArrowDownCreate("aeed"+type+i,symbol,i,clrAliceBlue);
         } else {
        //    ArrowUpCreate("aeeu"+type+i,symbol,i,clrAliceBlue);
         }
        }
      // check the type, we must be doing a bar that meets the close requirements before
      // we bother checking further
      switch ( closeType ) {
         case CT_1ATR: if ( percentOfATR(symbol,PERIOD_D1,i) > 1 ) { e = TRADE_ARROW_NONE; } break;
         case CT_15ATR: if ( percentOfATR(symbol,PERIOD_D1,i) <= 1 || percentOfATR(symbol,PERIOD_D1,i) > 1.5 ) { e = TRADE_ARROW_NONE; } break;
         case CT_2ATR: if ( percentOfATR(symbol,PERIOD_D1,i) < 2 ) { e = TRADE_ARROW_NONE; } break;
         case CT_SWING: if ( !isSwingBar(symbol,barType,PERIOD_D1,i) ) { e = TRADE_ARROW_NONE; } break;
         case CT_INVSWING: if ( isSwingBar(symbol,barType,PERIOD_D1,i) || !isSwingBar(symbol,barType == TRADE_ARROW_BUY ? TRADE_ARROW_SELL : TRADE_ARROW_BUY,PERIOD_D1,i) ) { e = TRADE_ARROW_NONE; } break;
         // did we touch (get a high  / low) beyond the extreme (bolliger bands)
         case CT_TOUCHEXT: 
               if ( iHigh(symbol,PERIOD_D1,i) > iBands(symbol,PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,i) ||
                    iLow(symbol,PERIOD_D1,i) < iBands(symbol,PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,i) ) {
               } else {
                  e = TRADE_ARROW_NONE;       
               }
               break;
         // did we closebeyond the extreme (bolliger bands)
         case CT_CLOSEEXT: 
               if ( iClose(symbol,PERIOD_D1,i) > iBands(symbol,PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,i) ||
                    iClose(symbol,PERIOD_D1,i) < iBands(symbol,PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,i) ) {
               } else {
                  e = TRADE_ARROW_NONE;       
               }
               break;
         // did we engulf an inside day
         case CT_ID: if ( !detectInsideBar(symbol,PERIOD_D1,i+1) ) { e = TRADE_ARROW_NONE; } break;
         default: break;// no special type, just move on
      }

      if ( e != TRADE_ARROW_NONE && e == barType ) {
         if ( barType == TRADE_ARROW_SELL ) {
            ArrowDownCreate("ad"+type+i,symbol,i);
         } else {
            ArrowUpCreate("au"+type+i,symbol,i);
         }
         total++;
         
         double high = iHigh(symbol,PERIOD_D1,i);    
         double low = iLow(symbol,PERIOD_D1,i);
         double open = iOpen(symbol,PERIOD_D1,i);
         double close = iClose(symbol,PERIOD_D1,i);
         
         if ( e == TRADE_ARROW_BUY ) {
            if ( iHigh(symbol,PERIOD_D1,i-1) > high ) {
               HH++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) > high ) {
               HHHC++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) > iOpen(symbol,PERIOD_D1,i-1) ) {
               BULL++;
            }
            if ( detectInsideBar(symbol,PERIOD_D1,i-1) ) {
               ID++;
            }            
         } else if ( e == TRADE_ARROW_SELL ) {
            if ( iLow(symbol,PERIOD_D1,i-1) < low ) {
               HH++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) < low ) {
               HHHC++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) < iOpen(symbol,PERIOD_D1,i-1) ) {
               BULL++;
            }
            if ( detectInsideBar(symbol,PERIOD_D1,i-1) ) {
               ID++;
            }            
         }
         
      }
   }
   
   double pHH = ( total == 0 ? 0 : (double)HH / (double)total );
   double pHHHC = ( total == 0 ? 0 : (double)HHHC / (double)total );   
   double pBULL = ( total == 0 ? 0 : (double)BULL / (double)total );
   double pID = ( total == 0 ? 0 : (double)ID / (double)total );
   
   buy += (string)total+";" + (string)pHH + ";" + (string)pHHHC + ";" + (string)pBULL + ";" + (string)pID;
}

void process(string type, string symbol) {
   
 //  runBars(type, CT_ALL, symbol);
 //  runBars(type, CT_1ATR, symbol);
 //  runBars(type, CT_15ATR, symbol);
  // runBars(type, CT_2ATR, symbol);
  // runBars(type, CT_SWING, symbol);
  // runBars(type, CT_INVSWING, symbol);
   runBars(type, CT_TOUCHEXT, symbol);
   runBars(type, CT_CLOSEEXT, symbol);
     
   FileWriteString(stats_file, symbol + ";"+(string)iBars(symbol,PERIOD_D1)+";" + buy + "\r\n");
}

void dotype(string type) {
 
   FileDelete("Data//engulf-"+type+".csv");
   stats_file = FileOpen("Data//engulf-"+type+".csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);

   FileWriteString(stats_file, ";;Standard;;;;;Range < 1ATR;;;;;Range < 2ATR;;;;;Range > 2ATR;;;;;Swing Point;;;;;Inv Swing;;;;;Touch Bands;;;;;Close Bands;;;;;Pop Gun (Egf ID);;;;;\r\n");
   FileWriteString(stats_file, ";;Bars;HH/LL;HC/LC;UP/DN;ID;Bars;HH/LL;HC/LC;UP/DN;ID;Bars;HH/LL;HC/LC;UP/DN;ID;Bars;HH/LL;HC/LC;UP/DN;ID;Bars;HH/LL;HC/LC;ID;UP/DN;Bars;HH/LL;HC/LC;ID;UP/DN;Bars;HH/LL;HC/LC;ID;UP/DN;Bars;HH/LL;HC/LC;ID;UP/DN;Bars;HH/LL;HC/LC;ID;UP/DN;\r\n");
   
   if ( CustomSymbols == "debug" ) {
      process(type,Symbol());
   } else {
      if ( CustomSymbols == "" ) {
         process(type,"AUDUSD");
         process(type,"GBPUSD");
         process(type,"GBPJPY");
         process(type,"EURGBP");
         process(type,"EURUSD");
         process(type,"EURJPY");
         process(type,"USDCAD");
         process(type,"USDJPY");
         process(type,"NZDUSD");
         process(type,"GOLD");
         process(type,"SILVER");
         process(type,"WTI"); 
      } else {
         process(type,"10TBILL"); 
         process(type,"5TBILL"); 
         process(type,"2TBILL"); 
         process(type,"US30"); 
         process(type,"US100"); 
         process(type,"USINDX"); 
         process(type,"GER30"); 
         process(type,"EU50"); 
         process(type,"EURBUND"); 
      }
   }
   
   FileClose(stats_file);
}

int OnInit()
{
//--- indicator buffers mapping
   
   ObjectsDeleteAll( 0);

   dotype("buy");
   dotype("sell");
   
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
