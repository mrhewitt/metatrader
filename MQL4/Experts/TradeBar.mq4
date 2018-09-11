//+------------------------------------------------------------------+
//|                                                     TradeBar.mq4 |
//|                                      Copyright 2017, Mark Hewitt |
//|                                       https://www.markhewitt.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Mark Hewitt"
#property link      "https://www.markhewitt.com"
#property version   "1.00"
#property strict

input double Lots = 0.3;
input double AutoLots = 0.01;
input int Magic = 123987;

bool longActive = false;
bool shortActive = false;
bool retraceActive = false;
double retracePrice = 0;
int   barsSinceEntry = 0;  

datetime previousBar ;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//---
   // create a button next to the One Click Trading bar
   ButtonCreate("btnSell",5,17,80,56,"SELL", clrDarkBlue);
   ButtonCreate("btnBuy",90,17,80,56,"BUY", clrDarkBlue);
   ButtonCreate("btnFlatten",175,17,100,56,"FLATTEN");
   ButtonCreate("btnLong", 280,17,80,56,"LONG",clrDimGray);
   ButtonCreate("btnShort", 365,17,80,56,"SHORT",clrDimGray);
   ButtonCreate("btnRetrace", 450,17,80,56,"RETRACE",clrDimGray);
   reset();
   previousBar = iTime(Symbol(),Period(),0);

   ObjectsDeleteAll(ChartID(),0,OBJ_ARROW_BUY);
   ObjectsDeleteAll(ChartID(),0,OBJ_ARROW_SELL);   
   
   // lookback to start of the chart and move forward applying the trade logic to all bars
   // so we can get a better idea of how the expert would have applied our trade rules
   for ( int i = Bars - 50; i--; i > 0 ) {
      autoTradePatterns(i);
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
   ObjectDelete("btnBuy");
   ObjectDelete("btnSell");
   ObjectDelete("btnFlatten");
   ObjectDelete("btnLong");
   ObjectDelete("btnShort");

   ObjectsDeleteAll(0,0,OBJ_ARROW_BUY);
   ObjectsDeleteAll(0,0,OBJ_ARROW_SELL);   
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool isNewBar = newBar(previousBar,Symbol(),Period());
   
   if ( longActive ) {

      // must go long when a new bar opens, but only if retrace price is not set, if there is a retrace price then we
      // are in fact already in our trade bar , didnt get an entry, and therefor just cancel
      if ( isNewBar ) {
         // only buy if this bar is bulish, if it snapped down and formed a bear bar we dont want it
         if ( retracePrice == 0 && Close[1] == High[1] ) {
           // want buy and bar closed up, cut & reverse if there any any open trades
           // check though for the retrce button, if set then we wait for retrace to close of previous bar instead
           if ( !retraceActive ) {
             buy();
           } else {
              retracePrice = Close[1];
              ArrowRightPriceCreate(Time[0],retracePrice);
           }
         } else {
            // bear bar, just reset the button state, leave any shorts currently in place alone
            reset();
         }
      } else if ( retracePrice != 0 ) {
         // new tick but not a new bar, if waiting for retrace check to see if we trade
         if ( Bid <= retracePrice ) {
            buy();
         }
      }
   
   } else if ( shortActive ) {
   
      // go short on new bar, but only if retrace price is not set, if there is a retrace price then we
      // are in fact already in our trade bar , didnt get an entry, and therefor just cancel
      if ( isNewBar ) {
         // really just reset state of flags and buttons as there are no orders
         // only sell if this bar is bearish, if it snapped up and formed a bull bar we dont want it
         if (  retracePrice == 0 && Close[1] == Low[1] ) {
            // want short and bar closed down, cut & reverse if there any any open trades
            // check though for the retrce button, if set then we wait for retrace to close of previous bar instead
            if ( !retraceActive ) {
               sell();
            } else {
              retracePrice = Close[1];
              ArrowRightPriceCreate(Time[0],retracePrice);
            }
         } else {
            // bull bar, just reset the button state, leave any longs currently in place alone
            reset();
         }
      } else if ( retracePrice != 0 ) {
         // new tick but not a new bar, if waiting for retrace check to see if we trade
         if ( Bid >= retracePrice ) {
            sell();
         }
      }
   
   }
   
   if ( isNewBar ) {
      autoTradePatterns();
   }
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
    if(id==CHARTEVENT_OBJECT_CLICK) 
     { 
        if ( sparam == "btnBuy" ) {
          buy();
        }
        
        if ( sparam == "btnSell" ) {
          sell();
        }
        
        if ( sparam == "btnFlatten" ) {
           flatten() ; 
        } 
        
        if ( sparam == "btnLong" ) {
          previousBar = iTime(Symbol(),Period(),0);
          if ( !longActive ) {
              ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrChocolate);  
              ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrDimGray); 
              longActive = true; shortActive = false; 
           } else {
              ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrDimGray); 
              longActive = false;
           }
        } 
         if ( sparam == "btnShort" ) {
           previousBar = iTime(Symbol(),Period(),0);
           if ( !shortActive ) {
              ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrChocolate);  
              ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrDimGray); 
              shortActive = true; longActive = false; 
           } else {
              ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrDimGray); 
              shortActive = false;
           }
        } 
        if ( sparam == "btnRetrace" ) {
            if ( retraceActive ) {
               ObjectSetInteger(0,"btnRetrace",OBJPROP_BGCOLOR,clrDimGray);  
               retraceActive = false;
            } else {
               ObjectSetInteger(0,"btnRetrace",OBJPROP_BGCOLOR,clrChocolate);  
               retraceActive = true;
            }  
        }
        
     }      
  }
