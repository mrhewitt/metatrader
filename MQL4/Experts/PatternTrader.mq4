//+------------------------------------------------------------------+
//|                                                PatternTrader.mq4 |
//|                                      Copyright 2018, Mark Hewitt |
//|                                     https://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Mark Hewitt"
#property link      "https://www.markhewitt.co.za"
#property version   "1.00"
#property strict
//--- input parameters
input double   Lots=0.01;
datetime previousBar ;
int   barsSinceEntry = 0;          

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   previousBar = iTime(Symbol(),Period(),0);
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
   if ( newBar(previousBar,Symbol(),Period()) ) {
      if ( openOrder() ) {
         barsSinceEntry++;
         fourBarTrail();
      } else {
      
         int tradeType = barType(1); 
         int dema = DEMA();
         
         if ( tradeType == dema && MathAbs(High[1] - Low[1]) < 0.00035 ) {

            /// SMALL PULLBACK
         
          Print("Evaluating SP");
            int count = 0;
            while ( barType(count+2,(count < 2)) != tradeType && barType(count+2,(count < 2)) != -1 ) { count++; }
            //Print ("Bar count ", count);
            if ( count >= 2 && ( (tradeType == OP_BUY && highestHigh(count+1,5)) || (tradeType == OP_SELL && lowestLow(count+1,5)) ) ){
               double dSlope = slope(count+1);
               Print("DEMA Slope == ", dSlope);
               // DEMA must be sloping our way, the base must be clean and not a 4 bar range and the T3 must have turned on at least one bar
               if ( dSlope > 0.0001 && !isRange(count+1) && T3(2) == inverse(tradeType) ) {
                  placeOrder(tradeType);
                  return;
               }
            } 
            
            // 4 bar trend pattern T1
         
            // is the t3 going in our direction, and is the market in a range for the last few bars
            Print("Evaluating T1");
            if ( T3(1) == tradeType && isRange(1) ) {
               Print("T1 on T3 and range");
               // check to see at least one of the bars in the range is full the opposite way
               for ( int i = 1; i <= 4; i++ ) {
                  Print("Bar ", i, " is ", T3(i), " against ", inverse(tradeType));
                  if ( T3(i) == inverse(tradeType) ) {
                     Print("Pullback found on bar ", i);
                     placeOrder(tradeType);
                  }
               }
            }
         
         }
         
         
         
       }
    }
  }
//+------------------------------------------------------------------+

/**
 * Returns true if there is an open order, and select its
 */
bool openOrder() {
   if ( OrdersTotal() > 0 ) {
      OrderSelect(0, SELECT_BY_POS);
      return true;
   }
   return false;
}

/**
 * Actually places and entry into the market
 */
void placeOrder(int tradeType) {
   if ( tradeType == OP_BUY ) {
      Print("Long at ", Ask);
      ArrowBuyCreate("buy" + DoubleToString(Ask), Time[0], Low[1] - 0.0002);
     // OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, iLow(Symbol(),Period(),1) - 0.0001, Ask + 0.0012, "PTSP");  
      barsSinceEntry = 0;          
   } else {
      //OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, iHigh(Symbol(),Period(),1) + 0.0001, Bid - 0.0012, "PTSP"); 
      Print("Short at ", Bid);
      ArrowSellCreate("sell" + DoubleToString(Bid), Time[0], High[1] + 0.0002);
      barsSinceEntry = 0;          
   }                  
}

int highestHigh(int shift, int bars) {
   for ( int i = shift; i < bars+shift; i++ ) {
      if ( High[shift] < High[i] ) { Print("Highest high : ", Time[shift], "(", shift, ") not highest"); return false; }
   }
   Print("Highest high : ", Time[shift], "(", shift, ") is highest");
   return true;
}

int lowestLow(int shift, int bars) {
   for ( int i = shift; i < bars+shift; i++ ) {
      if ( Low[shift] > Low[i] ) { Print("Lowest low : ", Time[shift], "(", shift, ") not lowest"); return false; }
   }
   Print("Lowest low : ", Time[shift], "(", shift, ") is lowest"); 
   return true;
}

int T3(int shift) {
   double t3ma = iCustom(Symbol(),Period(),"T3 MA Colour",4,0.4,0,shift);
   double value2 = iCustom(Symbol(),Period(),"T3 MA Colour",4,0.4,1,shift);
   double value4 = iCustom(Symbol(),Period(),"T3 MA Colour",4,0.4,3,shift); 
   Print("T3MA : ", t3ma, ", value2: ", value2, ", value4: " , value4);
   if ( value2 == value4 ) {
      return -1;
   } else if ( value2 == t3ma ) {
      return OP_SELL;
   } else if ( value4 == t3ma ) {
      return OP_BUY;
   }
   
   return "T3MA invalid options error";
   return -1;
}

/**
 * Returns the inverse trade type from the one given, if no trade type (-1) returns the same back (-1)
 */
