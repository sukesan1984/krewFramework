package com.tatsuyakoyama.krewfw.utility {

    import com.tatsuyakoyama.krewfw.utility.KrewUtil;

    //------------------------------------------------------------
    public class KrewTimeKeeperTask {

        private var _totalPassedTime:Number = 0;
        private var _prevPassedTime:Number  = 0;
        private var _interval:Number;
        private var _task:Function;
        private var _times:int = -1;  // number of runs. -1 means infinity

        //------------------------------------------------------------
        public function KrewTimeKeeperTask(interval:Number, task:Function, times:int=-1) {
            _interval = interval;
            _task     = task;
            _times    = times;

            if (_interval <= 0) {
                KrewUtil.fwlog('[Error] interval should not be 0 or less.');
                _interval = 0.1;
            }
        }

        public function update(passedTime:Number):void {
            if (_times == 0) { return; }

            _totalPassedTime += passedTime;
            while (_totalPassedTime - _prevPassedTime > _interval) {
                _prevPassedTime += _interval;
                _task();
                if (_times > 0) { --_times; }
            }
        }

        public function dispose():void {
            _task = null;
        }
    }
}