//+------------------------------------------------------------------+

void reset() {   
   shortActive = false; longActive = false;    retraceActive = false;
   retracePrice = 0;
   barsSinceEntry = 0; 
   ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrDimGray); 
   ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrDimGray); 
   ObjectSetInteger(0,"btnRetrace",OBJPROP_BGCOLOR,clrDimGray); 
   ObjectDelete(0,"RetraceEntryPoint");
   ChartBackColorSet(clrBlack);
}

void flatten( int onlyTradesOf = -1 ) {

   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && (onlyTradesOf == -1 || OrderType() == onlyTradesOf) ) {
         OrderClose(OrderTicket(),OrderLots(),(OrderType() == OP_BUY ? Bid : Ask),0);
      }
   }
   
   reset();
}

void buy() {
  flatten(OP_SELL);
  OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, iLow(Symbol(),Period(),1) - 0.0001, 0, "ERB", Magic);
}

void sell() {
   flatten(OP_BUY);
   OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, iHigh(Symbol(),Period(),1) + 0.0001, 0, "ERB", Magic); 
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

  
void autoTradePatterns(int currentBar = 0) {

      if ( openOrder() ) {
         barsSinceEntry++;
         fourBarTrail();
      } else {
      
         int tradeType = barType(currentBar+1,false); 
         int prevBar = barType(currentBar+2,false);
         int dema = DEMA(currentBar);
         
         if ( tradeType == dema && MathAbs(High[currentBar+1] - Low[currentBar+1]) < 0.00035 ) {

            /// SMALL PULLBACK
         
            Print("Evaluating SP");
            // SP only when the bar that just closed closed in the opposite direction to the one precening it, i.e. a turning point
            if ( tradeType != prevBar ) {
               int count = 0;
               while ( barType(currentBar+count+2,(count < 2)) != tradeType && barType(currentBar+count+2,(count < 2)) != -1 ) { count++; }
               Print ("Bar count ", count);
               if ( count >= 2 && ( (tradeType == OP_BUY && highestHigh(currentBar+count+1,5)) || (tradeType == OP_SELL && lowestLow(currentBar+count+1,5)) ) ){
                  double dSlope = slope(currentBar,count+1);
               //   Print("DEMA Slope == ", dSlope);
                  // DEMA must be sloping our way, the base must be clean and not a 4 bar range and the T3 must have turned on at least one bar
                  if ( dSlope > 0.0001 ) {
                     if ( !isRange(currentBar+count+1,tradeType) ) {
                       if ( T3(currentBar+2) == inverse(tradeType) ) {
                         placeOrder(tradeType,"SP",currentBar);
                         return;
                       } else {
                        Print("SP at ", Open[currentBar+0], " Rejected - no momentum change");
                       }
                     } else {
                        Print("SP at ", Open[currentBar+0], " Rejected - base is ranged");
                     }    
                  } else {
                     Print("SP at ", Open[currentBar+0], " Rejected - DEMA slope is ", DoubleToString(dSlope));
                  }
               } 
            }
                        
            // 4 bar trend pattern T1
         
            // is the t3 going in our direction, and is the market in a range for the last few bars
            Print("Evaluating T1");
            int barsInRange = 0;
            if ( T3(currentBar+1) == tradeType && (barsInRange = isRange(currentBar+1,tradeType,0.0006)) >= 4 ) {
               
               // at least one bar in the pattern must be a fully inverse to trade direction
               bool flipped = false;
               for ( int i = currentBar+1; i <= barsInRange+currentBar && !flipped; i++ ) {
                  if ( T3(currentBar+i) == inverse(tradeType) ) { flipped = true; }
               }
               
               // if we did turn the t3, find the bar preceding the pattern that form the highest high/lowest low of the 3 bars
               // preceding it, and make sure this is 2 pips from our entry, to ensure a pullback occured and we dont trade the swing hi/lo
               if ( flipped ) {
                  int i = barsInRange+currentBar;
                  if ( tradeType == OP_BUY ) {
                     // find highest high in 3 bars
                     while ( !highestHigh(i,3) ) { i++; }                     
                     if ( High[i] > Open[currentBar+0] + 0.0002 ) { 
                        placeOrder(tradeType,"T1",currentBar); 
                     } else { 
                        Print("Range ", barsInRange, " range lookback ", i, " high of ", High[i], " less than ", Open[currentBar+0], " + 0.0002 of ", Open[currentBar+0] + 0.0002);  
                     } 
                  } else {
                     // find lowest low in 3 bars
                     while ( !lowestLow(i,3) ) { i++; }                     
                     if ( Low[i] < Open[currentBar+0] - 0.0002 ) { 
                        placeOrder(tradeType,"T1",currentBar); 
                     } else { 
                        Print("Range ", barsInRange, " range lookback ", i, " low of ", Low[i], " less than ", Open[currentBar+0], " - 0.0002 of ", Open[currentBar+0] - 0.0002);  
                     } 
                 }
               } else {
                  Print("T1 rejected: No T3 turn");
               }
                            
               /*
               Print("T1 on T3 and range");
               // check to see that the 4 bar pattern was preceded by a pullback enough to turn at least
               // one bar the oppsite way, i.e. auto trade only deep pullbacks
               int pullback_bars = 0;
               for ( int i = barsInRange; i <= 4; i++ ) {
//                  Print("Bar ", i, " is ", T3(i), " against ", inverse(tradeType));
                  if ( T3(i) == inverse(tradeType) ) { pullback_bars++; }
               }   
               placeOrder(tradeType);*/
            }
         
         }
         
       }
}  
  