bool inverse( int tradeType ) {
   return ( tradeType == -1 ? -1 : (tradeType == OP_BUY ? OP_SELL : OP_BUY) );
}

int DEMA() {
   Print( "DEMA @ " , iCustom(Symbol(),Period(),"DEMA",40,0,1), " against bar close ", Close[1], ": ", ( iCustom(Symbol(),Period(),"DEMA",0,1) < Close[1] ? OP_BUY : OP_SELL ) );
   return ( iCustom(Symbol(),Period(),"DEMA",40,0,1) < Close[1] ? OP_BUY : OP_SELL );
}

int barType(int shift, bool ignorePins = true) {
   if ( Close[shift] < Open[shift] || (!ignorePins && (Close[shift] == Open[shift]) && (Close[shift] == Low[shift])) ) {
     return (OP_SELL);
   } else if ( Close[shift] > Open[shift] || (!ignorePins && (Close[shift] == Open[shift]) && (Close[shift] == High[shift])) ) {
      return (OP_BUY);
   }
   return (-1);
}

double slope(int shift) {
   return MathAbs(iCustom(Symbol(),Period(),"DEMA",40,0,0) - iCustom(Symbol(),Period(),"DEMA",40,0,shift));
}

double isRange(int shift) {

   // look back 4 bars, market is rangeing if those bars all printed within a 6 pip range
   double max = 0;
   double min = 9999;
   for ( int i = shift; i <= shift + 3; i++ ) {
      max = MathMax(High[i],max);
      min = MathMin(Low[i],min);
   }
   double range = max - min;
   Print("Bar range: " , range);
   return ( range <= 0.0006 );
}

/**
 * if we have gone more than 4 bars since open, close if we go into negative, and if not trail the stop loss
 * at the low/high of last 3 bars in fact (called 4 bar trail cos of loss rull and when it kicks in)
 */
void fourBarTrail() {

   // only start managing after 4 brs have passed, and only manage auto trades
   if ( barsSinceEntry >= 4 && OrderComment() != "" ) {
      if ( OrderProfit() < 0 ) {
         OrderClose(OrderTicket(),OrderLots(),(OrderType() == OP_BUY ? Bid : Ask),0,clrAliceBlue);
      } else {
         if ( OrderType() == OP_BUY ) {
            double sl = MathMin(Low[1],Low[2]);
            sl = MathMin(Low[3],sl);
            if ( OrderStopLoss() < sl ) {
               OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration(),clrDarkGoldenrod);
            }
          } else {
            double sl = MathMax(High[1],High[2]);
            sl = MathMax(High[3],sl);
            if ( OrderStopLoss() > sl ) {
               OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),OrderExpiration(),clrDarkGoldenrod);
            }
          
          }
      }
   }

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


bool ArrowBuyCreate( 
                    const string          name="ArrowBuy",   // sign name 
                    datetime              time=0,            // anchor point time 
                    double                price=0,           // anchor point price 
                    const color           clr=C'3,95,172',   // sign color 
                    const ENUM_LINE_STYLE style=STYLE_SOLID, // line style (when highlighted) 
                    const int             width=1,           // line size (when highlighted) 
                    const long            chart_ID=0,        // chart's ID
                    const int             sub_window=0,      // subwindow index 
                    const bool            back=false,        // in the background 
                    const bool            selection=false,   // highlight to move 
                    const bool            hidden=true,       // hidden in the object list 
                    const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price); 
//--- reset the error value 
   ResetLastError(); 
//--- create the sign 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_BUY,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Buy\" sign! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set a sign color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set a line style (when highlighted) 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set a line size (when highlighted) 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the sign by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
  //+------------------------------------------------------------------+ 
//| Create Sell sign                                                 | 
//+------------------------------------------------------------------+ 
bool ArrowSellCreate(
                     const string          name="ArrowSell",  // sign name                     
                     datetime              time=0,            // anchor point time 
                     double                price=0,           // anchor point price 
                     const color           clr=C'225,68,29',  // sign color 
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // line style (when highlighted) 
                     const int             width=1,           // line size (when highlighted) 
                     const long            chart_ID=0,        // chart's ID 
                     const int             sub_window=0,      // subwindow index 
                     const bool            back=false,        // in the background 
                     const bool            selection=false,   // highlight to move 
                     const bool            hidden=true,       // hidden in the object list 
                     const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price); 
//--- reset the error value 
   ResetLastError(); 
//--- create the sign 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_SELL,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Sell\" sign! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set a sign color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set a line style (when highlighted) 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set a line size (when highlighted) 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the sign by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
  void ChangeArrowEmptyPoint(datetime &time,double &price) 
  { 
//--- if the point's time is not set, it will be on the current bar 
   if(!time) 
      time=TimeCurrent(); 
//--- if the point's price is not set, it will have Bid value 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
  } 