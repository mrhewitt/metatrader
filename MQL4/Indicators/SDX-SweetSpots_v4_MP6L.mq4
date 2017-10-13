//+----------------------------------------------------------------------------------+
//|                                                   SweetSpots.mq4                 |
//|                                                                                  |
//|                                                                                  |
//+----------------------------------------------------------------------------------+
#property copyright "Copyright Shimodax"
#property link      "http://www.strategybuilderfx.com"

/*------------------------------------------------------------------------------------
SDX-SweetSpots_v2:

Flexibility in line styles is increased.  You can now select to make the lines Solid,
Dash, Dot, or DashDotDot.  And when selecting Solid lines, you can select thickness.

SDX-SweetSpots_v3:

This upgrade allows users to "turn off" the sub-lines, while retaining their settings.

SDX-SweetSpots_v4:

This upgrade does away with the two fixed levels at the whole and half numbers, and
allows the user to input up to four different levels of choice.  By default, the 
first level is set to the whole number (input "0"), the second level is set to the
half number (input "50"), the third level is set to the quarter (input "25") and the
fourth level is set to three-quarters (input "75").  The user can change these.
The user can select for each line the line style, line thickness (for solid lines),
and the line color.  And now each line can be separately toggled on/off with the
"true/false" switch.  The Range selection feature recognizes that the current price
is in a base range bounded by upper and lower whole numbers.  A selection of "0" for 
"RangesAboveBelowBaseRange" will fill out this base range with the selected lines.
A selection of "1" for "RangesAboveBelowBaseRange" will also add a full range of the
lines both above and below the base range.  A selection of "2" will place two full
ranges of lines above and below the base range, etc.  As the price crosses whole 
number lines, the indicator appropriately deletes old and adds new ranges of lines.

                                                    -  Traderathome, November 23, 2008
SDX-SweetSpots_v4_MP6L:

MP6L = MultiPlatform - 6 levels
Addition of the code for the indicator to also work with platforms that have unconventional
Point digits number (0.00001 and 0.001).

Addition of two customizable line levels (default 66 and 33) as these are places where price 
usually stops and bounces.

                                                     -  Doblece, December 3, 2008
                                                    
                                                    
--------------------------------------------------------------------------------------*/  

#property indicator_chart_window

extern int   RangesAboveBelowBaseRange  = 1;

extern color FirstLineColor             = Red;
extern bool  FirstLineOn                = true;
extern int   FirstLine0s_orEnd2Digits   = 0;
extern int   FirstLineStyle_01234       = 0;
extern int   FirstLineSolidThickness    = 1;

extern color SecondLineColor            = Red;
extern bool  SecondLineOn               = true;
extern int   SecondLineEnd2Digits       = 50;
extern int   SecondLineStyle_01234      = 2;
extern int   SecondLineSolidThickness   = 0;

extern color ThirdLineColor             = DarkOrange;
extern bool  ThirdLineOn                = true;  
extern int   ThirdLineEnd2Digits        = 20;
extern int   ThirdLineStyle_01234       = 2;
extern int   ThirdLineSolidThickness    = 0;

extern color FourthLineColor            = DarkOrange;
extern bool  FourthLineOn               = true;
extern int   FourthLineEnd2Digits       = 80;
extern int   ForthLineStyle_01234       = 2;
extern int   ForthLineSolidThickness    = 0;

extern color FifthLineColor             = CornflowerBlue;
extern bool  FifthLineOn                = true;
extern int   FifthLineEnd2Digits        = 66;
extern int   FifthLineStyle_01234       = 2;
extern int   FifthLineSolidThickness    = 0;

extern color SixthLineColor             = CornflowerBlue;
extern bool  SixthLineOn                = true;
extern int   SixthLineEnd2Digits        = 33;
extern int   SixthLineStyle_01234       = 2;
extern int   SixthLineSolidThickness    = 0;


