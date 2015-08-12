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
#define TRADE_TYPE_ALL -1
           
int period(string p) {
   if ( p == "MN" ) { return (PERIOD_MN1); }
   if ( p == "W1" ) { return (PERIOD_W1); }
   if ( p == "D1" ) { return (PERIOD_D1); }
   if ( p == "H4" ) { return (PERIOD_H4); }
   if ( p == "H1" ) { return (PERIOD_H1); }
   if ( p == "M15" ) { return (PERIOD_M15); }
   return (PERIOD_H1);
}

double symbolPoints(string symbol) {
   if ( symbol == "GOLD" ) { return (0.1); }
   if ( symbol == "GOLDgr" ) { return (0.001); }
   if ( symbol == "SILVER" ) { return (0.01); }
   if ( StringSubstr(symbol,0,3) == "#CL" ||       // old oil
        StringSubstr(symbol,0,3) == "#LC" ||       // old brent
        StringSubstr(symbol,0,7) == "#US_Oil" ||   // new oil
        StringSubstr(symbol,0,7) == "#UK_Oil" ||   // new brent
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
        StringSubstr(symbol,0,5) == "#DJ30" ||
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

double getTradeValue(double points, double lots) {
   return (lots*10) * points * tickValue();
}

double tickValue( string symbol = "") {
   if ( symbol == "" ) { symbol = Symbol(); }
   double tickvalue = MarketInfo(Symbol(),MODE_TICKVALUE);
   // EURAUD , AUDJPY , CADJPY etc show tick value as if trading 1.0 lots, others as if 0.1
   // so convert them as we want to determine the price as it its "$1 per tick"
   if ( tickvalue > 2  || isFutures() ) {        
      tickvalue = tickvalue / 10;      
   }
   return tickvalue;   
}

void goBreakEven(string symbol) {
   // if there are no open trades on this pair, check for a buy/sell line
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderSymbol() == symbol ) {
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),OrderExpiration());
      }  
   }
}

/**
 * Get the minimum stoploss allowed, by default this is 8 * [spread]
 * @note Maybe make this configurable at a later stage
 */
double minimumStop() {
   return 8 * (Ask - Bid);
}

void printPairData() {
   Print("Symbol=",Symbol());
   Print("Low day price=",MarketInfo(Symbol(),MODE_LOW));
   Print("High day price=",MarketInfo(Symbol(),MODE_HIGH));
   Print("The last incoming tick time=",(MarketInfo(Symbol(),MODE_TIME)));
   Print("Last incoming bid price=",MarketInfo(Symbol(),MODE_BID));
   Print("Last incoming ask price=",MarketInfo(Symbol(),MODE_ASK));
   Print("Point size in the quote currency=",MarketInfo(Symbol(),MODE_POINT));
   Print("Digits after decimal point=",MarketInfo(Symbol(),MODE_DIGITS));
   Print("Spread value in points=",MarketInfo(Symbol(),MODE_SPREAD));
   Print("Stop level in points=",MarketInfo(Symbol(),MODE_STOPLEVEL));
   Print("Lot size in the base currency=",MarketInfo(Symbol(),MODE_LOTSIZE));
   Print("Tick value in the deposit currency=",MarketInfo(Symbol(),MODE_TICKVALUE));
   Print("Tick size in points=",MarketInfo(Symbol(),MODE_TICKSIZE)); 
   Print("Swap of the buy order=",MarketInfo(Symbol(),MODE_SWAPLONG));
   Print("Swap of the sell order=",MarketInfo(Symbol(),MODE_SWAPSHORT));
   Print("Market starting date (for futures)=",MarketInfo(Symbol(),MODE_STARTING));
   Print("Market expiration date (for futures)=",MarketInfo(Symbol(),MODE_EXPIRATION));
   Print("Trade is allowed for the symbol=",MarketInfo(Symbol(),MODE_TRADEALLOWED));
   Print("Minimum permitted amount of a lot=",MarketInfo(Symbol(),MODE_MINLOT));
   Print("Step for changing lots=",MarketInfo(Symbol(),MODE_LOTSTEP));
   Print("Maximum permitted amount of a lot=",MarketInfo(Symbol(),MODE_MAXLOT));
   Print("Swap calculation method=",MarketInfo(Symbol(),MODE_SWAPTYPE));
   Print("Profit calculation mode=",MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   Print("Margin calculation mode=",MarketInfo(Symbol(),MODE_MARGINCALCMODE));
   Print("Initial margin requirements for 1 lot=",MarketInfo(Symbol(),MODE_MARGININIT));
   Print("Margin to maintain open orders calculated for 1 lot=",MarketInfo(Symbol(),MODE_MARGINMAINTENANCE));
   Print("Hedged margin calculated for 1 lot=",MarketInfo(Symbol(),MODE_MARGINHEDGED));
   Print("Free margin required to open 1 lot for buying=",MarketInfo(Symbol(),MODE_MARGINREQUIRED));
   Print("Order freeze level in points=",MarketInfo(Symbol(),MODE_FREEZELEVEL)); 
  }
