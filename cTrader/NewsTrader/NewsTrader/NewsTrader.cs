using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class NewsTrader : Robot
    {

        [Parameter("News Minute", DefaultValue = 30)]
        public int NewsMinute { get; set; }

        [Parameter("$ Risk", DefaultValue = 0.01)]
        public double Risk { get; set; }

        [Parameter("R:R", DefaultValue = 3)]
        public int RiskReward { get; set; }

        [Parameter("ATR Period", DefaultValue = 5)]
        public int ATRPeriod { get; set; }

        [Parameter("ATR Multipier", DefaultValue = 2)]
        public double ATRMultiplier { get; set; }

        [Parameter("Min Leg Size", DefaultValue = 5)]
        public int MinLegSize { get; set; }

        protected bool ordersPlaced = false;

        protected override void OnStart()
        {
            Timer.Start(1);
            ordersPlaced = false;
        }

        protected override void OnTick()
        {
            // Put your core logic here
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }

        protected override void OnTimer()
        {
            if (!ordersPlaced && (Time.Minute == NewsMinute - 1 || (NewsMinute == 0 && Time.Minute == 59)) && Time.Second >= 56)
            {
                AverageTrueRange averageTrueRange = Indicators.AverageTrueRange(ATRPeriod, MovingAverageType.Exponential);
                double LegSize = Math.Max((averageTrueRange.Result.LastValue * 10000) * ATRMultiplier, MinLegSize);

                // take the $ value to be risked, convert into lots using the pip value of the current pair, then
                // convert that in volume for cTrader, then normalize it so that we dont get wierd fractional volumes,
                // in volume must always be a multiple of 1000
                long volume = ((long)((Risk / (LegSize * 2)) / Symbol.PipValue) / 1000) * 1000;

                PlaceStopOrderAsync(TradeType.Buy, Symbol, volume, Symbol.Bid + (LegSize * Symbol.PipSize), "NTBUY", LegSize * 2, RiskReward * LegSize);
                PlaceStopOrderAsync(TradeType.Sell, Symbol, volume, Symbol.Bid - (LegSize * Symbol.PipSize), "NTBUY", (LegSize * 2), RiskReward * LegSize);
                ordersPlaced = true;
            }
        }
    }
}
