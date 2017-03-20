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
 * Detects a plain arrowe, any candle with an arrow on it
 */
int detectArrow( string symbol, int timeFrame, int shift = 1 ) {
      double buyArrow = iCustom(symbol,timeFrame,"GoldTradePro",false,0,shift);
      double sellArrow = iCustom(symbol,timeFrame,"GoldTradePro",false,1,shift);

     // Print( " TRADE: buyArrow = ", buyArrow, " ; sellArrow = ", sellArrow );

      if ( buyArrow != 2147483647 ) {
         return (TRADE_ARROW_BUY);
      }
      if ( sellArrow != 2147483647 ) {
         return (TRADE_ARROW_SELL);
      }
      return (TRADE_ARROW_NONE);
}

/**
 * Detects a "real" arrow trade, that is an arrow at a turning point, so the previous
 * bar must be one of the opposite type (kinda crude for now)
 */
int detectRealArrow( string symbol, int timeFrame, int shift = 1 )
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

// detect if the two bars prior to the given one in shift are the same
// i.e 2 bull or 2 bear bars
int detectTwoBar(string symbol,int timeframe, int shift = 1) {
   if ( isBullBar(symbol,timeframe,shift+1) && isBullBar(symbol,timeframe,shift+2) ) {
      return (TRADE_ARROW_BUY);
   } 
   if ( isBearBar(symbol,timeframe,shift+1) && isBearBar(symbol,timeframe,shift+2) ) {
      return (TRADE_ARROW_SELL);
   }  
   return (TRADE_ARROW_NONE);
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

// detect if the bar closed outside the bands
int detectBandsClose( string symbol, int timeframe, int shift ) {
   double bu = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,shift);
   double bl = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,shift);
   if ( iClose(Symbol(),PERIOD_D1,shift) < bl ) {
      return (TRADE_ARROW_SELL);
   }
   if ( iClose(Symbol(),PERIOD_D1,shift) > bu ) {
      return (TRADE_ARROW_BUY);
   } 
   return (TRADE_ARROW_NONE);
}

// detect if a bar opened below/above the bollinger bands (that is, the band on the previous close as the band for this bar is affected by its closing)
// the previous bar must have opened above and closed below its bands
// this bar must have opened at/below or at/above the previous bar (not gapped inside)
int detectBandsOpen( string symbol, int timeframe, int shift ) {
   double bu = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,shift+1);
   double bl = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,shift+1);
   if ( iOpen(Symbol(),PERIOD_D1,shift) < bl && iOpen(Symbol(),PERIOD_D1,shift) - (symbolPoints(Symbol())*4) <= iClose(Symbol(),PERIOD_D1,shift+1) ) {
      if ( iOpen(Symbol(),PERIOD_D1,shift+1) >= bl && iClose(Symbol(),PERIOD_D1,shift+1) <= bl ) {
         return (TRADE_ARROW_SELL);
      }
   }
   if ( iOpen(Symbol(),PERIOD_D1,shift) > bu && iOpen(Symbol(),PERIOD_D1,shift) + (symbolPoints(Symbol())*4) >= iClose(Symbol(),PERIOD_D1,shift+1) ) {
      if ( iOpen(Symbol(),PERIOD_D1,shift+1) <= bu && iClose(Symbol(),PERIOD_D1,shift+1) >= bu ) {
         return (TRADE_ARROW_BUY);
      }
   } 
   return (TRADE_ARROW_NONE);
}

// detect if a bar close inside the bands, true/false
bool detectBandsInsideClose( string symbol, int timeframe, int shift ) {
   double bu = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,shift);
   double bl = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,shift);
   return ( iClose(Symbol(),PERIOD_D1,shift) > bl && iClose(Symbol(),PERIOD_D1,shift) < bu );
}

// detect if the bar moved outside the bands, and by how much (0 == no excursion beyond bands, positive for upper band, negative for lower band)
double detectExceededBands( string symbol, int timeframe, int shift ) {
   double bu = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,shift);
   double bl = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,shift);
   if ( iLow(Symbol(),PERIOD_D1,shift) < bl ) {
      return (iLow(Symbol(),PERIOD_D1,shift) - bl);
   }
   if ( iHigh(Symbol(),PERIOD_D1,shift) > bu ) {
      return (iHigh(Symbol(),PERIOD_D1,shift) - bu);
   } 
   return (0);
}

