//+------------------------------------------------------------------+
//|                                                    functions.mqh |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property strict

#ifndef TRADE_ARROW_NONE
#define TRADE_ARROW_NONE -1
#define TRADE_ARROW_SELL OP_SELL
#define TRADE_ARROW_BUY OP_BUY
#endif

int detectTrend( string symbol, int timeframe ) {
   double ema21 = iMA(symbol,timeframe,21,0,MODE_EMA,PRICE_CLOSE,0);
   double ema50 = iMA(symbol,timeframe,50,0,MODE_EMA,PRICE_CLOSE,0);
  
   // to be a trend the open price of the bar must be on the same side of 50 ema as the 21 ema
   if ( ema21 > ema50 && Bid > ema50 ) {
      return (TRADE_ARROW_BUY);
   } else if ( ema21 < ema50 && Bid < ema50 ) {
      return (TRADE_ARROW_SELL);
   }
   
   return (TRADE_ARROW_NONE);

}

int detect50( string symbol, int timeframe ) {
   double ema50 = iMA(symbol,timeframe,50,0,MODE_EMA,PRICE_CLOSE,0);
  
   // to be a trend the open price of the bar must be on the same side of 50 ema as the 21 ema
   if ( Bid  > ema50 ) {
      return (TRADE_ARROW_BUY);
   } else if ( Bid  < ema50 ) {
      return (TRADE_ARROW_SELL);
   }
   
   return (TRADE_ARROW_NONE);

}

/**
 * Detects a "real" arrow trade, that is an arrow at a turning point, so the previous
 * bar must be one of the opposite type (kinda crude for now)
 */
int detectArrow( string symbol, int timeFrame, int shift = 1 )
{
      double buyArrow = iCustom(symbol,timeFrame,"GoldTradePro",false,0,shift);
      double sellArrow = iCustom(symbol,timeFrame,"GoldTradePro",false,1,shift);

     // Print( " TRADE: buyArrow = ", buyArrow, " ; sellArrow = ", sellArrow );

      if ( buyArrow != 2147483647 ) {
         if ( isBullBar(symbol,timeFrame,shift) && isBearBar(symbol,timeFrame,shift+1) ) {
            return (TRADE_ARROW_BUY);
         }
      }
      if ( sellArrow != 2147483647 ) {
         if ( isBearBar(symbol,timeFrame,shift) && isBullBar(symbol,timeFrame,shift+1) ) {
            return (TRADE_ARROW_SELL);
         }
      }
      return (TRADE_ARROW_NONE);
}

/**
 * This is a raw detection of a trade arrow, just the arrow iself
 */
int barHasArrow( string symbol, int timeFrame, int shift = 1 )
{
      double buyArrow = iCustom(symbol,timeFrame,"GoldTradePro",false,0,shift);
      double sellArrow = iCustom(symbol,timeFrame,"GoldTradePro",false,1,shift);

      if ( buyArrow != 2147483647 ) {
         return (TRADE_ARROW_BUY);
      }
      if ( sellArrow != 2147483647 ) {
         return (TRADE_ARROW_SELL);
      }
      return (TRADE_ARROW_NONE);
}

int detectMACD(string symbol, int timeframe)
{
   double macdUp = iCustom(symbol,timeframe,"MACDColoredv102decimal",0,1);
   double macdDn = iCustom(symbol,timeframe,"MACDColoredv102decimal",1,1);

   double macdUpLast = iCustom(symbol,timeframe,"MACDColoredv102decimal",0,2);
   double macdDnLast = iCustom(symbol,timeframe,"MACDColoredv102decimal",1,2);
   //Print(symbol," ",timeframe," UP: ",macdUp," ",macdUpLast," DN: ",macdDn," ",macdDnLast);
   if ( macdUp != 0 && macdDnLast != 0 ) { 
      return (OP_BUY); 
   } else if ( macdDn != 0 && macdUpLast != 0  ) { 
      return (OP_SELL); 
   } else {
      return (TRADE_ARROW_NONE);
   }
}

