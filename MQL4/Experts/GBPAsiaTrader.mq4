//+------------------------------------------------------------------+
//|                                             GBPAsiaTrader.mq4 |
//|                                      Copyright 2019, Mark Hewitt |
//|                                     https://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Mark Hewitt"
#property link      "https://www.markhewitt.co.za"
#property version   "1.00"
#property strict

//--- input parameters
input double   Lots=0.01;
input int      BarsHold=3;
input bool     Invert=false;
input int      Magic = 20190415;
input string   Comment = "GBPASIA-EA";
input double   SL = 0.0020;

datetime previousBar ;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   previousBar = iTime(Symbol(),Period(),0);
   
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      // we only make a new trading decision once a new bar opens
      if ( newBar(previousBar,Symbol(),Period()) ) {
           
          datetime today = iTime(Symbol(),PERIOD_M5,0);
          // Monday - place trade at market open
          // Tuesday - Friday trade after first 5 minutes
     /*     if ( (TimeDayOfWeek(today) == 1 && TimeHour(today) == 0 && TimeMinute(today) == 5) ||       // monday - place trade on open
               (TimeDayOfWeek(today) != 5 && TimeHour(today) == 23 && TimeMinute(today) == 55)      // mon - thurs - place trade 5 min before NY close for next "days" asia session                  
               ) {  
               */
          if ( TimeHour(today) == 0 && TimeMinute(today) == 5 ) {  
         //  if ( Hour() == 0 ) {
            buy();   
         } else if ( Hour() == 0 + BarsHold ) {
            flatten();
         }
      }
  }
//+------------------------------------------------------------------+

void buy() {
   while(IsTradeContextBusy()) Sleep(50);
   RefreshRates();
   
   if ( !Invert ) {
      // normal sell as per original system rules
      OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, ( SL == 0 ? 0 : Bid - SL ), 0/*Bid - (TPPips/10)*/, Comment, Magic);
   } else {
      // we are fading the strategy, so go long when strategy says go short, with TP where stratgy stop was and SL when target was
      OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0, "", Magic);
   }
}


void sell() {
   while(IsTradeContextBusy()) Sleep(50);
   RefreshRates();
   
   if ( !Invert ) {
      // normal sell as per original system rules
      OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0/*Bid - (TPPips/10)*/, Comment, Magic);
   } else {
      // we are fading the strategy, so go long when strategy says go short, with TP where stratgy stop was and SL when target was
      OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0, "", Magic);
   }
}

void flatten( int onlyTradesOf = -1, bool wholePosition = true ) {

   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && (onlyTradesOf == -1 || OrderType() == onlyTradesOf) ) {
         OrderClose(OrderTicket(),OrderLots(),(OrderType() == OP_BUY ? Bid : Ask),0);
         if ( !wholePosition ) { break; }
      }
   }
   
}

/**
 * Returns true if there are active positions placed by this EA on this symbol, false otherwise
 */
bool isFlat() {
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--) {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;      
      if ( OrderMagicNumber() == Magic && OrderSymbol() == Symbol() ) {
         return (false);     // found an active position in our EA
      }
   }
   
   return (true);   // no open orders for our EA
}


// This function returns the value true if the current bar/candle was just formed
bool newBar(datetime& pBar,string symbol,int timeframe)
{
   if ( pBar < iTime(symbol,timeframe,0) )
   {
      pBar = iTime(symbol,timeframe,0);
      return(true);
   }
   else
   {
      return(false);
   }
}