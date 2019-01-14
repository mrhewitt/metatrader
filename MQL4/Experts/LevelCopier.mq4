//+------------------------------------------------------------------+
//|                                                  LevelCopier.mq4 |
//|                                      Copyright 2018, Mark Hewitt |
//|                                     https://www.markhewitt.co.za |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Mark Hewitt"
#property link      "https://www.markhewitt.co.za"
#property version   "1.00"
#property strict

#include <stderror.mqh> 
#include <stdlib.mqh> 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   flushOtherCharts();
   fullCopy();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
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
   switch ( id ) {
      case CHARTEVENT_OBJECT_CREATE:
      case CHARTEVENT_OBJECT_CHANGE:
      case CHARTEVENT_OBJECT_DRAG:
         copy(sparam);
         break;
      case CHARTEVENT_OBJECT_DELETE:
         remove(sparam);
         break;

   }
  }
//+------------------------------------------------------------------+

void copy(string name) {
   long type = ObjectType(name);
   switch ( type ) {
      case OBJ_HLINE: copyHLine(name); break;
      case OBJ_TREND: copyTLine(name); break;
   }
}

void remove(string name) {
   long type = ObjectType(name);
   if ( type == OBJ_HLINE || type == OBJ_TREND ) { 
      long cid = ChartFirst();
      while ( cid != -1 ) {
         if ( cid != ChartID() ) {
            ObjectDelete(cid,name);
         }
         ChartRedraw(cid);
         cid = ChartNext(cid);
      }
   }
}

void flushOtherCharts() {
   long cid = ChartFirst();
   while ( cid != -1 ) {
      if ( cid != ChartID() ) {
        ObjectsDeleteAll(cid,0,OBJ_HLINE); 
        ObjectsDeleteAll(cid,0,OBJ_TREND); 
      }
      ChartRedraw(cid);
      cid = ChartNext(cid);
   }
}

void fullCopy() {
   for ( int i=0; i < ObjectsTotal(); i++ ) {
      copy(ObjectName(i));
   }
}

void copyHLine(string name) {
   
   // if not new and line is not a HLC (copied) line ignore this object, we dont copy lines from other indicators
   bool is_new = (StringFind(name,"Horizontal Line",0) == 0);
   if ( !is_new && StringFind(name,"HLC",0) < 0 ) { return; }   
   string newName = ( is_new ? "HLC-"+TimeToString(TimeCurrent())+"-"+(string)MathRand() : name );
   
   long cid = ChartFirst();
   while ( cid != -1 ) {
      if ( cid != ChartID() ) {
         // if new or it does not exist on target chart, create
         if ( is_new || ObjectFind(cid,name) < 0 ) {
            // default uncopied line, create it then set attrs           
            ObjectCreate(cid,newName,OBJ_HLINE,0,0,ObjectGet(name,OBJPROP_PRICE1));
         }
         // already copied line, just update its attrs
         updateHLine(cid,newName);
         ChartRedraw(cid);
      }      
      cid = ChartNext(cid);
   }

   // give the object on the page   
   if ( is_new ) { ObjectSetString(ChartID(),name,OBJPROP_NAME,newName); }
}

void updateHLine(long cid, string name) {   
   ObjectSet(name, OBJPROP_PRICE1, ObjectGet(name,OBJPROP_PRICE1)); 
   //--- set color
   ObjectSetInteger(cid,name,OBJPROP_COLOR,ObjectGetInteger(0,name,OBJPROP_COLOR));
   //--- set the style of line
   ObjectSetInteger(cid,name,OBJPROP_STYLE,ObjectGetInteger(0,name,OBJPROP_STYLE));
   //--- set width of the line
   ObjectSetInteger(cid,name,OBJPROP_WIDTH,ObjectGetInteger(0,name,OBJPROP_WIDTH));
   ObjectSetInteger(cid,name,OBJPROP_TIMEFRAMES,ObjectGetInteger(0,name,OBJPROP_TIMEFRAMES));
}

void copyTLine(string name) {
  
   // if not new and line is not a TLC (copied) line ignore this object, we dont copy lines from other indicators
   bool is_new = (StringFind(name,"Trendline",0) == 0);
   if ( !is_new && StringFind(name,"TLC",0) < 0 ) { return; }   
   string newName = ( is_new ? "TLC-"+TimeToString(TimeCurrent())+"-"+(string)MathRand() : name );
   
   long cid = ChartFirst();
   while ( cid != -1 ) {
      if ( cid != ChartID() ) {
         // if new or it does not exist on target chart, create
         if ( is_new || ObjectFind(cid,name) < 0 ) {
            // default uncopied line, create it then set attrs           
            ObjectCreate(cid,newName,OBJ_TREND,0,(datetime)ObjectGet(name,OBJPROP_TIME1),ObjectGet(name,OBJPROP_PRICE1),ObjectGet(name,OBJPROP_TIME2),ObjectGet(name,OBJPROP_PRICE2));
         }
         // already copied line, just update its attrs
         updateTLine(cid,newName);
         ChartRedraw(cid);
      }      
      cid = ChartNext(cid);
   }

   // give the object on the page a new name 
   if ( is_new ) { ObjectSetString(ChartID(),name,OBJPROP_NAME,newName); }
}

void updateTLine(long cid, string name) {   
   ObjectSet(name, OBJPROP_TIME1, ObjectGet(name,OBJPROP_TIME1)); 
   ObjectSet(name, OBJPROP_TIME2, ObjectGet(name,OBJPROP_TIME2)); 
   ObjectSet(name, OBJPROP_PRICE1, ObjectGet(name,OBJPROP_PRICE1)); 
   ObjectSet(name, OBJPROP_PRICE2, ObjectGet(name,OBJPROP_PRICE2)); 
   
   //--- set color
   ObjectSetInteger(cid,name,OBJPROP_COLOR,ObjectGetInteger(0,name,OBJPROP_COLOR));
   //--- set the style of line
   ObjectSetInteger(cid,name,OBJPROP_STYLE,ObjectGetInteger(0,name,OBJPROP_STYLE));
   //--- set width of the line
   ObjectSetInteger(cid,name,OBJPROP_WIDTH,ObjectGetInteger(0,name,OBJPROP_WIDTH));
   ObjectSetInteger(cid,name,OBJPROP_TIMEFRAMES,ObjectGetInteger(0,name,OBJPROP_TIMEFRAMES));
}