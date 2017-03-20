//+------------------------------------------------------------------+
//|                                                   Statistics.mqh |
//|                                      Copyright 2015, Mark Hewitt |
//|                                      http://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Mark Hewitt"
#property link      "http://www.markhewitt.co.za"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

/**
 * Returns the range of the given bar
 */
double barRange(string symbol, int timeframe, int shift) {
   return MathAbs(iHigh(symbol,timeframe,shift)-iLow(symbol,timeframe,shift));
}

/**
 * Returns the percentage that this bars range made relative to ATR(20)
 */
double percentOfATR(string symbol, int timeframe, int shift) {
   return barRange(symbol,timeframe,shift) / iATR(symbol,timeframe,20,shift+1);
}

/**
 * Returns the percent of shadow between close and high/low, i.e. if the bar closes
 * down the return is (gap between close/low) / (bar range)
 */
double shadowRatio(string symbol, int timeframe, int shift) {
   double range = barRange(symbol,timeframe,shift);
   if ( isBullBar(symbol,timeframe,shift) ) {
      return (iHigh(symbol,timeframe,shift)-iClose(symbol,timeframe,shift))/range;
   } else {
      return (iClose(symbol,timeframe,shift)-iLow(symbol,timeframe,shift))/range;
   } 
}

bool isSwingBar( string symbol, int dir, int timeframe, int shift ) {
   if ( dir == TRADE_ARROW_SELL ) { 
      return isHighestHigh(symbol,timeframe,shift,4) || isHighestHigh(symbol,timeframe,shift+1,3);
   } else {
      return isLowestLow(symbol,timeframe,shift,4) || isLowestLow(symbol,timeframe,shift+1,3);
   }
   return false;
}

/**
 * Returns true is the given value is higher than the high of every bar going back [n] bars
 */
bool isHighestHigh( string symbol, int timeframe, int shift, int barsBack ) {
   double v = iHigh(symbol,timeframe,shift);
   for ( int i = shift+1; i < shift+barsBack; i++ ) {
      if ( iHigh(symbol,timeframe,i) > v ) { return false; } 
   } 
   return true;
}
/**
 * Returns true is the given value is lower than the low of every bar going back [n] bars
 */
bool isLowestLow( string symbol, int timeframe, int shift, int barsBack ) {
   double v = iLow(symbol,timeframe,shift);
   for ( int i = shift+1; i < shift+barsBack; i++ ) {
      if ( iLow(symbol,timeframe,i) < v ) { return false; } 
   } 
   return true;
}
 

int statsOpenCSV(string symbol, string fname, string headers) {

   FileDelete("Data//"+symbol+"-"+fname+".csv");
   int file_handle = FileOpen("Data//"+symbol+"-"+fname+".csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
   if ( file_handle < 0 ) {
      Print("Failed to open the file by the absolute path ");
      Print("Error code ",GetLastError());
   }
     
   FileWriteString(file_handle, "Symbol;Date;Open;Close;High;Low;" + headers + "\r\n");
   
   return file_handle;

}

// file , symbol, shift
void statsWrite(int file_handle, string s, int i, string data ) {

   double high = iHigh(s,PERIOD_D1,i);    
   double low = iLow(s,PERIOD_D1,i);
   double open = iOpen(s,PERIOD_D1,i);
   double close = iClose(s,PERIOD_D1,i);
           
   FileWriteString(file_handle,s + ";" + TimeToString(iTime(s,PERIOD_D1,i),TIME_DATE) + ";" +(string)open + ";" +(string)close + ";" + (string)high + ";" + (string)low + ";" + data + "\r\n");

}

 
bool VLineCreate (
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

bool ArrowUpCreate(
                   string            name,       // sign name 
                   string symbol,
                   int shift,
                   const color             clr=clrRed,           // sign color 
                   int timeframe = PERIOD_D1
)            // priority for mouse click 
  { 
   long              chart_ID=0;          // chart's ID 
    int               sub_window=0;         // subwindow index 
    datetime                time=iTime(symbol,timeframe,shift);               // anchor point time 
    double                  price=iLow(symbol,timeframe,shift);              // anchor point price 
     ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP; // anchor type 
     ENUM_LINE_STYLE   style=STYLE_SOLID;    // border line style 
     int               width=3;              // sign size 
     bool              back=false;          // in the background 
     bool              selection=false;       // highlight to move 
     bool              hidden=true;          // hidden in the object list 
     long              z_order=0;
                    
//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price); 
//--- reset the error value 
   ResetLastError(); 
//--- create the sign 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_UP,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Arrow Up\" sign! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- set a sign color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set the border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set the sign size 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the sign by mouse 
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

bool ArrowDownCreate( 
                      string            name,     // sign name 
                    string symbol,
                   int shift,
                     const color             clr=clrRed,           // sign color 
                    int timeframe = PERIOD_D1

)            // priority for mouse click 
  { 
  long chart_ID=0;           // chart's ID
  int sub_window=0;         // subwindow index 
    datetime                time=iTime(symbol,timeframe,shift);               // anchor point time 
    double                  price=iHigh(symbol,timeframe,shift);              // anchor point price 

                      ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM; // anchor type 
                      ENUM_LINE_STYLE   style=STYLE_SOLID;    // border line style 
                      int               width=3;             // sign size 
                      bool              back=false;           // in the background 
                      bool              selection=false;       // highlight to move 
                      bool              hidden=true;         // hidden in the object list 
                      long              z_order=0;

//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price); 
//--- reset the error value 
   ResetLastError(); 
//--- create the sign 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_DOWN,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Arrow Down\" sign! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- set a sign color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set the border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set the sign size 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the sign by mouse 
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
//+------------------------------------------------------------------+ 
//| Check anchor point values and set default values                 | 
//| for empty ones                                                   | 
//+------------------------------------------------------------------+ 
void ChangeArrowEmptyPoint(datetime &time,double &price) 
  { 
//--- if the point's time is not set, it will be on the current bar 
   if(!time) 
      time=TimeCurrent(); 
//--- if the point's price is not set, it will have Bid value 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
  } 