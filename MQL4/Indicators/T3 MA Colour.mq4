//
//
//
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 SteelBlue
#property indicator_color3 SteelBlue
#property indicator_color4 C'175,18,117'
#property indicator_color5 C'175,18,117'
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
#property  indicator_width4  2
#property  indicator_width5  2
extern int MA_Period = 8;
extern double b = 0.4;


double MapBuffer[];

double e1[],e2[],e3[],e4[],e5[],e6[];
double c1,c2,c3,c4;
double n,w1,w2,b2,b3;

double MA[];
double MAua[];
double MAub[];
double MAda[];
double MAdb[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators setting
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,indicator_width1,indicator_color1);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,indicator_width2,indicator_color2);
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,indicator_width3,indicator_color3);
SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,indicator_width4,indicator_color4);
SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,indicator_width5,indicator_color5);
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
IndicatorShortName("T3 MA"+MA_Period);
SetIndexDrawBegin(0,100);
//SetIndexBuffer(0,MapBuffer);


SetIndexBuffer(0,MA);
SetIndexBuffer(1,MAua);
SetIndexBuffer(2,MAub);
SetIndexBuffer(3,MAda);
SetIndexBuffer(4,MAdb);



//---- variable reset
//e2=0; e3=0; e4=0; e5=0; e6=0;
c1=0; c2=0; c3=0; c4=0; 
n=0; 
w1=0; w2=0; 
b2=0; b3=0;

b2=b*b;
b3=b2*b;
c1=-b3;
c2=(3*(b2+b3));
c3=-3*(2*b2+b+b3);
c4=(1+3*b+b3+3*b2);
n=MA_Period;

if (n<1) n=1;
n = 1 + 0.5*(n-1);
w1 = 2 / (n + 1);
w2 = 1 - w1;

//----
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int limit;
int counted_bars=IndicatorCounted();
if (counted_bars<0) return (-1);
if (counted_bars>0) counted_bars--;
limit=(Bars-counted_bars)-1;

//---- indicator calculation
ArrayResize(e1, Bars+1);
ArrayResize(e2, Bars+1);
ArrayResize(e3, Bars+1);
ArrayResize(e4, Bars+1);
ArrayResize(e5, Bars+1);
ArrayResize(e6, Bars+1);

for(int i=limit; i>=0; i--)
{
e1[Bars-i] = w1*Close[i] + w2*e1[(Bars-i)-1];
e2[Bars-i] = w1*e1[Bars-i] + w2*e2[(Bars-i)-1];
e3[Bars-i] = w1*e2[Bars-i] + w2*e3[(Bars-i)-1];
e4[Bars-i] = w1*e3[Bars-i] + w2*e4[(Bars-i)-1];
e5[Bars-i] = w1*e4[Bars-i] + w2*e5[(Bars-i)-1];
e6[Bars-i] = w1*e5[Bars-i] + w2*e6[(Bars-i)-1];
//Print ("I- ",i, "Bars-I ",Bars-i);
MA[i]=c1*e6[Bars-i] + c2*e5[Bars-i] + c3*e4[Bars-i] + c4*e3[Bars-i];

MAua[i] = EMPTY_VALUE;
MAua[i] = EMPTY_VALUE;
MAda[i] = EMPTY_VALUE;
MAdb[i] = EMPTY_VALUE;
if (MA[i]>MA[i+1]) PlotPoint(i,MAua,MAub,MA);
if (MA[i]<MA[i+1]) PlotPoint(i,MAda,MAdb,MA);


} 
//----
return(0);
}
//+------------------------------------------------------------------+
void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   = from[i];
                second[i+1] = from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}
//
//
//
//
//
//
//void CleanPoint(int i,double& first[],double& second[])
//{
//   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
//        second[i+1] = EMPTY_VALUE;
//   else
//      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
//          first[i+1] = EMPTY_VALUE;
//}

