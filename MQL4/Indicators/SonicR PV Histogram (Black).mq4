//+-------------------------------------------------------------------------------------------+
//|                                                                                           |
//|                                SonicR PV Histogram.mq4                                    |
//|                                                                                           |
//+-------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2011 traderathome"
#property link      "email:   traderathome@msn.com"

/*---------------------------------------------------------------------------------------------
Overview:

This indicator produces a multi-colored volume histogram based on special price and volume
situations, described as follows. 

The indicator can be turned on/off without having to remove it from the chart, preserving your
chart settings.  You can specify a width to add to make wide bars, which is good for when you 
zoom in on a chart which naturally makes all the chart bars wider. You can also change colors.  
To make any such changes, modify the under the Inputs tab, close the External Inputs window 
and change the chart TF back and forth once.  Your changes are then made and appear under the 
Colors tab also.  They will be permanent for the chart until you make other changes.
 
Green & Red Volume Climax Bars - 
Green bars are for bull candles and red bars are for bear candles.  The product of volume and
candle price spread is highest for the calculation Climax_Period, or as included by the 
Climax_Factor.  in other words, if the Climax_Factor is 0.88, then the bar only has to be 88% 
of the highest product in order to show green/red.

Blue Volume Rising Bars -
Bar volume is >= the Rising_Period average volume by the input Volume_Factor.  For example, if 
the Rising_Period is "10" and the Volume_Factor is "1.38", then any bar with volume >= 1.38 
times the average volume of the last 10 bars will be blue, unless already qualified as a 
volume climax bar.  While blue is used for both bull and bear candles, you could use 2 colors.

Gray Volume Normal Bars -
All remaining volume histogram bars are displayed in gray.

There are user controls for the periods used in computing climax and rising volume, and for 
the factors that, by their settings, can "filter" to allow more or less bars be selected for 
display.  

  1. The Climax_Period is set to "20".  Decreasing the period tends to increase displayed bars 
     (less selective).  The Climax_Factor is set to "1.0", the maximum value.  A greater input
     will default to "1.0". The min/max recommeded range is "0.75 - 1.0". Decreasing the factor 
     tends to increase displayed bars (less selective.

  2. The Rising_period is set to "10".  Increasing the period tends to increase displayed bars 
     (less selective).  The Rising_Factor is set to "1.38".  A range of "1.38 - 1.62" is best. 
     Decreasing the factor tends to increase displayed bars (less selective).
     
This indicator includes a voice alert "Volume!" that will trigger one time per TF (TFs > M1) 
at the first qualification of the bar as green or red.  On M1 TFs multiple alerts can happen 
during the minute. 
                                        
The indicator ShortName in the study sub-window shows the averaging period, and the status of
the voice and text alers.  The ShortName can be turned off to allow an unobstructed study when 
multiple small charts are simultaneously displayed in the MT4 main window. 

When this indicator is used with the SonicR PV Histogram indicator, be sure all the settings 
are the same in both indicators!

                                                                    - Traderathome, 07-16-2011 
-----------------------------------------------------------------------------------------------
Acknowledgements:
BetterVolume.mq4 - for some core coding (BetterVolume_v1.4).
     
-----------------------------------------------------------------------------------------------
Suggested Settings:         White Chart        Black Chart         Function

#property indicator_color1  LightGray          DimGray             Volume Bars
#property indicator_color2  C'33,201,83'       Lime                Climax Bull
#property indicator_color3  C'33,201,83'       Red                 Climax Bear
#property indicator_color4  C'0,0,244'         C'62,158,255'       Rising Bull            
#property indicator_color5  C'0,0,244'         C'62,158,255'       Climax Bear           
#property indicator_width1  2                  2
#property indicator_width2  2                  2
#property indicator_width3  2                  2
#property indicator_width4  2                  2           
#property indicator_width5  2                  2             
---------------------------------------------------------------------------------------------*/


//+-------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                   |                                                        
//+-------------------------------------------------------------------------------------------+ 
#property indicator_separate_window
#property indicator_buffers 5

#property indicator_color1  DimGray      
#property indicator_color2  Lime 
#property indicator_color3  Red      
#property indicator_color4  C'62,158,255'  
#property indicator_color5  C'62,158,255'                       
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2

//Global External Inputs 
extern bool   Indicator_On                    = true;
extern bool   Show_Wide_Bars                  = false;
extern int    Wide_Bar_Width                  = 3;
extern bool   Show_Climax_Volume              = true;
extern bool   Show_Rising_Volume              = true;
extern int    Climax_Period                   = 20; 
extern double Climax_Factor                   = 1.0; 
extern int    Rising_Period                   = 10; 
extern double Rising_Factor                   = 1.38; 
extern color  Volume_Normal_Bars              = DimGray;
extern color  Volume_Climax_Bull              = Lime;
extern color  Volume_Climax_Bear              = Red;
extern color  Volume_Rising_Bull              = C'62,158,255';
extern color  Volume_Rising_Bear              = C'62,158,255';
extern bool   Voice_Alert_On                  = false;
extern bool   Text_Alert_On                   = false;
extern bool   Show_Indicator_ShortName        = true;

//Global Buffers & Other Inputs
bool          FLAG_deinit;
int           i,j,n;
int           Volume_Rising_Width,Volume_Climax_Width,Volume_Normal_Width;
double        Normal[];
double        Climax1[],Climax2[];
double        Rising1[],Rising2[]; 
double        av,Range,Value2,HiValue2,tempv2;
datetime      dt1, dt2;

