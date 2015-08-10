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

bool initVariables = true;
bool hasNewBar = false;
datetime barM1 = NULL;     // for testing
datetime barM15 = NULL;
datetime barM30 = NULL;
datetime barH1 = NULL;

string buttonClr = "buttonclr";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   if ( initVariables )
   {
      barM1 = iTime(Symbol(),PERIOD_M1,0);
      barM15 = iTime(Symbol(),PERIOD_M15,0);
      barM30 = iTime(Symbol(),PERIOD_M30,0);
      barH1 = iTime(Symbol(),PERIOD_H1,0);
      initVariables = false;
   }  
   
   int btnLeft = 220;
   int btnSpace = 55;
   
   // button to clear the template background after I've seen the signal
   button( buttonClr, "Reset", btnLeft );   
   btnLeft += btnSpace;
   
//---
   return(INIT_SUCCEEDED);
}

void button(string name, string label, int left, int width = 50) {
   ObjectCreate(0,name,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGray);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,left);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,0);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,16);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,label);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
}
  
   
//+------------------------------------------------------------------+
//| Handle chart events (click of the reset button)                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
 {
   // trap the click on the clear button event
   if ( id == CHARTEVENT_OBJECT_CLICK ) {
      string clickedChartObject=sparam;
      
      if ( clickedChartObject == buttonClr ) {
         // reset the background to our default empty
         ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,clrNONE);
         ChartSetSymbolPeriod( ChartID(), Symbol(), PERIOD_M30 );
             
         // reset state of button to unclicked
         ObjectSetInteger(0,buttonClr,OBJPROP_STATE,0);
         ChartRedraw();
      }
   }
}
   
   
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
 /* 
  * M1 block, use for testing so signals appear rapidly!
  
  detect(barM1,PERIOD_M1);
  */
  
  /*
   * Actual code for detecting intraday moves
   */
   
   if ( !detectLimited(barM15,PERIOD_M15) ) {
      if ( !detect(barM30,PERIOD_M30) ) {
         detect(barH1,PERIOD_H1);
      }
   }
}

bool detect(datetime& barTime, int period) {
   if ( hasNewBar(barTime,Symbol(),period) ) {
      if ( detectArrow(Symbol(), period) != TRADE_ARROW_NONE ) {
         showAlert(period,"Standard Arrow");
         return true;
      }
    
      // now we want to find all the arrows that did not meet our standard of being at a turning
      // point but did perform a trendline break
      int obj_total = ObjectsTotal();
      string name;
      for ( int i=0; i < obj_total; i++ )
      {
        string name = ObjectName(i);
        int objType = ObjectType(name);
     
        // we only work with line types
        if ( objType == OBJ_HLINE || objType == OBJ_TREND ) {

          bool tlBreak = crossedTrendline(name,period);      // did this bar cross over this line?
          if ( tlBreak ) Print("trendline break");
        
          // first lets see if there is an arrow on a trendline break
          if ( tlBreak && barHasArrow(Symbol(),period) != TRADE_ARROW_NONE ) {
               showAlert(period,"Arrow Trendline Break");
               return true;
          }  
          
          // if this is a horizontal line and price didn't cross but it did spike over it alert
          if ( objType == OBJ_HLINE ) { 
             // get the price of the line at the last bar
            double price = ObjectGet(name, OBJPROP_PRICE1);
            if ( !tlBreak && 
                 ((iHigh(Symbol(),period,1) > price && iClose(Symbol(),period,1) < price && iOpen(Symbol(),period,1) < price) ||
                  (iLow(Symbol(),period,1) < price && iClose(Symbol(),period,1) > price && iOpen(Symbol(),period,1) > price))
               ) {
               showAlert(period,"Horizontal Bounce");
               return true;
          }
        }
      }
     }
     
     return ( detectLimited(barTime, period) );
   }
   return false;    
}

bool detectLimited(datetime& barTime, int period) {
   if ( hasNewBar(barTime,Symbol(),period) ) {
       // if we crossed a big MA, and the next bar is a pullback but still shows on the same side as the cross alert
       if ( detectMaCross(Symbol(),period,200,MODE_SMA,2) && detectBarToMA(Symbol(),period,200) ||
            detectMaCross(Symbol(),period,89,MODE_SMA,2) && detectBarToMA(Symbol(),period,89) ||
            detectMaCross(Symbol(),period,50,MODE_EMA,2) && detectBarToMA(Symbol(),period,50,MODE_EMA)
          ) {
            showAlert(period,"Moving Average Wave");
            return true;
       }
   }
   return false;    
}

void showAlert(int period, string comment) {
   ChartSetSymbolPeriod( ChartID(), Symbol(), period );
   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,clrMidnightBlue);  
   Comment(comment);
   Print(comment);
   PlaySound("stops.wav");
}

// This function return the value true if the current bar/candle was just formed
// Inspired by: simplefx2.mq4, http://www.GetForexSoftware.com
bool hasNewBar(datetime& previousBar,string symbol,int timeframe)
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

//+------------------------------------------------------------------+