int detectPin(string symbol, int timeframe) {
   double high = iHigh(symbol,timeframe,1);
   double low = iLow(symbol,timeframe,1);
   double range = high-low;
   double upper_part = range * 0.2;  // must close in top 10% of range 
   double lower_part = range * 0.4; // must open in top 40% of rage
   
   double upper = MathMax(iOpen(symbol,timeframe,1),iClose(symbol,timeframe,1));
   double lower = MathMin(iOpen(symbol,timeframe,1),iClose(symbol,timeframe,1)); 
   double middle = iHigh(symbol,timeframe,1)-(range*0.5);
   
   // buy single, open/close in top half
   if ( upper > high - upper_part && lower > high - lower_part ) {
       // previous bar must be bearish; low point of the tail must be lower than low of previous bar
      if ( isBearBar(symbol,timeframe,2) && low <= iLow(symbol,timeframe,2) ) {
         return (TRADE_ARROW_BUY);
      }
   } else if ( lower < low + upper_part && upper < low + lower_part ) {
      // previous bar must be bullish; high point of the tail must be higher than highest high of previous bar
      if ( isBullBar(symbol,timeframe,2) && high >= iHigh(symbol,timeframe,2) ) {
         return (TRADE_ARROW_SELL);
      }
   }
   return (TRADE_ARROW_NONE);   
}

int detectEngulf(string symbol, int timeframe) {
   if ( isBullBar(symbol,timeframe,1) && isBearBar(symbol,timeframe,2) ) {
      if ( iClose(symbol,timeframe,1) >= iOpen(symbol,timeframe,2) ) {
         return (TRADE_ARROW_BUY);
      }
   } else if ( isBearBar(symbol,timeframe,1) && isBullBar(symbol,timeframe,2)  ) {
      if ( iClose(symbol,timeframe,1) <= iOpen(symbol,timeframe,2) ) {
         return (TRADE_ARROW_SELL);
      }
   }
   return (TRADE_ARROW_NONE);
}

bool isBullBar(string symbol, int timeframe, int shift) {
   if ( iClose(symbol,timeframe,shift) > iOpen(symbol,timeframe,shift) ) {
      return (true);
   } else {
      return (false);
   }
}

bool isBearBar(string symbol, int timeframe, int shift) {
   if ( iClose(symbol,timeframe,shift) < iOpen(symbol,timeframe,shift) ) {
      return (true);
   } else {
      return (false);
   }
}

double findRecentHigh(string symbol = NULL, int timeframe = 0, int shift = 0) {
   double high = iHigh(symbol,timeframe,shift);
   for ( int i = shift+1; i < 10; i++ ) {
      double p = iHigh(symbol,timeframe,i);
      if ( p < high ) {
         break;
      } else {
         high = p;
      }
   }
   return high;
}

double findRecentLow(string symbol = NULL, int timeframe = 0, int shift = 0) {
   double low = iLow(symbol,timeframe,shift);
   for ( int i = shift+1; i < 10; i++ ) {
      double p = iLow(symbol,timeframe,i);
      if ( p > low ) {
         break;
      } else {
         low = p;
      }
   }
   return low;
}

/**
 * Determine if the most recent bar that closed cross the given line
 * Note this works only on the current active chart as the line
 * must be an object on the chart
 */
 bool crossedTrendline(string lineName, int timeframe, int shift = 1) {
   // get the price of the line at the last bar
   double price;
   if ( ObjectType(lineName) == OBJ_HLINE ) {
      price = ObjectGet(lineName, OBJPROP_PRICE1);
   } else {
      price = ObjectGetValueByShift(lineName,1);
   }
   double open = iOpen(Symbol(),timeframe,shift);
   double close = iClose(Symbol(),timeframe,shift);
   // is that price between the open and close of the last bar?
   return ( (open > price && close < price) || (close > price && open < price) );
 }
 
 /**
  * Determine if the bar cross the moving average
  */
 bool detectMaCross(string symbol, int timeframe, int ma_period, int ma_method = MODE_SMA, int shift = 1) {
   double price = iMA(symbol,timeframe,ma_period,0,ma_method,PRICE_CLOSE,shift);
   double open = iOpen(symbol,timeframe,shift);
   double close = iClose(symbol,timeframe,shift);
   return ( (open > price && close < price) || (open < price && close > price) );
 }
 
 /**
  * Detects if given bar opened and closed above or below the MA, and is the opposite of the previous
  * bar, i.e is this is a bull bar the bar before it must be a bear bar
  */
 int detectBarToMA(string symbol, int timeframe, int ma_period, int ma_method = MODE_SMA, int shift = 1) {
   double price = iMA(symbol,timeframe,ma_period,0,ma_method,PRICE_CLOSE,shift);
   double open = iOpen(symbol,timeframe,shift);
   double close = iClose(symbol,timeframe,shift);
   if ( open > price && close > price && isBearBar(symbol,timeframe,shift-1) ) {
      return (TRADE_ARROW_BUY);
   } else if ( open < price && close < price && isBullBar(symbol,timeframe,shift-1) ) {
      return (TRADE_ARROW_SELL);
   }
   return (TRADE_ARROW_NONE);
 }