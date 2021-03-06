package com.tatsuyakoyama.krewfw.core {

    import starling.display.DisplayObject;
    import starling.events.EnterFrameEvent;
    import starling.events.Event;

    import com.tatsuyakoyama.krewfw.core.KrewSystemEventType;
    import com.tatsuyakoyama.krewfw.utility.KrewUtil;
    import com.tatsuyakoyama.krewfw.utility.KrewTimeKeeper;
    import com.tatsuyakoyama.krewfw.core_internal.SceneServantActor;
    import com.tatsuyakoyama.krewfw.core_internal.StageLayer;
    import com.tatsuyakoyama.krewfw.core_internal.StuntAction;

    //------------------------------------------------------------
    public class KrewScene extends KrewGameObject {

        private var _newActorPool:Array = new Array();
        private var _servantActor:SceneServantActor;  // to use multi tasker and so on
        private var _isTimeToExit:Boolean = false;
        private var _nextScene:KrewScene  = null;
        private var _hasDisposed:Boolean  = false;

        //------------------------------------------------------------
        public function KrewScene() {
            touchable = true;
            addEventListener(Event.ENTER_FRAME, _onEnterFrame);
        }

        public override function dispose():void {
            if (_hasDisposed) { return; }
            _hasDisposed = true;

            removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
            sharedObj.layerManager.dispose();
            sharedObj.collisionSystem.removeAllGroups();
            sharedObj.resourceManager.purgeSceneScopeResources();
            _newActorPool = [];
            onDispose();
            super.dispose();
        }

        //------------------------------------------------------------
        // To compose your game scene, implements these handlers.
        //------------------------------------------------------------

        /**
         * 「ゲーム全体で常に保持しておきたいアセット」に追加するファイル名群を指定.
         * これは起動時に 1 回だけ呼ばれる起動処理専用の Scene で指定されることを想定している。
         * 現時点では、これによってグローバルに保持したアセットを解放するインタフェースは用意していない。
         *
         * Scene の getAdditionalGlobalAssets がオーバライドされていた場合、
         * Scene は遷移時に Global のアセット読み込みを先に行ってから
         * Scene スコープのアセット読み込みを行う。
         *
         * @see getRequiredAssets
         */
        public function getAdditionalGlobalAssets():Array {
            return [];
        }

        /**
         * このシーンで必要なアセットのファイルパス一覧を指定.
         * ここで指定したアセットによって確保されたリソースは、
         * シーン遷移時に自動的に解放される
         * @return Example:
         * <pre>
         * [
         *     "image/atlas_1.png",
         *     "image/atlas_1.xml",
         *     "bgm/bgm_1.mp3",
         *     "bmp_font/gothic.png",
         *     "bmp_font/gothic.fnt",
         *     "level_data/stage_1.json"
         * ]
         * </pre>
         */
        public function getRequiredAssets():Array {
            return [];
        }

        /**
         * ローディング画面を構成するための init.
         * この時点では KrewGameDirector で指定した大域リソースしか使えないので、
         * ここでセットする Actor はグローバルに保持しているリソースを使う必要がある
         */
        public function initLoadingView():void {
            KrewUtil.fwlog(' - default initLoadingView called.');
        }

        /**
         * getAdditionalGlobalAssets で指定したアセット群のロード中に呼ばれる。
         * アセットの指定があれば最低 1 回は呼ばれ、最後の呼び出しでは loadRatio = 1 となる
         */
        public function onLoadProgressGlobal(loadRatio:Number):void {
            KrewUtil.fwlog(' - - default onLoadProgressGlobal called: ' + loadRatio);
        }

        /**
         * getAdditionalGlobalAssets で指定したアセット群のロード完了時に呼ばれる。
         * （これの直後に getRequiredAssets で指定したアセットの読み込みが始まる）
         */
        public function onLoadCompleteGlobal():void {
            KrewUtil.fwlog(' - - - default onLoadCompleteGlobal called.');
        }

        /**
         * getRequiredAssets で指定したアセット群のロード中に呼ばれる。
         * アセットの指定があれば最低 1 回は呼ばれ、最後の呼び出しでは loadRatio = 1 となる
         */
        public function onLoadProgress(loadRatio:Number):void {
            KrewUtil.fwlog(' - - - - default onLoadProgress called: ' + loadRatio);
        }

        /**
         * getRequiredAssets で指定したアセット群のロード完了時に呼ばれる。
         * （これの直後に initAfterLoad が呼ばれる）
         */
        public function onLoadComplete():void {
            KrewUtil.fwlog(' - - - - - default onLoadComplete called.');
        }

        /**
         * 全てのアセットのロード完了後の本命のシーン初期化処理
         * ここから requiredAssets で指定したアセットが使える
         */
        public function initAfterLoad():void {
            KrewUtil.fwlog(' - - - - - - default initAfterLoad called.');
        }

        /**
         * exit() が呼ばれた際に遷移する次のシーンを返すよう override してほしい.
         * なお exit(specificScene) と引数にシーンを渡した場合はそのシーンが遷移先となり、
         * この関数は無視される
         */
        public function getDefaultNextScene():KrewScene {
            return null;
        }

        /**
         * レイヤー構造の定義
         * @return Example: ['back', 'forward', 'ui']
         */
        public function getLayerList():Array {
            return ['l-back', 'l-forward', 'l-ui'];
        }

        /**
         * 衝突判定を行うグループの定義
         * @return Example: Array of Array such as
         * <pre>
         * [
         *    ['myship' , ['enemy', 'en-shot', 'item']],
         *    ['myshot' , ['enemy']],
         *    ['enemy'  , []],
         *    ['en-shot', []],
         *    ['item'   , []]
         * ]
         * </pre>
         * こう書くと「c-myship と c-enemy グループ間」、
         * 「c-myship と c-item グループ間」などでヒットテストが行われるといった次第
         */
        public function getCollisionGroups():Array {
            return [];
        }

        //------------------------------------------------------------
        // Automatically called by framework
        //------------------------------------------------------------

        /** @private */
        public function startInitSceneSequence():void {
            sharedObj.layerManager.setUpLayers(this, getLayerList());
            sharedObj.collisionSystem.setUpGroups(getCollisionGroups());
            _setUpServantActor();

            initLoadingView();

            // load global assets, load local assets, and call scene init.
            _loadGlobalAssets(function():void {
                _loadSceneScopeAssets(function():void {
                    initAfterLoad();
                });
            });
        }

        private function _loadGlobalAssets(doneCallback:Function):void {
            // hook onLoadCompleteGlobal
            var _onLoadComplete:Function = function():void {
                onLoadCompleteGlobal();
                doneCallback();
            };
            if (getAdditionalGlobalAssets().length == 0) {
                _onLoadComplete();
                return;
            }

            // hook onLoadProgressGlobal
            var _onLoadProgressGlobal:Function = function(loadRatio:Number):void {
                _servantActor.sendMessage(
                    KrewSystemEventType.PROGRESS_GLOBAL_ASSET_LOAD, {loadRatio: loadRatio}
                );
                onLoadProgressGlobal(loadRatio);
            };

            // start loading assets
            sharedObj.resourceManager.loadGlobalResources(
                getAdditionalGlobalAssets(), _onLoadProgressGlobal, _onLoadComplete
            );
        }

        private function _loadSceneScopeAssets(doneCallback:Function):void {
            // hook onLoadComplete
            var _onLoadComplete:Function = function():void {
                onLoadComplete();
                doneCallback();
            };
            if (getRequiredAssets().length == 0) {
                _onLoadComplete();
                return;
            }

            // hook onLoadProgress
            var _onLoadProgress:Function = function(loadRatio:Number):void {
                _servantActor.sendMessage(
                    KrewSystemEventType.PROGRESS_ASSET_LOAD, {loadRatio: loadRatio}
                );
                onLoadProgress(loadRatio);
            };

            // start loading assets
            sharedObj.resourceManager.loadResources(
                getRequiredAssets(), _onLoadProgress, _onLoadComplete
            );
        }

        private function _setUpServantActor():void {
            _servantActor = new SceneServantActor();
            setUpActor('_system_', _servantActor);
        }

        /**
         * @private
         * 新しい Actor を足してもらうよう Scene に頼む
         * この関数は KrewActor によって呼ばれる
         * 新しい Actor 達は既存の Actor 達の update の後に layer に足される
         */
        public function applyForNewActor(newActor:KrewActor, layerName:String=null):void {
            _newActorPool.push({
                actor: newActor,
                layer: layerName
            });
        }

        private function _recruitNewActors():void {
            var count:int = 0;
            for each (var info:Object in _newActorPool) {
                ++count;
                setUpActor(info.layer, info.actor);
            }
            if (count > 0) {
                _newActorPool = [];
                //KrewUtil.fwlog(count + ' new actor joined');
            }
        }

        /** @private */
        public function addLayer(layer:StageLayer):void {
            layer.sharedObj = this.sharedObj;
            layer.applyForNewActor = this.applyForNewActor;
            addChild(layer);
        }

        /** @private */
        protected function addActor(layerName:String, actor:KrewActor,
                                    putOnDisplayList:Boolean=true):void {
            sharedObj.layerManager.addActor(layerName, actor, putOnDisplayList);
        }

        /** @private */
        protected function addChildToLayer(layerName:String, displayObj:DisplayObject):void {
            sharedObj.layerManager.addChild(layerName, displayObj);
        }

        /** @private */
        public function getNextScene():KrewScene {
            if (_nextScene != null) {
                return _nextScene;
            }
            return getDefaultNextScene();
        }

        //------------------------------------------------------------
        /**
         * Entry point of the game loop
         */
        private function _onEnterFrame(event:EnterFrameEvent):void {
            if (_hasDisposed) { return; }

            var passedTime:Number = KrewTimeKeeper.getReasonablePassedTime(event);

            if (_servantActor.isSystemActivated) {
                // update actors
                onUpdate(passedTime);
                sharedObj.layerManager.onUpdate(passedTime);
                _recruitNewActors();

                // collision detection
                sharedObj.collisionSystem.hitTest();
            }

            // broadcast messages
            sharedObj.notificationService.broadcastMessage();

            if (_isTimeToExit) {
                dispatchEvent(new Event(KrewSystemEventType.EXIT_SCENE));
            }
        }

        //------------------------------------------------------------
        // Your tools
        //------------------------------------------------------------
        protected function exit(nextScene:KrewScene=null):void {
            _isTimeToExit = true;
            _nextScene    = nextScene;
        }

        protected function act(action:StuntAction=null):StuntAction {
            return _servantActor.act(action);
        }

        protected function react():void {
            _servantActor.react();
        }

        public function addPeriodicTask(interval:Number, task:Function):void {
            _servantActor.addPeriodicTask(interval, task);
        }

        public function addScheduledTask(timeout:Number, task:Function):void {
            _servantActor.addScheduledTask(timeout, task);
        }

        protected function setUpActor(layerName:String, actor:KrewActor,
                                      putOnDisplayList:Boolean=true):void {
            addActor(layerName, actor, putOnDisplayList);
        }
    }
}
