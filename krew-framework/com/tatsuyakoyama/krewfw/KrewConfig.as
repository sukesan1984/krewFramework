package com.tatsuyakoyama.krewfw {

    /**
     * Please customize these static values for your game
     * before the krewFramework starts up.
     */
    public class KrewConfig {

        /** Virtual screen size */
        public static var SCREEN_WIDTH :int = 480;

        /** Virtual screen size */
        public static var SCREEN_HEIGHT:int = 320;

        /**
         * FPS がどこまで落ちるのを許すか。
         * これ以上の遅れは単純な処理落ちとして扱う
         */
        public static var ALLOW_DELAY_FPS:int = 15;

        /**
         * ビルド対象のプラットフォームに応じて、ファイルアクセスのベースパスとなる
         * スキーマを任意に指定してほしい.
         * このスキーマは krewfw.core_internal.KrewResourceManager でのパス解決に使用される。
         *
         * <ul>
         *   <li>ローカルでテストしたい場合は空文字列 "" でよい。
         *       （swf と同じ階層にアセットディレクトリのリンクなど置いておくことを想定）
         *   </li>
         *   <li>iOS, Android アプリの場合は "app:/" を指定する</li>
         *   <li>Web 上で Flash として公開したい場合は "http://..." のように
         *       アセットが置かれている URL を指定すればよい
         *   </li>
         * </ul>
         */
        public static var ASSET_URL_SCHEME:String = "";

        public static var ASSET_BASE_PATH:String = "asset/";


        //------------------------------------------------------------
        // デバッグ系
        //------------------------------------------------------------

        /**
         * KrewFramework のログ (KrewUtil.fwlog) のレベル.
         * <ul>
         *   <li>0 にすると吐かない</li>
         *   <li>1 で普通に trace</li>
         *   <li>2 だと吐いたクラス名やソースの行数も付与する</li>
         * </ul>
         *
         * [ToDo] 現状 2 にしておくと実機で動かしたときにうまく動かなかった気がする…
         */
        public static var FW_LOG_VERBOSE:int = 1;

        /**
         * ゲーム側で利用するログ (KrewUtil.log) のレベル.
         * 数字の意味は FW_LOG_VERBOSE と同様
         */
        public static var GAME_LOG_VERBOSE:int = 1;

        /** true にすると１秒に１回各 layer の Actor 数をログに吐く */
        public static var WATCH_NUM_ACTOR:Boolean = false;

        /** true にすると starling.utils.AssetMamager のログを吐く */
        public static var ASSET_MANAGER_VERBOSE:Boolean = false;
    }
}