//+-------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                  |
//+-------------------------------------------------------------------------------------------+
int init()
  {
  FLAG_deinit  = false;
  dt1 = iTime(NULL,0,1); dt2 = dt1;
  
  if (Climax_Factor > 1) {Climax_Factor = 1;} 
   
  Volume_Rising_Width= 2;
  Volume_Climax_Width= 2;
  Volume_Normal_Width= 2;
      
  if (Show_Wide_Bars)
    {
    Volume_Rising_Width= Wide_Bar_Width;
    Volume_Climax_Width= Wide_Bar_Width;
    Volume_Normal_Width= Wide_Bar_Width;
    } 
       
  //Indicators 
  SetIndexBuffer(0, Normal);  
  SetIndexStyle(0, DRAW_HISTOGRAM, 0, Volume_Normal_Width, Volume_Normal_Bars);  
  
  if (Show_Climax_Volume)
    {  
    SetIndexBuffer(1, Climax1);   
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, Volume_Climax_Width, Volume_Climax_Bull);
    SetIndexBuffer(2, Climax2);   
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, Volume_Climax_Width, Volume_Climax_Bear);
    }
     
  if (Show_Rising_Volume)
    {      
    SetIndexBuffer(3, Rising1);   
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, Volume_Rising_Width, Volume_Rising_Bull);
    SetIndexBuffer(4, Rising2);   
    SetIndexStyle(4, DRAW_HISTOGRAM, 0, Volume_Rising_Width, Volume_Rising_Bear); 
    }
       
  //Indicator subwindow data labels     
  SetIndexLabel(0,  NULL);
  SetIndexLabel(1,  NULL); 
  SetIndexLabel(2,  NULL);
  SetIndexLabel(3,  NULL);
  SetIndexLabel(4,  NULL);
  SetIndexLabel(5,  NULL);
  SetIndexLabel(6,  NULL);
  SetIndexLabel(7,  NULL); 
         
  return(0);
  }
  
//+-------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                |
//+-------------------------------------------------------------------------------------------+
int deinit()
  {
  //Comment("");
  return(0);
  }
  
//+-------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                       |
//+-------------------------------------------------------------------------------------------+
int start()
  {
  //If Indicator is "Off" deinitialize only once, not every tick------------------------------  
  if (!Indicator_On)
    {
    if (Show_Indicator_ShortName) 
      {
      IndicatorShortName("SonicR PV Histogram  ("+Climax_Period+", "+Rising_Period+")  -off.   ");
      }  
    else {IndicatorShortName("");}
    if (!FLAG_deinit) {deinit(); FLAG_deinit = true;}
    return(0);
    }  
             
  for(i = Bars-1-IndicatorCounted(); i >= 0; i--)       
    {            
    //Clear buffers
    Normal[i] = Volume[i]; 
    Climax1[i]  = 0;   
    Climax2[i]  = 0;                          
    Rising1[i]  = 0;
    Rising2[i]  = 0;    
    Value2        = 0;
    HiValue2      = 0;
    tempv2        = 0;
    av            = 0;
            
    //Compute Average Volume   
    for (j = i; j < (i+Rising_Period); j++) {av = av + Volume[j];}   
    av = av / Rising_Period;     
               
    //Input average and current volume into ShortName
    if (Show_Indicator_ShortName)
      {
      string ShortName= "SonicR PV Histogram  ("+Climax_Period+", "+Rising_Period+")   "; 
           
      if((!Voice_Alert_On) && (!Text_Alert_On))
        {
        IndicatorShortName (ShortName + "Voice & Text Alerts off.   "); 
        }
      else {if((Voice_Alert_On) && (!Text_Alert_On))
        {  
        IndicatorShortName (ShortName + "Voice Alert On, Text Alert off.   ");         
        }
      else {if((!Voice_Alert_On) && (Text_Alert_On))
        {
        IndicatorShortName (ShortName + "Voice Alert Off, Text Alert on.   "); 
        }
      else {if((Voice_Alert_On) && (Text_Alert_On))
        {
        IndicatorShortName (ShortName + "Voice & Text Alerts on.   ");               
        } }}}
      }                                                  
    else                                 
      {
      IndicatorShortName("");
      }  
       
    //Calculations necessary for candles                 
    Range = (High[i]-Low[i]);
    Value2 = Volume[i]*Range;                 
    for (n=i;n<i+Climax_Period;n++)
      {
      tempv2 = Volume[n]*((High[n]-Low[n])); 
      if (tempv2 >= HiValue2) {HiValue2 = tempv2;}    
      }
                
    if(Value2 >= HiValue2 * Climax_Factor)
      { 
      //Bull Candle                                  
      if (Close[i] > Open[i]) 
        {
        Climax1[i] = NormalizeDouble(Volume[i],0);
        }
      //Bear Candle  
      else if (Close[i] <= Open[i]) 
        {
        Climax2[i] = NormalizeDouble(Volume[i],0);
        }
      //Voice & Text Alert
      if((Voice_Alert_On) || (Text_Alert_On))
        {  
        if((dt2 != iTime(NULL,0,0)) && (i == 0))         
          {        
          dt2 = iTime(NULL,0,0);
          if(Voice_Alert_On) {PlaySound("vol_alert.wav");}
          if(Text_Alert_On) {Alert (Symbol()+", TF "+Period()+", volume alert!");}           
          }
        }                  
      } 
                                 
      //Volume high over average                       
      else if (Volume[i] >= av * Rising_Factor)
        {
        //Bull Candle                                  
        if (Close[i] > Open[i]) 
          {
          Rising1[i] = NormalizeDouble(Volume[i],0);
          }
        // Bear Candle  
        else if (Close[i] <= Open[i]) 
          {
          Rising2[i] = NormalizeDouble(Volume[i],0);
          }                                  
        }              
                  
    }//End "for i" loop    
    
  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//|Custom indicator end                                                                       |
//+-------------------------------------------------------------------------------------------+    
         