//========================================================
//       AUTO PATTERN TRADE HANDLING CODE
//========================================================


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
void placeOrder(int tradeType, string type, int currentBar) {
   if ( tradeType == OP_BUY ) {
      Print("Long at ", Ask);
      ArrowBuyCreate(type + " @ " + DoubleToString(Open[currentBar]), Time[currentBar+1], Open[currentBar+0]);
     // OrderSend(Symbol(), OP_BUY, AutoLots, Ask, 0, iLow(Symbol(),Period(),1) - 0.0001, Ask + 0.0012, "PTSP");  
      barsSinceEntry = 0;          
   } else {
      //OrderSend(Symbol(), OP_SELL, AutoLots, Bid, 0, iHigh(Symbol(),Period(),1) + 0.0001, Bid - 0.0012, "PTSP"); 
      Print("Short at ", Bid);
      ArrowSellCreate(type + " @ " + DoubleToString(Open[currentBar]), Time[currentBar+1], Open[currentBar+0]);
      barsSinceEntry = 0;          
   }                  
}

int highestHigh(int shift, int bars) {
   for ( int i = shift; i < bars+shift; i++ ) {
      if ( High[shift] < High[i] ) { Print("Highest high : ", Time[shift], "(", shift, ") not highest"); return false; }
   }
  // Print("Highest high : ", Time[shift], "(", shift, ") is highest");
   return true;
}

int lowestLow(int shift, int bars) {
   for ( int i = shift; i < bars+shift; i++ ) {
      if ( Low[shift] > Low[i] ) { Print("Lowest low : ", Time[shift], "(", shift, ") not lowest"); return false; }
   }
 //  Print("Lowest low : ", Time[shift], "(", shift, ") is lowest"); 
   return true;
}

