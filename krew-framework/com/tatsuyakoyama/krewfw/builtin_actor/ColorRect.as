package com.tatsuyakoyama.krewfw.builtin_actor {

    import starling.display.Quad;

    import com.tatsuyakoyama.krewfw.core.KrewActor;

    /**
     * Simple rectangle node with vertex color.
     */
    //------------------------------------------------------------
    public class ColorRect extends KrewActor {

        private var _quad:Quad;

        public var _color1:int;
        public var _color2:int;
        public var _color3:int;
        public var _color4:int;

        //------------------------------------------------------------
        /**
         * color index:
         *   1 - 2
         *   | / |
         *   3 - 4
         */
        public function ColorRect(width:Number=100, height:Number=100,
                                  touchable:Boolean=true,
                                  color1:int=0, color2:int=0,
                                  color3:int=0, color4:int=0) {
            this.touchable = touchable;

            _quad = new Quad(width, height);
            _quad.touchable = true;
            _quad.setVertexColor(0, color1);
            _quad.setVertexColor(1, color2);
            _quad.setVertexColor(2, color3);
            _quad.setVertexColor(3, color4);
            addChild(_quad);

            _color1 = color1;
            _color2 = color2;
            _color3 = color3;
            _color4 = color4;
        }

        public override function setVertexColor(color1:int=0, color2:int=0,
                                                color3:int=0, color4:int=0):void {
            _quad.setVertexColor(0, color1);
            _quad.setVertexColor(1, color2);
            _quad.setVertexColor(2, color3);
            _quad.setVertexColor(3, color4);
        }
    }
}
