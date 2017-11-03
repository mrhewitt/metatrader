//+------------------------------------------------------------------+
//|                                                   NewsTrader.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define EXPERT_MAGIC 123456                             // MagicNumber of the expert
//--- input parameters
input int      NewsMinute=30;
input double   Risk=1.00;
input double   ATRMultiplier=1.5;
input int      MinLegSize=5;

int countdown = 999;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- create timer
   EventSetTimer(1);
   
 
//---
   return(INIT_SUCCEEDED);
}

void placeOrder(ENUM_ORDER_TYPE orderType, double offset, double volume)
  {
//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- parameters to place a pending order
   request.action    = TRADE_ACTION_PENDING;                             // type of trade operation
   request.symbol    = Symbol();                                         // symbol
   request.volume    = volume;                                              // volume of 0.1 lot
   request.deviation = 200;                                                // allowed deviation from the price
   request.magic     = EXPERT_MAGIC;                                     // MagicNumber of the order

   double price;                                                       // order triggering price
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);                // value of point
   int digits=SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);                // number of decimal places (precision)
   MqlDateTime end;
   TimeToStruct(TimeCurrent(),end);
   end.hour += 1;
   
   //--- checking the type of operation
   if(orderType==ORDER_TYPE_BUY_LIMIT)
     {
      request.type     =ORDER_TYPE_BUY_LIMIT;                          // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;        // price for opening 
      request.price    =NormalizeDouble(price,digits);                 // normalized opening price 
     }
   else if(orderType==ORDER_TYPE_SELL_LIMIT)
     {
      request.type     =ORDER_TYPE_SELL_LIMIT;                          // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point;         // price for opening 
      request.price    =NormalizeDouble(price,digits);                  // normalized opening price 
     }
   else if(orderType==ORDER_TYPE_BUY_STOP)
     {
      request.type =ORDER_TYPE_BUY_STOP;                                // order type
      price        =SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point; // price for opening 
      request.price=NormalizeDouble(price,digits);                      // normalized opening price 
      request.sl   =NormalizeDouble(price - (offset*2*point),digits); 
      ArrowedLineCreate(0,"ntbuy", 0, StructToTime(end), price, TimeCurrent(), price, clrGreen);
     }
   else if(orderType==ORDER_TYPE_SELL_STOP)
     {
      request.type     =ORDER_TYPE_SELL_STOP;                           // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID)-offset*point;         // price for opening 
      request.price    =NormalizeDouble(price,digits);                  // normalized opening price 
      request.sl   =NormalizeDouble(price + (offset*2*point),digits); 
      ArrowedLineCreate(0,"ntsell", 0, StructToTime(end), price, TimeCurrent(), price, clrRed);
    }
   else Alert("This example is only for placing pending orders");   // if not pending order is selected
//--- send the request
 /*  if(!OrderSend(request,result)) {
      PrintFormat("OrderSend error %d",GetLastError());                 // if unable to send the request, output the error code
     }
     */
//--- information about the operation
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }

bool ArrowedLineCreate(const long            chart_ID=0,         // chart's ID 
                       const string          name="ArrowedLine", // line name 
                       const int             sub_window=0,       // subwindow index 
                       datetime              time1=0,            // first point time 
                       double                price1=0,           // first point price 
                       datetime              time2=0,            // second point time 
                       double                price2=0,           // second point price 
                       const color           clr=clrRed,         // line color 
                       const ENUM_LINE_STYLE style=STYLE_SOLID,  // line style 
                       const int             width=1,            // line width 
                       const bool            back=false,         // in the background 
                       const bool            selection=true,     // highlight to move 
                       const bool            hidden=true,        // hidden in the object list 
                       const long            z_order=0)          // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
   ChangeArrowedLineEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create an arrowed line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROWED_LINE,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create an arrowed line! Error code = ",GetLastError()); 
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
//+------------------------------------------------------------------+ 
//| Check anchor points' values and set default values               | 
//| for empty ones                                                   | 
//+------------------------------------------------------------------+ 
void ChangeArrowedLineEmptyPoints(datetime &time1,double &price1, 
                                  datetime &time2,double &price2) 
  { 
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1) 
      time1=TimeCurrent(); 
//--- if the first point's price is not set, it will have Bid value 
   if(!price1) 
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2) 
     { 
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10]; 
      CopyTime(Symbol(),Period(),time1,10,temp); 
      //--- set the second point 9 bars left from the first one 
      time2=temp[0]; 
     } 
//--- if the second point's price is not set, it is equal to the first point's one 
   if(!price2) 
      price2=price1; 
  } 

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   // if we have not initialize yet, work out the current seconds, this will be done when market is actuvely ticking
   if ( countdown == 999 ) {
       MqlDateTime now;
       TimeToStruct(TimeCurrent(),now);
       countdown = 55 - now.sec;
       Print( "Countdown is : ", countdown, " @ ", TimeToString( TimeCurrent() , TIME_MINUTES|TIME_SECONDS ) );
   }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
     MqlDateTime now;
     TimeToStruct(TimeCurrent(),now);

   // if we have not initialize yet, work out the current seconds, this will be done when market is actuvely ticking
   // then compute the number of seconds until the 55th of the minute, and set countdown to this many seconds
   // when countdown is 0 orders will be placed
   if ( countdown > 0 && countdown < 999 ) {
      countdown--;
      Print( "Countdown is : ", countdown, " @ ", TimeToString( TimeCurrent() , TIME_MINUTES|TIME_SECONDS ) );
      if ( countdown == 0 ) {
         EventKillTimer();
         Print( "Countdown is : ", countdown, " @ ", TimeToString( TimeCurrent() , TIME_MINUTES|TIME_SECONDS ) );

         double atr = iATR( Symbol(), Period(), 5 );
         double LegSize = MinLegSize; // MathMax(atr * ATRMultiplier, MinLegSize);
         
         // assuming we can price our volume in Rands as per Futures Trader, the volume is simply
         // the amount to risk in Rands divided by the number of pips risked 
         long volume = Risk / (LegSize * 2);
      
         placeOrder(ORDER_TYPE_BUY_STOP, LegSize, 1);
         placeOrder(ORDER_TYPE_SELL_STOP, LegSize, 1);
      }
    }
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
