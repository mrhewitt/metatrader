//+------------------------------------------------------------------+
//|                                                    PSARCross.mq4 |
//|                                    Copyright © 2015, Mark Hewitt |
//|                                      http://www.markhewitt.co.za |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Mark Hewitt"
#property link      "http://www.markhewitt.co.za"

#include "../Include/detectXXX.mqh"
#include "../Include/TradeFunctions.mqh"
#include "../Include/stdlib.mqh"

#define PSAR_UNDER 1
#define PSAR_ABOVE 2

bool initVariables = true;
bool hasNewBar = false;
datetime previousBar ;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   return 0;
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   if ( initVariables ) {
    initVariables = false;
    previousBar = iTime(Symbol(),Period(),0);
   }
   
   if ( newBar(previousBar,Symbol(),Period()) ) {
      double tenkansen = iIchimoku( Symbol(), 
                                    Period(),      // timeframe
                                    9,             // period of Tenkan-sen line
                                    26,            // period of Kijun-sen line
                                    52,            // period of Senkou Span B line
                                    MODE_TENKANSEN,// line index
                                    1              // shift
                                 );
      double kijunsen  = iIchimoku( Symbol(), 
                                    Period(),      // timeframe
                                    9,             // period of Tenkan-sen line
                                    26,            // period of Kijun-sen line
                                    52,            // period of Senkou Span B line
                                    MODE_KIJUNSEN,// line index
                                    1              // shift
                                 );
      
      double thisPSAR = iCustom(Symbol(),Period(),"Parabolic",0,1);
      double thisClose = iClose(Symbol(),Period(),1);
      double thisOpen = iOpen(Symbol(),Period(),1);
      double prevPSAR = iCustom(Symbol(),Period(),"Parabolic",0,2);
      double prevClose = iClose(Symbol(),Period(),2);
       
      // check to see if the psar has changed sides, and if so that the price is on the correct
      // side of the tenkensan/kijunsen, if these conditions are met sound an alarm
      int side = psarSide(thisPSAR,thisClose);
      if ( side != psarSide(prevPSAR,prevClose) ) {
         if ( side == PSAR_ABOVE &&          // psar above so we are trying to sell
              thisClose < tenkansen && thisClose < kijunsen &&   // bar must close below all ichimoku lines
              (thisOpen > tenkansen || thisOpen > kijunsen)    // bar must have opened above one of the lines, so it has crossed this bar
            ) {
            Print("SELL");    
         } else if ( side == PSAR_UNDER &&          // psar above so we are trying to sell
              thisClose > tenkansen && thisClose > kijunsen &&   // bar must close above buy all ichimoku lines
              (thisOpen < tenkansen || thisOpen < kijunsen)    // bar must have opened below one of the lines, so it has crossed this bar
            ) {
            Print("BUY");
         }
      }
         
   } 
   return 0;
}

/**
 * Returns if the psar is above or below the bar
 */
int psarSide( double psar, double close ) {
   if ( psar < close ) {
      return PSAR_UNDER;
   } else {
      return PSAR_ABOVE;
   }
   return 0;
}

// This function return the value true if the current bar/candle was just formed
// Inspired by: simplefx2.mq4, http://www.GetForexSoftware.com
bool newBar(datetime& previousBar,string symbol,int timeframe)
{
   if ( previousBar < iTime(symbol,timeframe,0) )
   {
      previousBar = iTime(symbol,timeframe,0);
      return(true);
   }
   else
   {
      return(false);
   }
}
