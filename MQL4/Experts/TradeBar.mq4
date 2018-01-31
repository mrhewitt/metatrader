//+------------------------------------------------------------------+
//|                                                     TradeBar.mq4 |
//|                                      Copyright 2017, Mark Hewitt |
//|                                       https://www.markhewitt.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Mark Hewitt"
#property link      "https://www.markhewitt.com"
#property version   "1.00"
#property strict

input double Lots = 0.02;

bool longActive = false;
bool shortActive = false;
bool retraceActive = false;
double retracePrice = 0;

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
   ButtonCreate("btnSell",5,17,80,56,"SELL", clrDarkBlue);
   ButtonCreate("btnBuy",90,17,80,56,"BUY", clrDarkBlue);
   ButtonCreate("btnFlatten",175,17,100,56,"FLATTEN");
   ButtonCreate("btnLong", 280,17,80,56,"LONG",clrDimGray);
   ButtonCreate("btnShort", 365,17,80,56,"SHORT",clrDimGray);
   ButtonCreate("btnRetrace", 450,17,80,56,"RETRACE",clrDimGray);
   reset();
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
   ObjectDelete("btnBuy");
   ObjectDelete("btnSell");
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

      // must go long when a new bar opens, but only if retrace price is not set, if there is a retrace price then we
      // are in fact already in our trade bar , didnt get an entry, and therefor just cancel
      if (  newBar(previousBar,Symbol(),Period()) ) {
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
      if ( newBar(previousBar,Symbol(),Period()) ) {
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
   ObjectSetInteger(0,"btnShort",OBJPROP_BGCOLOR,clrDimGray); 
   ObjectSetInteger(0,"btnLong",OBJPROP_BGCOLOR,clrDimGray); 
   ObjectSetInteger(0,"btnRetrace",OBJPROP_BGCOLOR,clrDimGray); 
   ObjectDelete(0,"RetraceEntryPoint");
}

void flatten( int onlyTradesOf = -1 ) {

   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderSymbol() == Symbol() && (onlyTradesOf == -1 || OrderType() == onlyTradesOf) ) {
         OrderClose(OrderTicket(),OrderLots(),(OrderType() == OP_BUY ? Bid : Ask),0);
      }
   }
   
   reset();
}

void buy() {
  flatten(OP_SELL);
  OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, iLow(Symbol(),Period(),1) - 0.0001, 0);
}

void sell() {
   flatten(OP_BUY);
   OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, iHigh(Symbol(),Period(),1) + 0.0001, 0); 
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