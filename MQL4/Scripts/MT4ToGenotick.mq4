//+------------------------------------------------------------------+
//|                                                MT4ToGenotick.mq4 |
//|                                      Copyright 2019, Mark Hewitt |
//|                                     https://www.markhewitt.co.za |
//|                                                                  |
//| Dumps all history for current period into a CSV format for       | 
//| use with the Genotick AI (http://genotick.com)                   |
//|                                                                  |
//| Note this does not reverse data this is best done with Genoticks |
//| reverse feature to ensure best compatibility                     |
//| java -jar genotick.jar reverse=[csvfilename]                     |
//|                                                                  |
//| Works in MT5 as well, simply rename file as MT4ToGenotick.mq5    |
//| and compile in your Metaeditor if the file does not appear in    |
//| in your MT5 navigator on its own                                 |
//+------------------------------------------------------------------+

#property copyright "Copyright 2019, Mark Hewitt"
#property link      "https://www.markhewitt.co.za"
#property version   "0.1"
#property strict
#property script_show_inputs
//--- input parameters

input string   PATH = "=== Output will be [DataDir]\\MQL4\\Files ===";
input string   FILE = "=== Default to SYMBOL-PERIOD.csv ===";
input string   FileName;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      Comment("Loading...");
      Comment(exportBars());
      
  }
//+------------------------------------------------------------------+


string exportBars() {
   MqlRates prices[];
   ArraySetAsSeries(prices,true);
   int maxBars= MathMin(TerminalInfoInteger(TERMINAL_MAXBARS),100000);
   int bars=CopyRates(Symbol(),Period(),0,maxBars,prices);
   string fileName = ( FileName != "" ? FileName : Symbol() + "-" + PeriodName(Period()) + ".csv" );
   string comment="";
   if ( bars > 1 ) {
      int fh = FileOpen(fileName,FILE_WRITE|FILE_CSV,",");
      for ( int i = bars-1; i >= 0; i-- ) {
         string date = TimeToString(prices[i].time,TIME_DATE);
         StringReplace(date, ".", "" );
         if ( Period() < PERIOD_D1 ) {
            string time = TimeToString(prices[i].time,TIME_MINUTES);
            StringReplace( time, ":", "" );
            date += time + "00";
         }
         FileWrite( fh,
                    date,
                    prices[i].open,
                    prices[i].high,
                    prices[i].low,
                    prices[i].close
                  );
      }
      FileFlush(fh);
      FileClose(fh);
      return ( "Exported: "+fileName+", "+IntegerToString(bars)+" bars" );
   }
   else {
      return ( "Error with exporting: "+fileName );
   }
}


string PeriodName(int period) {
   switch(period) {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_D1: return "D";
      case PERIOD_W1: return "W";
      case PERIOD_MN1: return "MN";
   }
   return "Custom";
}