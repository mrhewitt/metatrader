//+------------------------------------------------------------------+
//|                                                 SaneFXTrader.mq4 |
//|                  Copyright © 2009, Powerful Internet Enterprises |
//|                                          http://forex.my-pie.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Powerful Internet Enterprises"
#property link      "http://forex.my-pie.biz"

#include "../Include/detectXXX.mqh"
#include "../Include/TradeFunctions.mqh"
#include "../Include/stdlib.mqh"

int Losses = 2;
string TradeHeader = "TMAKER";

double Balances[4];

int accountType = 0;         // account index into Symbols/Balances to put current trade onto
int risks_used = 0;         // number of risks trade was taken on
double sl_used = 0;        // stop loss size in pips used

bool initVariables = true;
bool hasNewBar = false;
datetime previousBar ;
string buttonID = "button";
string buttonClr = "buttonclr";
string buttonBE = "buttonbe";
string buttonTrade = "buttontrade";
string buttonInfo = "btninfo";

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   int btnLeft = 5;
   int btnSpace = 55;
   
//----
//--- Create a button to send custom events
   button( buttonID, "Lines", btnLeft );   
   btnLeft += btnSpace;
   
   button( buttonClr, "Clear", btnLeft );   
   btnLeft += btnSpace;

   button( buttonBE, "BE", btnLeft );   
   btnLeft += btnSpace;
   
   button( buttonTrade, "Trade", btnLeft );
   btnLeft += btnSpace;

   button( buttonInfo, "X", btnLeft, 12 );
        
   ObjectCreate("symbol",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("symbol",OBJPROP_XDISTANCE,250);
   ObjectSet("symbol",OBJPROP_YDISTANCE,0);
   ObjectSetText("symbol","");
        
   ObjectCreate("tradesopen",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("tradesopen",OBJPROP_XDISTANCE,350);
   ObjectSet("tradesopen",OBJPROP_YDISTANCE,0);
   ObjectSetText("tradesopen","");
   
   ObjectCreate("tradesopen2",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("tradesopen2",OBJPROP_XDISTANCE,605);
   ObjectSet("tradesopen2",OBJPROP_YDISTANCE,0);
   ObjectSetText("tradesopen2",""); 
   
   ObjectCreate("trend_m15",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_m15",OBJPROP_XDISTANCE,860);
   ObjectSet("trend_m15",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_m15","M15");   
    
   ObjectCreate("trend_h1",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_h1",OBJPROP_XDISTANCE,885);
   ObjectSet("trend_h1",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_h1","H1"); 
      
   ObjectCreate("trend_h4",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_h4",OBJPROP_XDISTANCE,910);
   ObjectSet("trend_h4",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_h4","H4"); 
   
   ObjectCreate("trend_d1",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_d1",OBJPROP_XDISTANCE,930);
   ObjectSet("trend_d1",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_d1","D1");   
    
   ObjectCreate("trend_wk",OBJ_LABEL,0,NULL,NULL);
   ObjectSet("trend_wk",OBJPROP_XDISTANCE,950);
   ObjectSet("trend_wk",OBJPROP_YDISTANCE,0);
   ObjectSetText("trend_wk","WK");   
//----
   return(0);
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
  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   
//--- Check the event by pressing a mouse button
   if(id==CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject=sparam;
      
      if ( clickedChartObject == buttonInfo ) {
         printPairData();
         
        // 
       //  OrderClose(
         
         ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
         ChartRedraw();
      }
      
      //--- If you click on the object with the name buttonID
      if ( clickedChartObject == buttonID ) {
         if ( ObjectGetInteger(0,buttonID,OBJPROP_STATE) ) {
            showLines();
            ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
            ChartRedraw();
         }
      }
        
      if ( clickedChartObject == buttonClr ) {
         if ( ObjectGetInteger(0,buttonClr,OBJPROP_STATE) ) {
            cleanLines();
            showStats();
            ObjectSetInteger(0,buttonClr,OBJPROP_STATE,0);
            ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
            ChartRedraw();
         }
      }
      
      if ( clickedChartObject == buttonBE ) {
         goBreakEven(Symbol());
         ObjectSetInteger(0,buttonBE,OBJPROP_STATE,0);
         ChartRedraw();
      }
      
      if ( buttonTrade == clickedChartObject ) {
         if ( ObjectFind("entry") == 0 ) {
            if ( Bid > ObjectGet("entry", OBJPROP_PRICE1) ) {
               ObjectSetDouble(ChartID(),"entry",OBJPROP_PRICE1,Low[1]-symbolPoints(Symbol()));
               ObjectSetString(ChartID(),"entry",OBJPROP_NAME,"sell");
            } else {
               ObjectSetDouble(ChartID(),"entry",OBJPROP_PRICE1,High[1]+symbolPoints(Symbol()));
               ObjectSetString(ChartID(),"entry",OBJPROP_NAME,"buy");
            }
         } else {
            double sl = 0;
            double entry = 0;
            double tp = 0;
            double pip = symbolPoints(Symbol());
            string type = "";
            
            if ( isBearBar(Symbol(),Period(),1) ) {
               sl = findRecentHigh()+pip;
               entry = Low[1]-pip;
               type = "sell";
            } else {
               sl = findRecentLow()-pip;
               entry = High[1]+pip;
               type = "buy";
           }

            showLines(1,sl,entry);
            ObjectSetString(ChartID(),"entry",OBJPROP_NAME,type);
         }
         ObjectSetInteger(0,buttonTrade,OBJPROP_STATE,0);
         ChartRedraw();
      }
      
      return;
  }
  
   if ( id == CHARTEVENT_OBJECT_DRAG ) {
      showStats();
   }
   
   if (id == CHARTEVENT_CLICK) {
       if ( ObjectGetInteger(0,buttonID,OBJPROP_STATE) && dparam > 20 ) {
         datetime t;
         double p;
         int s;
         ChartXYToTimePrice(0,lparam,dparam,s,t,p);
         
         int i = 0;
         while ( iTime(Symbol(),Period(),i) != t && i < 10000 ) {
            i++;
         }
         
         PrintFormat("Time=%s  O=%G Bar=%d " + sparam,TimeToString(t),iOpen(Symbol(),Period(),i),i);
   
         if ( i < 10000 ) {
            showLines(i);
         }
       }
   }
   
   if ( id == CHARTEVENT_CHART_CHANGE ) {
      showTrends();
   }
}

void showLines(int shift=1, double sl = 0, double p = 0) {
   cleanLines();
   loadStatBalances();
   
   double tp;
   if ( p == 0 ) {      // only set entry price if not given
      if ( shift == 0 ) {
         p = Bid;
      } else {
         p = iOpen(Symbol(),Period(),shift-1);
      }
   }
   
   if ( iOpen(Symbol(),Period(),shift) > iClose(Symbol(),Period(),shift) ) {
      // bear  bar - short trade
     if ( sl == 0 ) {      // only set SL if not given
       sl = iHigh(Symbol(),Period(),shift) + symbolPoints(Symbol());
     }
     tp = p - ( (sl-p) * 1.5 );
    } else {
      // bull  bar - long trade
      if ( sl == 0 ) {      // only set SL if not given
         sl = iLow(Symbol(),Period(),shift) - symbolPoints(Symbol());
      }
     tp = p + ( (p-sl) * 1.5 );
   }
   
   addLine("entry", p, clrSkyBlue );
   addLine("sl", sl, clrCrimson );
   addLine("tp", tp, clrLimeGreen );
   
   showStats();
   
  // ObjectSetInteger(0,buttonID,OBJPROP_STATE,0);
   ChartRedraw();// Forced redraw all chart objects
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
      ObjectDelete("tradesopen");
      ObjectDelete("symbol");
      ObjectDelete("tradesopen2");
      ObjectDelete("trend_h1");
      ObjectDelete("trend_h4");
      ObjectDelete("trend_d1");
      ObjectDelete("trend_wk");
      ObjectDelete(buttonID);
      ObjectDelete(buttonClr);

//----
   return(0);
  }
  
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
  
  if ( initVariables ) {
    initVariables = false;
    previousBar = iTime(Symbol(),Period(),0);
    loadStatBalances();
  }
  
  if ( newBar(previousBar,Symbol(),Period()) ) {
     loadStatBalances();
  } 
  
  showTrends();
  
   // if there are no open trades on this pair, check for a buy/sell line
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if ( OrderSymbol() == Symbol() ) {
         return(0); 
      }  
   }
   
   if ( ObjectFind("sl") == 0 ) {
   
      showStats();
   
      // if we have a pending order, we can trade if the price is between the SL and order price
      if ( ObjectFind("pending") == 0 ) {
         double sl = ObjectGet("sl", OBJPROP_PRICE1);
         double price = ObjectGet("pending", OBJPROP_PRICE1);
         if ( price > sl && sl < Bid && Bid <= price ) {
            ObjectDelete("pending");
            ObjectDelete("buy");       // cleanup in case ...
            ObjectCreate("buy", OBJ_HLINE, 0, TimeCurrent(), price);
         } else if ( price < sl && sl > Bid && Bid >= price ) {
            ObjectDelete("pending");
            ObjectDelete("sell");         // cleanup in case ...
            ObjectCreate("sell", OBJ_HLINE, 0, TimeCurrent(), price);
         } 
      }
   
      // buy line, enter trade if price is on or above the line
      if ( ObjectFind("buy") == 0 ) {
         if ( Bid >= ObjectGet("buy", OBJPROP_PRICE1) ) {
            if ( tradeBalances(OP_BUY) ) {
               ObjectDelete("buy");
               ObjectDelete("sl");
               ObjectDelete("tp");
            }
         } else {
            ObjectSetText("buy", "Stop Size: " + DoubleToString((ObjectGet("sl", OBJPROP_PRICE1) - ObjectGet("sell", OBJPROP_PRICE1))/symbolPoints(Symbol()),1) );
         }
     }
   
      if ( ObjectFind("sell") == 0 ) {
         if ( Bid <= ObjectGet("sell", OBJPROP_PRICE1) ) {
            if ( tradeBalances(OP_SELL) ) {
               ObjectDelete("sell");
               ObjectDelete("sl");
               ObjectDelete("tp");
            }
        } else {
            ObjectSetText("sell", "Stop Size: " + DoubleToString((ObjectGet("sl", OBJPROP_PRICE1) - ObjectGet("sell", OBJPROP_PRICE1))/symbolPoints(Symbol()),1) );
         }
      }
      
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void cleanLines() {
   ObjectDelete("pending");
   ObjectDelete("inactive buy");
   ObjectDelete("inactive sell");
   ObjectDelete("buy");
   ObjectDelete("sell");
   ObjectDelete("sl");
   ObjectDelete("tp");
   ObjectDelete("entry");
   ObjectDelete("BREAKEVEN");
}

void addLine( string name, double price, const color clr = clrWhiteSmoke, const ENUM_LINE_STYLE style=STYLE_DASHDOT ) {
   ObjectCreate(name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
}

void showTrends() {  
   updateTrend("trend_m15",PERIOD_M15);
   updateTrend("trend_h1",PERIOD_H1);
   updateTrend("trend_h4",PERIOD_H4);
   updateTrend("trend_d1",PERIOD_D1);
   updateTrend("trend_wk",PERIOD_W1);
}

void updateTrend(string label, int period) {
   int trend = detectTrend(Symbol(),period);
   if ( trend != TRADE_ARROW_NONE ) {
      drawTrendLabel(label,trend,true);
   } else {
      drawTrendLabel(label,detect50(Symbol(),period),false);
   }
   
   int width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   ObjectSet("trend_m15",OBJPROP_XDISTANCE,width-190); 
   ObjectSet("trend_h1",OBJPROP_XDISTANCE,width-158); 
   ObjectSet("trend_h4",OBJPROP_XDISTANCE,width-137); 
   ObjectSet("trend_d1",OBJPROP_XDISTANCE,width-115); 
   ObjectSet("trend_wk",OBJPROP_XDISTANCE,width-95); 
}

void drawTrendLabel(string label, int trend, bool supa) {
   if ( trend == TRADE_ARROW_BUY ) {
      ObjectSetInteger(0,label,OBJPROP_COLOR,clrLime);
   } else {
      ObjectSetInteger(0,label,OBJPROP_COLOR,clrCrimson);
   }
   if ( supa ) {
      ObjectSetString(0,label,OBJPROP_FONT,"Arial Black");
   } else {
      ObjectSetString(0,label,OBJPROP_FONT,"Arial");
   }
}

void showStats() {
 
   double price = 0;
   double rate = Bid;
   double tp = 0;
   
   if ( ObjectFind("sl") != 0 ) {
      ObjectSetText("tradesopen","",NULL,"Arial",White); 
      ObjectSetText("tradesopen2","",NULL,"Arial",White); 
      return;
   }
   
   double sl = ObjectGet("sl", OBJPROP_PRICE1);
   if ( ObjectFind("pending") == 0 ) {
      double p = ObjectGet("pending", OBJPROP_PRICE1);
      if ( p > sl ) {
         // pending buy, so must buy from the ask line when cpmputing lots
         rate = p + (Ask-Bid);
      } else {
         rate = p;
      }
   }
   
   if ( ObjectFind("buy") == 0 ) {
        double p = ObjectGet("buy", OBJPROP_PRICE1);
        if ( p > Bid ) {
          rate = (Ask-Bid) + p;
        } else {
           rate = Ask;
        }
     
    }
    else  if ( ObjectFind("sell") == 0  ) {

         double p = ObjectGet("sell", OBJPROP_PRICE1);
         if ( p < Bid ) {
          rate =  p;
        } else {
           rate = Bid;
        }

      
   } else if ( ObjectFind("entry") == 0 ) {
       double p = ObjectGet("entry", OBJPROP_PRICE1);
      if ( ObjectGet("tp", OBJPROP_PRICE1) > ObjectGet("sl", OBJPROP_PRICE1) ) {         
          rate = (Ask-Bid) + p;
     } else {
          rate = p;
     } 
   } 
    
    if ( ObjectFind("tp") == 0 ) {
      tp = ObjectGet("tp", OBJPROP_PRICE1);
    } else {
        if ( rate > sl ) {
           tp = rate + (MathAbs(rate - sl)*1.5);
        } else {
           tp = rate - (MathAbs(rate - sl)*1.5);
       }
    }
    
   // if no order or sell then we just assume the Bid rate 
   
   double points = symbolPoints(Symbol());
   double stoploss = MathAbs(rate - sl) / points;   
   double takeprofit = 0;
   double rr = 0;
   double lots = 0;
   double balance = 0;
   double loss = 0;
   double profit = 0;
   
   int account = accountForTrade(Symbol());
   if ( account != -1 ) {
      lots = GetLots(stoploss);
      balance = Balances[account];
      loss = getTradeValue(stoploss, lots);
      if ( tp > 0 ) {
         takeprofit =  MathAbs(rate - tp) / points;
         profit = getTradeValue(takeprofit, lots);
         rr = takeprofit/stoploss;
      }
   }
  
   string s = "(" + DoubleToStr(symbolPoints(Symbol()),4) + " x $" + DoubleToStr(tickValue()/10,2) + ")";  // show tick value as 0.01 lots
   ObjectSetText("symbol",s,NULL,"Arial",White);
    
   string t = "$" + DoubleToStr(balance,2) + "; L: " + DoubleToStr(lots,2) + "; SL: " + DoubleToStr(stoploss,0) + "; Loss: $" + DoubleToStr(loss,2); 
   ObjectSetText("tradesopen",t,NULL,"Arial",White);
   if ( tp > 0 ) {
      t = " TP: " + DoubleToStr(takeprofit,2) + "; P: $" + DoubleToStr(profit,2) + "; R: " + DoubleToStr(rr,1) + ":1";
      ObjectSetText("tradesopen2",t,NULL,"Arial",White);
   } else {
       ObjectSetText("tradesopen2","",NULL,"Arial",White);
  }
}


bool goLong(double deduct_lots = 0)
{
   double points = symbolPoints(Symbol());
   double stopPrice = ObjectGet("sl", OBJPROP_PRICE1);
   double stoploss = MathAbs(Ask - stopPrice) / points;
   double takeProfit = Ask + (stoploss*1.5*points);
   double breakEven = Ask + (stoploss*1*points);

   // if there is a TP line then adjust the TP to be the set level rather than fixed amount
   if ( ObjectFind("tp") == 0 ) {
      takeProfit = ObjectGet("tp", OBJPROP_PRICE1);
   }

   RefreshRates();
   while(IsTradeContextBusy() ) Sleep(100);
   double lots = GetLots(stoploss) - deduct_lots;
   if ( lots > 0 ) {    
     // Print("Trading: ",stopPrice, " ; ", takeProfit);
      int result = OrderSend(Symbol(), OP_BUY, lots, Ask, 0, stopPrice, takeProfit, getComment(), accountType+1, 0, Green); 
      if ( result < 0 ) {
         int err = GetLastError();
         if ( err == ERR_REQUOTE ) {
            // on a requote let it try again on the next tick
            return false;
         } else {
            // some other error (which will appear in journal, permanent failure so return true
            // to ensure the trade lines are removed so we dont keep trying
            Print("Failed to go LONG on ", Symbol()," : ",ErrorDescription(err));
            return true;
         } 
      }
      Print(getComment());
      ObjectCreate("BREAKEVEN", OBJ_HLINE, 0, TimeCurrent(), breakEven);
   } else {
      Print( "Cannot go LONG, no valid accounts for ", Symbol());
   }
   
   // permanent failure or success, flag the trade lines must be removed
   return true;
}

bool goShort(double deduct_lots = 0)
{
   double points = symbolPoints(Symbol());
   double stopPrice = ObjectGet("sl", OBJPROP_PRICE1) + (Ask-Bid);
   double stoploss = MathAbs(stopPrice - Bid) / points;
   double takeProfit = Bid - (stoploss*1.5*points);
   double breakEven = Bid - (stoploss*1*points);

   // if there is a TP line then adjust the TP to be the set level rather than fixed amount
   if ( ObjectFind("tp") == 0 ) {
      takeProfit = ObjectGet("tp", OBJPROP_PRICE1);
   }
   
   RefreshRates();
   while(IsTradeContextBusy() ) Sleep(100);
   double lots = GetLots(stoploss) - deduct_lots;
   if ( lots > 0 ) {
      int result = OrderSend(Symbol(), OP_SELL, lots, Bid, 0, stopPrice, takeProfit, getComment(), accountType+1, 0, Red); 
      if ( result < 0 ) {
         int err = GetLastError();
         if ( err == ERR_REQUOTE ) {
            // on a requote let it try again on the next tick
            return false;
         } else {
            // some other error (which will appear in journal, permanent failure so return true
            // to ensure the trade lines are removed so we dont keep trying
            Print("Failed to go LONG on ", Symbol());
            return true;
         } 
      }
      Print(getComment());
      ObjectCreate("BREAKEVEN", OBJ_HLINE, 0, TimeCurrent(), breakEven);
   } else {
      Print( "Cannot go SHORT, no valid accounts for ", Symbol() );
   }
   
   // permanent failure or success, flag the trade lines must be removed
   return true;
}

void loadStatBalances() {
   int handle;
   handle=FileOpen("balances.csv",FILE_CSV|FILE_READ,';');
   if(handle<1)
   {
      Print("Cannot load balances for Stats, the last error is ", GetLastError());
      return;
   }
   
   TradeHeader = FileReadString(handle);                   // trade account name
   Losses = StringToInteger( FileReadString(handle) );                        // risks to apply to this account
   Balances[0] = StrToDouble( FileReadString(handle) );    // 1
   Balances[1] = StrToDouble( FileReadString(handle) );    // 2
   Balances[2] = StrToDouble( FileReadString(handle) );    // 3
   Balances[3] = StrToDouble( FileReadString(handle) );    // 4
   FileClose(handle);
}

bool tradeBalances(int trade) {
   int handle;
   handle=FileOpen("balances.csv",FILE_CSV|FILE_READ,';');
   if(handle<1)
   {
      Print("Cannot load trade balances, the last error is ", GetLastError());
      return(false);
   }
   
   TradeHeader = FileReadString(handle);                   // trade account name
   while ( TradeHeader != "END" ) {
      Losses = StringToInteger(FileReadString(handle));                        // risks to apply to this account
      Balances[0] = StrToDouble( FileReadString(handle) );    // 1
      Balances[1] = StrToDouble( FileReadString(handle) );    // 2
      Balances[2] = StrToDouble( FileReadString(handle) );    // 3
      Balances[3] = StrToDouble( FileReadString(handle) );    // 4
      Print ("Account ",TradeHeader, "; Risk ", Losses, "; Balances: $", Balances[0]," , $",Balances[1]," , $",Balances[2]," , $",Balances[3]);
      if ( trade == OP_BUY ) {
         if ( !goLong() ) {
            return false;
         }
      } else {
         if ( !goShort() ) {
            return false;
         }
      }
      
      TradeHeader = FileReadString(handle);                   // trade account name
   }
   FileClose(handle);
   
   return (true);
   
//   Print( "Balanced: M:", TradableBalance, "; U:",USD, "; E:",EUR, "; G:",GBP, "; J:",JPY, "; A:",AUD, "; F:",Futures, "; C:",Commodities );
}

string getComment() {
   return (TradeHeader + ";" + IntegerToString(accountType+1) + "; $" + DoubleToStr(Balances[accountType],2));
}

double GetLots( double stopLoss ) { 

   accountType = accountForTrade(Symbol());
   if ( accountType != -1 ) {
      sl_used = stopLoss;
      risks_used = Losses;
      return (getLotsForBalance(stopLoss,accountType,Losses));
   }
   
   return (0);
}

double getLotsForBalance( double stopLoss, int account, int risk ) {
   double lots;
   double balance = Balances[account];

   lots = (MathFloor( (balance/(risk*stopLoss*tickValue()))*10 ) / 10) / 10;
   if ( lots < 0.01 ) { lots = 0.01; }
  
  Print (tickValue(), " ; ", MathFloor( (balance/(risk*stopLoss*tickValue()))*10 ));
   Print( ": Lots ", lots, " with SL ", stopLoss , " and balance ", balance );
   return (lots);
}

int accountForTrade(string symbol) {

   // ugly code, filter out the accounts that are not available for trading
   // by simply setting their balance to 0, Balances is reloaded each time
   // so this does not future trades
   // we dont do this if risks > 8 as these are large accounts handling multiple simultaneous trades on one balance
   if ( Losses <= 8 ) {
      for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
      {
         if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
         if ( OrderComment() != "" ) {
            string c[];
            StringSplit(OrderComment(),';',c);
            if ( c[0] == TradeHeader ) {
              Balances[ StringToInteger(c[1]) - 1 ] = 0;     // accounts number 1,2.. in comment not zero-based
            }
            /*if ( OrderMagicNumber() > 0 ) {
               Balances[ OrderMagicNumber() - 1 ] = 0;     // accounts number 1,2.. in magic number not zero-based
            }*/
         }
      }
   }
   
   // now we trade on the account that has the highest balance
   // so loop through the list and pick the best one
   double max = 0;
   int account = -1;
   for ( int i = 0; i < ArraySize(Balances); i++ ) {
      if ( Balances[i] > max ) {
         max = Balances[i];
         account = i;
      }
   }

   return (account);      // cannot find a valid account
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