int detectEngulf(string symbol, int timeframe, int shift = 1) {
   if ( isBullBar(symbol,timeframe,shift) ) {
      // bull engulf - must close higher that previous bar high and must also have taken out its low
      if ( iClose(symbol,timeframe,shift) >= iHigh(symbol,timeframe,shift+1) && iLow(symbol,timeframe,shift) <= iLow(symbol,timeframe,shift+1) ) {
         return (TRADE_ARROW_BUY);
      }
   } else if ( isBearBar(symbol,timeframe,shift) ) {
      // bear engulf, make close below low of prevoious bar and have taken out its high
      if ( iClose(symbol,timeframe,shift) <= iLow(symbol,timeframe,shift+1) && iHigh(symbol,timeframe,shift) >= iHigh(symbol,timeframe,shift+1) ) {
         return (TRADE_ARROW_SELL);
      }
   }
   return (TRADE_ARROW_NONE);
}

bool detectInsideBar(string symbol, int timeframe, int shift = 1) {
   return ( iHigh(symbol,timeframe,shift) <= iHigh(symbol,timeframe,shift+1) && 
            iLow(symbol,timeframe,shift) >= iLow(symbol,timeframe,shift+1) ); 
}

// detect if the bar at the given shift is a bar forming IDF,i.e. previous bar is inside day
// to be IDF it also cannot be a flushed inside day
bool isInsideBarFailure(string symbol, int timeframe, int shift = 1) {
   if ( detectInsideBar(symbol,timeframe,shift+1) && !detectInsideBarFlush(symbol,timeframe,shift+1) && !detectInsideBar(symbol,timeframe,shift) ) {
      if ( iClose(symbol,timeframe,shift) <= iHigh(symbol,timeframe,shift+1) &&
           iClose(symbol,timeframe,shift) >= iLow(symbol,timeframe,shift+1)
         ) {
         return (true);
      }
   }
   return (false);
}

// check if the IDF at the current shift gets completed, i.e. this bar is an idf bar, so the next bar
// will tag the high/low of the inside day before this one to be true
bool isIDFComplete(string symbol, int timeframe, int shift = 1) {
   
   // check if we tagged the high or low in the idf, then check the opposite on the next day for completion
   if ( iHigh(symbol,timeframe,shift+1) < iHigh(symbol,timeframe,shift) ) {
      return ( iLow(symbol,timeframe,shift-1) <= iLow(symbol,timeframe,shift+1) );
   } else {
      return ( iHigh(symbol,timeframe,shift-1) >= iHigh(symbol,timeframe,shift+1) );
   }
   
}

/// if this given day is an inside bar, detect if the next candle flushed it (took both high and low in a single bar)
bool detectInsideBarFlush(string symbol, int timeframe, int shift = 1) {
   // is thsi bar an inside bar?
   if ( detectInsideBar(symbol,timeframe,shift) ) { 
      // if so, check to see if it was flushed the next day (both high and low taken)
      return ( iHigh(symbol,timeframe,shift-1) > iHigh(symbol,timeframe,shift) && 
               iLow(symbol,timeframe,shift-1) < iLow(symbol,timeframe,shift) 
             );
   }
   return (false);
}

// is the given bar and inside day, and if so, does the next day have an outer close,
// i.e. it does not flush the bar but closes higher / lower than inside day 
int detectIBOutsideClose(string symbol, int timeframe, int shift = 1) {
   if ( detectInsideBar(symbol,timeframe,shift) && !detectInsideBar(symbol,timeframe,shift-1) && !detectInsideBarFlush(symbol,timeframe,shift) && !isInsideBarFailure(symbol,timeframe,shift-1) ) {
      return ( iClose(symbol,timeframe,shift-1) > iHigh(symbol,timeframe,shift) ? TRADE_ARROW_BUY : TRADE_ARROW_SELL );  
   } 
   return (TRADE_ARROW_NONE);
}

// detect if this bar is an insde day, and if so if the next day engulfed it, i.e. broke both extrems of ID and closed high/lower than ID high/low
int detectIBEngulf(string symbol, int timeframe, int shift = 1) {
   if ( detectInsideBar(symbol,timeframe,shift) ) {
      return detectEngulf(symbol,timeframe,shift-1);
   }
   return (TRADE_ARROW_NONE);
}

