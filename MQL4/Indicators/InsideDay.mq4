//+------------------------------------------------------------------+
//|                                                    InsideDay.mq4 |
//|                                      Copyright 2015, Mark Hewitt |
//|                                      http://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Mark Hewitt"
#property link      "http://www.markhewitt.co.za"
#property version   "1.00"
#property strict
#property indicator_chart_window

string high_line = "idlnhigh";
string low_line = "idlnlow";
string high_label = "idlblhigh";
string low_label = "idlbllow";
int day = -1;
int hour = -1;
bool idf = false;

void tearDown() {
   ObjectDelete(0,high_line);
   ObjectDelete(0,low_line);
   ObjectDelete(0,high_label);
   ObjectDelete(0,low_label);
}

void line(string name, double price) {
   MqlDateTime end;
   TimeToStruct(TimeCurrent(),end);
   end.hour = 8;
   ObjectCreate(name,OBJ_TREND,0,iTime(Symbol(),PERIOD_D1,1),price,StructToTime(end),price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrSteelBlue);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,PERIOD_H1);
}

datetime textTime() {
   MqlDateTime end;
   TimeToStruct(TimeCurrent(),end);
   end.hour += 8;
   return StructToTime(end);
}

void text(string name, string label, double price, int corner = ANCHOR_TOP) {
      
   ObjectCreate(0,name,OBJ_TEXT,0,textTime(),price);
   ObjectSetText(name,label);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,label);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   //ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);  
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrSteelBlue);
   ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,PERIOD_H1);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,corner);
}

void setup() {
   tearDown();
   day = Day();
   hour = Hour();
   
   double high = iHigh(Symbol(),PERIOD_D1,1);
   double low = iLow(Symbol(),PERIOD_D1,1);
   if ( high <= iHigh(Symbol(),PERIOD_D1,2) &&
        low >= iLow(Symbol(),PERIOD_D1,2) ) {
      idf = true;
      line(high_line,high);
      line(low_line,low);
      text(high_label,"Inside Day High",high,ANCHOR_LEFT_LOWER);
      text(low_label,"Inside Day Low",low);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   setup();
//---
   return(INIT_SUCCEEDED);
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
   if ( Day() != day ) {
      setup();
   }
   
   if ( idf && hour != Hour() ) {
      ObjectMove(0,high_label,0,textTime(),iHigh(Symbol(),PERIOD_D1,1));
      ObjectMove(0,low_label,0,textTime(),iLow(Symbol(),PERIOD_D1,1));
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
