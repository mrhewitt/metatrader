//+------------------------------------------------------------------+
//|                                                    TheMarket.mq5 |
//|                                      Copyright 2018, Mark Hewitt |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Mark Hewitt"
#property link      "https://www.mql5.com"
#property version   "1.00"



string signals[] = 
{
	//	[symbol] [LONG|SHORT] [open type] [rules]  
	//    where open type is
	//		OPEN - start of days trade (no positions opened if there is already one)
	//		@ [price] - limit/stop at set price
	//		CLOSE [price] - trade at open if prev day closed above/below given price
	// 	  where rules are in format
	//		[action] [type] [price]
	//
	//	 actions are:
	//		TP - take profit
	//		SL - stop loss
	//      1D - exit on break of 1 day high/low
	// 		2D - exit on break of 2 day high/low
	//		BE - go to break even
	//
	//	 types are:
	//		CLOSE - aplly rule if previous day closed above/below price (with exception of SL, where the SL becomes break of the high/low to prevent being stopped out on bars the instant retrace)
	//		@     - on touch of the price level
	
    // /*AVI*/     "AVI",
    // /*Anggold*/ "",
    // /*angplat*/ "AMS",
    // /*anglo*/   "ANG",
    // /*Aspen*/   "APN LONG OPEN TP @ 27080 TP @ 26670 BE @ 26100 SL CLOSE 23850 2D @ 26300 1DL @ 26670",
    // /*assore*/  "",
    // /*barlow*/  "BAR",
    // /*bats*/    "BAT",
    // /*billiton*/"BIL",
    // /*brait*/   "",
    // /*capitec*/ "",
    // /*clicks*/  "CKS",
    // /*dischem*/ "",
    // /*discvry*/ "DSC",
    // /*firstrd*/ "FSR",
    // /*glencor*/ "",
    // /*imperia*/ "",
    // /*implats*/ "",
    // /*invplc*/  "",
    // /*kumba*/   "",
    // /*mondi*/   "",
    // /*mrprice*/ "",
    // /*mtn*/     "",
    // /*naspers*/ "",
    // /*netcare*/ "",
    // /*newgold*/ "",
    // /*omutual*/ "",
    // /*pnp*/     "",
    // /*ppc*/     "PPC",
    // /*psg*/     "PSG",
    // /*reinet*/  "",
    // /*remgro*/  "",
    // /*richmont*/"",
    // /*sanlam*/  "",
       /*SAPPI  */ "SAP LONG 21000 SL @ 20000 TP @ 22000 TP @ 24000 BE @ 21500 1D ABOVE 21200 2D ABOVE 21100",
    // /*sasol*/   "",
    // /*shoprit*/ "",
    // /*south32*/ "",
    // /*stanbank*/"",
    // /*steinnv*/ "",
    // /*telkom*/  "",
    // /*tfg*/     "",
    // /*tigbrans*/"",
    // /*truworth*/"",
    // /*vodacom*/ "",
    // /*woolies*/ "",

}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
