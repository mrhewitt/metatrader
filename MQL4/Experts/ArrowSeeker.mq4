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
   
   if ( !detect(barM30,PERIOD_M30) ) {
      detect(barH1,PERIOD_H1);
   }
   
}

bool detect(datetime& barTime, int period) {
   if ( hasNewBar(barTime,Symbol(),period) ) {
      if ( detectArrow(Symbol(), period) != TRADE_ARROW_NONE ) {
         ChartSetSymbolPeriod( ChartID(), Symbol(), period );
         ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,clrMidnightBlue);  
         PlaySound("stops.wav");
         return true;
      }
   }
   return false;    
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
