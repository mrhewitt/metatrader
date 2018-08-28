//+------------------------------------------------------------------+
//|                                                      T3xDEMA.mq4 |
//|                                      Copyright 2018, Mark Hewitt |
//|                                     https://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Mark Hewitt"
#property link      "https://www.markhewitt.co.za"
#property version   "1.00"
#property strict

extern double Lots = 0.01;
extern int Magic = 12345;

datetime previousBar ;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   previousBar = iTime(Symbol(),Period(),0);
   
   if ( !IsTradeAllowed() ) {
      Alert("Trading is not Allowed");
      return(INIT_FAILED);
   }     
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
   
   if ( OrdersTotal() > 0 ) {
      double dema = DEMA();
      
      // check each order, close orders that have reached target (dema)
      for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
      {
         if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
         if ( OrderMagicNumber() == Magic ) {
            if ( OrderType() == OP_BUY && Bid <= dema ) {
               OrderClose(OrderTicket(),OrderLots(),Bid,0);
            } else if ( OrderType() == OP_SELL && Bid >= dema ) {
               OrderClose(OrderTicket(),OrderLots(),Ask,0);
            }   
         }
      }
    }
          
    if ( newBar(previousBar,Symbol(),Period()) ) {
        // bear bar? then check if bar closed above t3 envelope
        if ( Close[1] == Low[1] ) {
           double upper = iCustom(Symbol(),Period(),"T3MA Dynamic Envelope",30,0.4,100,4,1,1);  
           // if closed above the envelope trade short to the dema
           if ( Close[1] >= upper ) {
             sell();
           }
        } else {
          // if bull candle then check if its below then envelopte
           double lower = iCustom(Symbol(),Period(),"T3MA Dynamic Envelope",30,0.4,100,4,2,1);  
           if ( Close[1] <= lower ) {
             buy();
           } 
        }  
    }
  }
//+------------------------------------------------------------------+

void buy() {
   while(IsTradeContextBusy()) Sleep(50);
   RefreshRates();
  OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0);
}

void sell() {
   while(IsTradeContextBusy()) Sleep(50);
   RefreshRates();
   OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0); 
}

int DEMA() {
   return iCustom(Symbol(),Period(),"DEMA",40,0,0);
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