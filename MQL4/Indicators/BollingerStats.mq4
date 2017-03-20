//+------------------------------------------------------------------+
//|                                               BollingerStats.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include "../Include/detectXXX.mqh"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
   
   
   for ( int i = 1; i < 365*5; i++ ) {
   
    /*  int e = detectEngulf(Symbol(), PERIOD_D1, i);
      if ( e != TRADE_ARROW_NONE ) {
         int c = clrRed;
         if ( e == TRADE_ARROW_BUY ) { c = clrForestGreen; }
         VLineCreate("eb"+i,iTime(Symbol(),PERIOD_D1,i),c);
      } 
      */
      double bu = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_UPPER,i);
        double bl = iBands(Symbol(),PERIOD_D1,20,2,0,PRICE_CLOSE,MODE_LOWER,i);
        if ( iClose(Symbol(),PERIOD_D1,i) < bl ) {
        VLineCreate("eb"+i,iTime(Symbol(),PERIOD_D1,i));
        }
           if ( iClose(Symbol(),PERIOD_D1,i) > bu ) {
        VLineCreate("eb"+i,iTime(Symbol(),PERIOD_D1,i),clrForestGreen);
        }     

   }
   
//---
   return(INIT_SUCCEEDED);
   
   
   write("EURUSD");
   write("GBPUSD");
   write("EURGBP");
   write("EURJPY");
   write("USDCHF");     
   write("USDJPY");     
   write("USDCAD");
   write("NZDUSD");
   write("AUDUSD");
   write("GBPJPY");     
   write("GOLD");     
   write("SILVER");     
   
//---
   return(INIT_SUCCEEDED);
  }
  
bool VLineCreate(
                 const string          name="VLine",      // line name 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
   long            chart_ID=0;        // chart's ID 
   
   int             sub_window=0;      // subwindow index 
//--- if the line time is not set, draw it via the last bar 
   if(!time) 
      time=TimeCurrent(); 
//--- reset the error value 
   ResetLastError(); 
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a vertical line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
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


void write( string s) {

   int file_handle = FileOpen("Data//"+s+".csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
   if ( file_handle < 0 ) {
      Print("Failed to open the file by the absolute path ");
      Print("Error code ",GetLastError());
   }
     
   FileWriteString(file_handle,"Symbol;Date;ATR;High;Low;Close;ATR Low;ATR High;Exceeded;Closed In;ATR IO\r\n");

   for ( int i = 1; i < 365*5; i++ ) {
      double high = iHigh(s,PERIOD_D1,i);    
      double low = iLow(s,PERIOD_D1,i);
      double atr = iATR(s,PERIOD_D1,20,i+1);
      double close = iClose(s,PERIOD_D1,i);
      double atr_low = high - atr;
      double atr_high = low + atr;
      
      string exceeded = "NO";
      if ( high >= atr_high || low <= atr_low ) {
         exceeded = "YES";
      }
      
      string closed_in = "NO";
      if ( close <= atr_high && close >= atr_low ) {
         closed_in = "YES";
      }
  
      string atrio = "";
      if ( exceeded == "YES" ) {
         atrio = closed_in;
      }     
      
      FileWriteString(file_handle,s + ";" + TimeToString(iTime(s,PERIOD_D1,i),TIME_DATE) + ";" + (string)atr + ";" + (string)high + ";" + (string)low + ";" +(string)close + ";" + (string)atr_low + ";" + (string)atr_high + ";" + exceeded+ ";" + closed_in + ";" + atrio + "\r\n");
   }
   
   FileClose(file_handle);

}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
