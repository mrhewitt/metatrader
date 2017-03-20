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


// empty to do all basic swing pairs, futures to do TBILLS, bund etc (used on Window Demo)
input string CustomSymbols = "";        // FUTURES or empty

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int total_sell = 0;
int total_buy = 0;
int HH = 0;
int LL =  0;
int HHHC = 0;
int LLLC = 0;
int BULL = 0;
int BEAR = 0;
string buy = "";
string sell = "";
int stats_file = 0;

void doArrow(string type, int e, string symbol, int i) {

      if ( type == "real" && e == TRADE_ARROW_BUY ) { 
         if ( !isBearBar(symbol,PERIOD_D1,i+1) ) { e = TRADE_ARROW_NONE; }
      } if ( type == "real" && e == TRADE_ARROW_SELL ) { 
         if ( !isBullBar(symbol,PERIOD_D1,i+1) ) { e = TRADE_ARROW_NONE; }
      } else if ( type == "two-bar" ) {
         // in 2-bar we want not only a real arrow (opposing bar types) but it must also be a two bar
         // i.e. if the arrow is on a bullish bar we want it to be a 2 bear bars preceding
         if ( e == TRADE_ARROW_BUY && detectTwoBar(symbol,PERIOD_D1,i) != TRADE_ARROW_SELL ) {
            e = TRADE_ARROW_NONE;
         } else if ( e == TRADE_ARROW_SELL && detectTwoBar(symbol,PERIOD_D1,i) != TRADE_ARROW_BUY ) {
            e = TRADE_ARROW_NONE;
         }
      } else if ( type == "engulf" && e != detectEngulf(symbol,PERIOD_D1,i) ) {
         e = TRADE_ARROW_NONE;
      }  
      
      if ( e != TRADE_ARROW_NONE ) {
         int c = clrRed;
         if ( e == TRADE_ARROW_BUY ) { c = clrForestGreen; }
        // VLineCreate("eb"+i,iTime(symbol,PERIOD_D1,i),c);
         
         double high = iHigh(symbol,PERIOD_D1,i);    
         double low = iLow(symbol,PERIOD_D1,i);
         double open = iOpen(symbol,PERIOD_D1,i);
         double close = iClose(symbol,PERIOD_D1,i);
         
         string LLHH = "NO";
         string LLHHC = "NO";
         string BB = "NO";

         if ( e == TRADE_ARROW_BUY ) {
            total_buy++;
            if ( iHigh(symbol,PERIOD_D1,i - 1) > high ) {
               LLHH = "YES";
               HH++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) > high ) {
               LLHHC = "YES";
               HHHC++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) > iOpen(symbol,PERIOD_D1,i - 1) ) {
               BB = "YES";
               BULL++;
            }
         } else {
             total_sell++;
             if ( iLow(symbol,PERIOD_D1,i - 1) < low ) {
               LLHH = "YES";
               LL++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) < low ) {
               LLHHC = "YES";
               LLLC++;
            }
            if ( iClose(symbol,PERIOD_D1,i-1) < iOpen(symbol,PERIOD_D1,i - 1) ) {
               BB = "YES";
               BEAR++;
            }
         }
      }
      
}