double Poin;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{ 
//Checking for unconventional Point digits number
   if (Point == 0.00001) Poin = 0.0001; //5 digits
   else if (Point == 0.001) Poin = 0.01; //3 digits
   else Poin = Point; //Normal
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  
{
   int obj_total= ObjectsTotal();  
   for (int i= obj_total; i>=0; i--) 
      {
      string name= ObjectName(i);    
          if (StringSubstr(name,0,11)=="[SweetSpot]")
          {
          ObjectDelete(name);
          }
      }  
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;     
   // no need to update these buggers too often   
      // if (CurTime()-timelastupdate < 5 && Period()==lasttimeframe) return (0); 
   // Perform update    
   int obj_total= ObjectsTotal();  
   for (int k= obj_total; k>=0; k--) 
      {
      string name= ObjectName(k);    
          if (StringSubstr(name,0,11)=="[SweetSpot]")
          {
          ObjectDelete(name);
          }
      }    
   int i, ssp, ssp1; //choosing "int" instead of "double" drops decimal portion of value
   double linelevel, linestyle ,linewidth;
   color linecolor;
   ssp1= Bid; //Comment(ssp1); //equals bid w/o decimal portion
   ssp1= Bid / Poin; //Comment(ssp1); //Point operation restores all bid integers, but w/o the decimal  
   // Initialize user inputs of last 2 digit IDs of lines to be drawn 
   int u1 = FirstLine0s_orEnd2Digits;
   int u2 = SecondLineEnd2Digits;
   int u3 = ThirdLineEnd2Digits;
   int u4 = FourthLineEnd2Digits;
   int u5 = FifthLineEnd2Digits;
   int u6 = SixthLineEnd2Digits;
      
   int c1=ssp1%100;  //Comment(c1); //last 2 digits of control reference price/bid
   
   double LA, LB, LN; LN=100-c1; LB=c1; LA=LN; 
//if (c1<50)LB=c1;LA=LN;
//if (c1>+50)LB=c1;LA=LN;Comment(LB);
   ssp=ssp1; //start ssp at reference price/bid

   for (i= -((100*(RangesAboveBelowBaseRange))+LB); i<=((100*(RangesAboveBelowBaseRange))+LA); i++)   
      {
         ssp=ssp1+i;//Comment(i+"  "+ssp);
         c1=ssp%100; //Comment(c1);
         if (c1==u1 && FirstLineOn == true)
             {           
             linestyle = FirstLineStyle_01234;
             linecolor = FirstLineColor;
             linewidth = FirstLineSolidThickness;
             linelevel = ssp*Poin;
             }
          if (c1==u2 && SecondLineOn == true)
             {           
             linestyle = SecondLineStyle_01234;
             linecolor = SecondLineColor;
             linewidth = SecondLineSolidThickness;
             linelevel = ssp*Poin;
             }
          if (c1==u3 && ThirdLineOn == true)
             {           
             linestyle = ThirdLineStyle_01234;
             linecolor = ThirdLineColor;
             linewidth = ThirdLineSolidThickness;
             linelevel = ssp*Poin;
             }
         if (c1==u4 && FourthLineOn == true)
             {           
             linestyle = ForthLineStyle_01234;
             linecolor = FourthLineColor;
             linewidth = ForthLineSolidThickness;
             linelevel = ssp*Poin;
             }

         if (c1==u5 && FifthLineOn == true)
             {           
             linestyle = FifthLineStyle_01234;
             linecolor = FifthLineColor;
             linewidth = FifthLineSolidThickness;
             linelevel = ssp*Poin;
             }

         if (c1==u6 && FifthLineOn == true)
             {           
             linestyle = SixthLineStyle_01234;
             linecolor = SixthLineColor;
             linewidth = SixthLineSolidThickness;
             linelevel = ssp*Poin;
             }


         SetLevel(DoubleToStr(linelevel,Digits), linelevel,  linecolor, linestyle, linewidth, Time[10]);


      }
   return(0);
}
//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double linelevel, color linecolor, int linestyle, int linewidth, datetime startofday)
{
   int digits=Digits;  

   string linename= "[SweetSpot] " + text + " Line",pricelabel;   
   // create or move the horizontal line   
   if (ObjectFind(linename) != 0)
      {
      ObjectCreate(linename, OBJ_HLINE, 0, 0, linelevel);
      ObjectSet(linename, OBJPROP_STYLE, linestyle);     
      ObjectSet(linename, OBJPROP_COLOR, linecolor);
      ObjectSet(linename, OBJPROP_WIDTH, linewidth);
      }
   else 
      {
      ObjectMove(linename, 0, Time[10], linelevel);
      }
}
//------------------End Program------------------------------------------      