// work out how far the market rallied/dropped on the next bar if the given bar is an inside day
// and the next bar does not flush it or form IDF, value returned is number of pips above the inside
// day high or low
double getInsideDayBreakRange(string symbol, int timeframe, int shift = 1) {
   // is this an inside bar , not flushed and next day was not form IDF?
   if ( detectInsideBar(symbol,timeframe,shift) && !detectInsideBarFlush(symbol,timeframe,shift) && !isInsideBarFailure(symbol,timeframe,shift-1) ) { 
      if ( isBullBar(symbol,timeframe,shift-1) ) {
         // range on bull bar is number of pips the market traveled after breakout of IB high
         return ( iHigh(symbol,timeframe,shift-1) - iHigh(symbol,timeframe,shift) );
      } else {
         // range on bear bar is number of pips the market traveled after breakout of IB low
         return ( iLow(symbol,timeframe,shift) - iLow(symbol,timeframe,shift-1) );
      }
   }
   return (0);
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
 
 
 
double symbolPoints(string symbol) {
   if ( symbol == "GOLD" ) { return (0.1); }
   if ( symbol == "GOLDgr" ) { return (0.001); }
   if ( symbol == "SILVER" ) { return (0.01); }
   if ( StringSubstr(symbol,0,3) == "#CL" ||       // old oil
        StringSubstr(symbol,0,3) == "#LC" ||       // old brent
        StringSubstr(symbol,0,7) == "#US_Oil" ||   // new oil
        StringSubstr(symbol,0,7) == "#UK_Oil" ||   // new brent
        symbol == "WTI" ||                         // spot oil
        symbol == "EURBUND" ||                     // Window BUND CFD
        StringFind(symbol,"JPY") != -1 ) 
   {
      return (0.01);
   } 
   if ( StringSubstr(symbol,0,3) == "#EP" ||       // old S&P
        StringSubstr(symbol,0,3) == "#EN" ||       // old nasdaq
        StringSubstr(symbol,0,7) == "#S&P500" ||   // new s&p
        StringSubstr(symbol,0,7) == "#NAS100")     // new nasdaq
   {
      return (0.25);
   }
   if ( StringSubstr(symbol,0,3) == "#FD" ||       // old DAX contract
        StringSubstr(symbol,0,3) == "#FF" ||       // old FTSI contract
        StringSubstr(symbol,0,6) == "#GER30" ||    // new FTSI contract
        StringSubstr(symbol,0,6) == "#UK100" ||    // new FTSI contract
        StringSubstr(symbol,0,6) == "#FRA40"
      ) 
   {
      return (0.5);
   }
   if ( StringSubstr(symbol,0,6) == "#EUR50" ||
        symbol == "EU50" ||                       // windsor EURO STOXX
        StringSubstr(symbol,0,5) == "#DJ30" ||
        symbol == "US30" ||                       // window dow
        StringSubstr(symbol,0,6) == "#SWI20" ||
        StringSubstr(symbol,0,6) == "#Cocoa" ||
        StringSubstr(symbol,0,10) == "#Germany50" 
   ) {
      return 1;
   }
    if ( StringSubstr(symbol,0,4) == "#JPN" ) {
      return 5;
   }
   if ( StringSubstr(symbol,0,7) == "#Coffee" ) {
      return 0.05;
   }
   if ( StringSubstr(symbol,0,3) == "#CN" || 
        StringSubstr(symbol,0,3) == "#SN" ||
        StringSubstr(symbol,0,5) == "#Corn" ||
        StringSubstr(symbol,0,5) == "#Soyb" ||
        StringSubstr(symbol,0,6) == "#Wheat"
      ) {
      return 0.25;
   }

   if ( StringSubstr(symbol,0,4) == "#US$" ) {
      return 0.005;
   }
   if ( StringSubstr(symbol,0,7) == "#NatGas" ) {
      return 0.001;
   }
   if ( StringSubstr(symbol,0,6)  == "#China" ||
        StringSubstr(symbol,0,10) == "#GerTech30" ||
        StringSubstr(symbol,0,11) == "#Portugal20" ||
        StringSubstr(symbol,0,9)  == "#Sweden30"
      ) {
      return 0.10;
   }
   if ( StringSubstr(symbol,0,1) == "#" ) {        // all other futures, mostly for stock CFDs
     return (0.01);
   }
   if ( MathAbs(Bid-Ask) > 0.0050 ) {
      return (0.001);
   }
   return (0.0001);
}

bool isFutures(string symbol = NULL) {
   if ( symbol == NULL ) {
      symbol = Symbol();
   }
   
   if ( StringSubstr(symbol,0,1) == "#" ) {        // all other futures, mostly for stock CFDs
     return (true);
   } else {
      return false;
   } 
}