void runBars(string type, int closeType, string symbol) {

   HH = 0;
   LL =  0;
   HHHC = 0;
   LLLC = 0;
   BULL = 0;
   BEAR = 0;
   total_buy = total_sell = 0;

   int last = TRADE_ARROW_NONE;
   for ( int i = iBars(symbol,PERIOD_D1)-1; i > 1 ; i-- ) {
      
      int e = detectArrow(symbol,PERIOD_D1,i);      
      // check the type, we must be doing a bar that meets the close requirements before
      // we bother checking further
      switch ( closeType ) {
         // bar with the arrow must be an engulfing
         case CT_ENGULF: if ( detectEngulf(symbol,PERIOD_D1,i) == TRADE_ARROW_NONE ) { e = TRADE_ARROW_NONE; } break ;
         case CT_25P: if ( shadowRatio(symbol,PERIOD_D1,i) >= 0.25 ) { e = TRADE_ARROW_NONE; } break; 
         case CT_75P: if ( shadowRatio(symbol,PERIOD_D1,i) >= 0.75 ) { e = TRADE_ARROW_NONE; } break;
         case CT_50P: if ( shadowRatio(symbol,PERIOD_D1,i) < 0.25 || shadowRatio(symbol,PERIOD_D1,i) > 0.75 ) { e = TRADE_ARROW_NONE; } break;
         case CT_1ATR: if ( percentOfATR(symbol,PERIOD_D1,i) > 1 ) { e = TRADE_ARROW_NONE; } break;
         case CT_15ATR: if ( percentOfATR(symbol,PERIOD_D1,i) <= 1 || percentOfATR(symbol,PERIOD_D1,i) > 1.5 ) { e = TRADE_ARROW_NONE; } break;
         case CT_2ATR: if ( percentOfATR(symbol,PERIOD_D1,i) < 2 ) { e = TRADE_ARROW_NONE; } break;
         case CT_SWING: if ( !isSwingBar(symbol,PERIOD_D1,i) ) { e = TRADE_ARROW_NONE; } break;
         default: break;// no special type, just move on
      }

      if ( e != TRADE_ARROW_NONE ) {
        
         // if the last arroew found was the same type as this, then there was a vanishing arrow on last candle
         // as arroews always toggle each other
         if ( last == e ) { 
            if ( e == TRADE_ARROW_BUY ) { 
                doArrow( type, TRADE_ARROW_SELL, symbol, i+1);
            } else {
                doArrow( type, TRADE_ARROW_BUY, symbol, i+1);
            }
         }
         last = e;
         if ( e == TRADE_ARROW_BUY ) {
            doArrow(type,e,symbol,i);
         } else {
            doArrow(type,e,symbol,i);
         }
      }
   }
   
   double pHH = ( total_buy == 0 ? 0 : (double)HH / (double)total_buy );
   double pLL = ( total_sell == 0 ? 0 : (double)LL / (double)total_sell );
   
   double pHHHC = ( total_buy == 0 ? 0 : (double)HHHC / (double)total_buy );
   double pLLLC = ( total_sell == 0 ? 0 : (double)LLLC / (double)total_sell );
   
   double pBULL = ( total_buy == 0 ? 0 : (double)BULL / (double)total_buy );
   double pBEAR = ( total_sell == 0 ? 0 : (double)BEAR / (double)total_sell );

   buy += (string)total_buy+";" + (string)pHH + ";" + (string)pHHHC + ";" + (string)pBULL;
   sell += (string)total_sell+";" + (string)pLL + ";" + (string)pLLLC + ";" + (string)pBEAR;
}

void process(string type, string symbol) {
   
   runBars(type, CT_ALL, symbol);
   runBars(type, CT_ENGULF, symbol);
   runBars(type, CT_25P, symbol); 
   runBars(type, CT_50P, symbol);
   runBars(type, CT_75P, symbol);
   runBars(type, CT_1ATR, symbol);
   runBars(type, CT_15ATR, symbol);
   runBars(type, CT_2ATR, symbol);
   runBars(type, CT_SWING, symbol);
   
   FileWriteString(stats_file, symbol + ";BUY;"+(string)iBars(symbol,PERIOD_D1)+";" + buy + "\r\n");
   FileWriteString(stats_file, symbol + ";SELL;"+(string)iBars(symbol,PERIOD_D1)+";" + sell + "\r\n");
}

void dotype(string type) {
 
   FileDelete("Data//dayarrow-"+type+".csv");
   stats_file = FileOpen("Data//dayarrow-"+type+".csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);

   FileWriteString(stats_file, ";;;All;;;Engulf;;;Small Shadow;;;Mid-Shadow;;;Big Shadow;;;Range < 1ATR;;;Range < 2ATR;;;Range > 2ATR;;;Swing Point;;\r\n");
   FileWriteString(stats_file, ";;;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN;HH/LL;HC/LC;UP/DN\r\n");
   
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
   
   FileClose(stats_file);
}

int OnInit()
{
//--- indicator buffers mapping
   
   ObjectsDeleteAll( 0);

   dotype("plain");
   dotype("real");
   dotype("two-bar");
   dotype("engulf");
   
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
