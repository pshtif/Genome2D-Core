package com.genome2d.ui;
class GUIControl {
    public var position:Int = GUIPositionType.RELATIVE;

    public var left:Float = 0;
    public var right:Float = 0;
    public var top:Float = 0;
    public var bottom:Float = 0;

    public var width:Float = 0;
    public var height:Float = 0;

    public var marginLeft:Float = 0;
    public var marginRight:Float = 0;
    public var marginTop:Float = 0;
    public var marginBottom:Float = 0;

    #if swc @:extern #end
    public var fullWidth(get, never):Float;
    #if swc @:getter(fullWidth) #end
    inline private function get_fullWidth():Float {
        return marginLeft+width+marginRight;
    }

    #if swc @:extern #end
    public var fullHeight(get, never):Float;
    #if swc @:getter(fullHeight) #end
    inline private function get_fullHeight():Float {
        return marginTop+height+marginBottom;
    }

    public function invalidate():Void {

    }

    public function render(p_x:Float, p_y:Float):Void {
    }
}
