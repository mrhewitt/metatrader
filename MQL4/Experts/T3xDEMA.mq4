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
extern int Magic2 = 54321;
extern bool T3xDEMA = false;
extern bool T3xT3 = true;

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
   double nearestOrder = 0;
   if ( OrdersTotal() > 0 ) {
      double dema = DEMA();
     // Print(StringToDouble(dema));
      // check each order, close orders that have reached target (dema)
      for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
      {
         if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
         
         if ( (OrderMagicNumber() == Magic) || (OrderMagicNumber() == Magic2) ) {
            if ( OrderType() == OP_BUY ) {
               nearestOrder = MathMin(nearestOrder,OrderOpenPrice());
            } else {
               nearestOrder = ( nearestOrder == 0 ? OrderOpenPrice() : MathMax(nearestOrder,OrderOpenPrice()) );
            }
         }
         
         if ( OrderMagicNumber() == Magic ) {
       //  Print(DoubleToStr(Bid)," >= ", DoubleToStr(dema));
            if ( OrderType() == OP_BUY ) {
      //         nearestOrder = MathMin(nearestOrder,OrderOpenPrice());
               if ( Bid >= dema ) { OrderClose(OrderTicket(),OrderLots(),Bid,0); }
            } else if ( OrderType() == OP_SELL ) {
              // nearestOrder = ( nearestOrder == 0 ? OrderOpenPrice() : MathMin(nearestOrder,OrderOpenPrice()) );
               if ( Bid <= dema ) { OrderClose(OrderTicket(),OrderLots(),Ask,0); }
            }   
         } else if ( OrderMagicNumber() == Magic2 ) {
            if ( OrderType() == OP_BUY ) {
               double upper = iCustom(Symbol(),Period(),"T3MA Dynamic Envelope",30,0.4,100,4,2,1);
               if ( Bid >= upper ) { OrderClose(OrderTicket(),OrderLots(),Bid,0); }
            } else if ( OrderType() == OP_SELL ) { 
               double lower = iCustom(Symbol(),Period(),"T3MA Dynamic Envelope",30,0.4,100,4,1,1); 
               if ( Bid <= lower ) { OrderClose(OrderTicket(),OrderLots(),Ask,0); }
            }
         }
      }
    }
 
    if ( newBar(previousBar,Symbol(),Period()) ) {
        // bear bar? then check if bar closed above t3 envelope
        if ( Close[1] == Low[1] && Close[2] == High[2]) {
           if ( nearestOrder > 0 && Open[0] < nearestOrder + 0.0005 ) {
              Print("Open ", DoubleToStr(Open[0]), " too close to order at ", DoubleToStr(nearestOrder), " by ", DoubleToStr(nearestOrder + 0.0005));
           } else {
              double upper = iCustom(Symbol(),Period(),"T3MA Dynamic Envelope",30,0.4,100,4,2,1); 
              // Print( "T3 U:", DoubleToStr(upper) ); 
           // if closed above the envelope trade short to the dema
              if ( Close[1] >= upper ) {
                 sell();
              }
           }   
        } else if ( Close[1] == High[1] && Close[2] == Low[2] ) {
          // if bull candle then check if its below then envelopte
           if ( nearestOrder > 0 && Open[0] > nearestOrder - 0.0005 ) {
              Print("Open ", DoubleToStr(Open[0]), " too close to order at ", DoubleToStr(nearestOrder), " by ", DoubleToStr(nearestOrder - 0.0005));
           } else {
               double lower = iCustom(Symbol(),Period(),"T3MA Dynamic Envelope",30,0.4,100,4,1,1);  
               if ( Close[1] <= lower ) {
                  buy();
               }
           }     
        }  
    }
  }
//+------------------------------------------------------------------+

void buy() {
   while(IsTradeContextBusy()) Sleep(50);
   RefreshRates();
  if ( T3xDEMA ) { OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0,"T3xDEMA",Magic); }
  if ( T3xT3 ) { OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0,"T3xT3",Magic2); }
}

void sell() {
   while(IsTradeContextBusy()) Sleep(50);
   RefreshRates();
   if ( T3xDEMA ) { OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0,"T3xDEMA",Magic); }
   if ( T3xT3 ) { OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0,"T3xT3",Magic2);  }
}

double DEMA() {
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