int T3(int shift) {
   double t3ma = iCustom(Symbol(),Period(),"T3 MA Colour",4,0.4,0,shift);
   double value2 = iCustom(Symbol(),Period(),"T3 MA Colour",4,0.4,1,shift);
   double value4 = iCustom(Symbol(),Period(),"T3 MA Colour",4,0.4,3,shift); 
 //  Print("T3MA : ", t3ma, ", value2: ", value2, ", value4: " , value4);
   if ( value2 == value4 ) {
      return -1;
   } else if ( value2 == t3ma ) {
      return OP_BUY;
   } else if ( value4 == t3ma ) {
      return OP_SELL;
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

int DEMA(int currentBar) {
 //  Print( "DEMA @ " , iCustom(Symbol(),Period(),"DEMA",40,0,1), " against bar close ", Close[1], ": ", ( iCustom(Symbol(),Period(),"DEMA",0,1) < Close[1] ? OP_BUY : OP_SELL ) );
   return ( iCustom(Symbol(),Period(),"DEMA",40,0,currentBar+1) < Close[currentBar+1] ? OP_BUY : OP_SELL );
}

int barType(int shift, bool ignorePins = true) {
   if ( Close[shift] < Open[shift] || (!ignorePins && (Close[shift] == Open[shift]) && (Close[shift] == Low[shift])) ) {
     return (OP_SELL);
   } else if ( Close[shift] > Open[shift] || (!ignorePins && (Close[shift] == Open[shift]) && (Close[shift] == High[shift])) ) {
      return (OP_BUY);
   }
   return (-1);
}

double slope(int currentBar, int shift) {
   return MathAbs(iCustom(Symbol(),Period(),"DEMA",40,0,currentBar) - iCustom(Symbol(),Period(),"DEMA",40,0,currentBar+shift));
}

/**
 * Looks bar from bar shift (including shift) until it finds the range of the bars (from highest high to lowest low)
 * becomes greater than the given rangeWidth parameter
 * Return is the number of bars found in the range
 *
 * e..g  isRange(1)  will start with the bar before current (i.e. last full closed bar) and look back until the range of
 * highest high and lowest low found is greater than 0.0006 (default range) 
 */
int isRange(int shift, int tradeType, double rangeWidth = 0.0006) {

   // look back until the bars no longer fit into the given range
   double max = 0;
   double min = 9999;
   double range = 0;
   int count = 0;
   while ( range <= rangeWidth ) {
      
      // to count as a bar in the range, either the high or low of the bar must be on the right side of the dema
      double high = High[shift+count];
      double low = Low[shift+count];
      double dema = iCustom(Symbol(),Period(),"DEMA",40,0,shift+count);
      
      // we ject the bar if both high and low falls on other side of the dema to our trade
      if ( (low >= dema && tradeType == OP_SELL) || (high <= dema && tradeType == OP_BUY) ) {
         range = 99999;
      } else {  
         max = MathMax(high,max);
         min = MathMin(low,min);
         range = max - min;
      }
      count++;
   } 

   Print("Bar range: " , range);
   return ( count - 1 );
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
  
  
bool ArrowRightPriceCreate(datetime              time=0,            // anchor point time 
                           double                price=0,           // anchor point price 
                           const color           clr=clrRed,        // price label color 
                           const ENUM_LINE_STYLE style=STYLE_SOLID, // border line style 
                           const int             width=1,           // price label size 
                           const bool            back=false,        // in the background 
                           const bool            selection=true,    // highlight to move 
                           const bool            hidden=true,       // hidden in the object list 
                           const long            z_order=0)         // priority for mouse click 
  { 
   long chart_ID=0;
   string name="RetraceEntryPoint";
   int             sub_window=0;
    
//--- reset the error value 
   ResetLastError(); 
//--- create a price label 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create the right price label! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set the label color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set the border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set the label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the label by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
  
bool ButtonCreate(
                  const string            name="Button",            // button name 
                  const int               x=0,                      // X coordinate 
                  const int               y=0,                      // Y coordinate 
                  const int               width=50,                 // button width 
                  const int               height=18,                // button height 
                  const string            text="Button",            // text 
                  const color             back_clr=clrPurple,        // background color 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                  const string            font="Arial",             // font 
                  const int               font_size=10,             // font size 
                  const color             clr=clrWhite,             // text color 
                  const color             border_clr=clrWhiteSmoke,       // border color 
                  const bool              state=false,              // pressed/released 
                  const bool              back=false,               // in the background 
                  const bool              selection=false,          // highlight to move 
                  const bool              hidden=true,              // hidden in the object list 
                  const long              z_order=0)                // priority for mouse click 
  { 
   long      chart_ID=0;               // chart's ID 
   int        sub_window=0;             // subwindow index 

//--- reset the error value
 
   ResetLastError(); 
//--- create the button 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create the button! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state); 
//--- enable (true) or disable (false) the mode of moving the button by mouse 
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
//| The function sets chart background color.                        | 
//+------------------------------------------------------------------+ 
bool ChartBackColorSet(const color clr,const long chart_ID=0) 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- set the chart background color 
   if(!ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clr)) 
     { 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  }