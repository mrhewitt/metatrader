//+------------------------------------------------------------------+
//|                                        T3MA Dynamic Envelope.mq4 |
//|                                        Copyright © 2009, sjcoinc |
//|                                            sjcoinc2000@yahoo.com |
//|                         modified for T3 MA by mediciforexfactory |
//+------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 C'255,255,255'
#property indicator_color2 Silver
#property indicator_color3 Silver

extern int        MAPeriod = 30;
extern double     HotParameter = 0.4;
extern int        ATRPeriod = 100;
extern double     ATRMultiple = 4;


double ma[],lower[],upper[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

      SetIndexBuffer(0,ma);
      SetIndexStyle(0,DRAW_LINE);
      SetIndexLabel(0,"MovingAverage"+MAPeriod);
      
      SetIndexBuffer(1,lower);
      SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
      SetIndexLabel(1,"LowerBand"+ATRPeriod);
      
      SetIndexBuffer(2,upper);
      SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
      SetIndexLabel(2,"UpperBand"+ATRPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double atr;
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=0; i<limit; i++)   
      {
         atr = iATR(NULL,0,ATRPeriod,i);
         ma[i] = iCustom(NULL,0,"T3 MA",MAPeriod,HotParameter,0,i);
         lower[i]=ma[i]-(atr*ATRMultiple);
         upper[i]=ma[i]+(atr*ATRMultiple);
      
      }
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+