//+------------------------------------------------------------------+
//|                                                     TradeBar.mq4 |
//|                                      Copyright 2017, Mark Hewitt |
//|                                       https://www.markhewitt.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Mark Hewitt"
#property link      "https://www.markhewitt.com"
#property version   "1.00"
#property strict

input double Lots = 0.5;

bool longActive = false;
bool shortActive = false;
datetime previousBar ;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

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

int OnInit()
  {
//---
   // create a button next to the One Click Trading bar
   ButtonCreate("btnFlatten",200,17,100,56,"FLATTEN");
   ButtonCreate("btnLong", 305,17,100,56,"LONG",clrMidnightBlue);
   ButtonCreate("btnShort", 410,17,100,56,"SHORT",clrMidnightBlue);
   longActive = false;
   shortActive = false;
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
   ObjectDelete("btnFlatten");
   ObjectDelete("btnLong");
   ObjectDelete("btnShort");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   if ( longActive ) {
   
      // must go long when a new bar opens
      if ( newBar(previousBar,Symbol(),Period()) ) {
         // really just reset state of flags and buttons as there are no orders
         flatten();
         // only buy if this bar is bulish, if it snapped down and formed a bear bar we dont want it
         if ( iClose(Symbol(),Period(),1) == iHigh(Symbol(),Period(),1) ) {
            OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, iLow(Symbol(),Period(),1) - 0.0001, 0);
         } 
      }
   
   } else if ( shortActive ) {
   
      // go short on new bar
      if ( newBar(previousBar,Symbol(),Period()) ) {
         // really just reset state of flags and buttons as there are no orders
         flatten();
         // only sell if this bar is bearish, if it snapped up and formed a bull bar we dont want it
         if ( iClose(Symbol(),Period(),1) == iLow(Symbol(),Period(),1) ) {
            OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, iHigh(Symbol(),Period(),1) + 0.0001, 0); 
         }
      }
   
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
        if ( sparam == "btnFlatten" ) {
           flatten() ; 
        } 
        if ( sparam == "btnLong" ) {
          previousBar = iTime(Symbol(),Period(),0);
          if ( !longActive ) {
              ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrGreen);  
              ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrMidnightBlue); 
              longActive = true; shortActive = false; 
           } else {
              ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrMidnightBlue); 
              longActive = false;
           }
        } 
         if ( sparam == "btnShort" ) {
           previousBar = iTime(Symbol(),Period(),0);
           if ( !shortActive ) {
              ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrCrimson);  
              ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrMidnightBlue); 
              shortActive = true; longActive = false; 
           } else {
              ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrMidnightBlue); 
              shortActive = false;
           }
        } 
     }      
  }
//+------------------------------------------------------------------+

void flatten() {

   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderSymbol() == Symbol() ) {
         OrderClose(OrderTicket(),OrderLots(),(OrderType() == OP_BUY ? Bid : Ask),0);
      }
   }
   
   shortActive = false; longActive = false; 
   ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrMidnightBlue); 
   ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrMidnightBlue); 
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