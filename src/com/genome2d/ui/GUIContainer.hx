package com.genome2d.ui;
import com.genome2d.geom.GPoint;
import flash.Vector;
class GUIContainer extends GUIControl {

    private var g2d_children:Array<GUIControl>;

    public var autoSize:Bool = false;

    public function new() {
        g2d_children = new Array<GUIControl>();
    }

    override public function render(p_x:Float, p_y:Float):Void {
        var flowX:Float = 0;
        var flowY:Float = 0;
        var maxHeight:Float = 0;
        var childCount:Int = g2d_children.length;
        for (i in 0...childCount) {
            var child:GUIControl = g2d_children[i];
            child.invalidate();
            if (!autoSize) {
                if (flowX+child.left+child.fullWidth>width) {
                    flowX = 0;
                    flowY = maxHeight;
                }
            }
            child.render(p_x+flowX, p_y+flowY);
            flowX += child.fullWidth;

            if (maxHeight<child.fullHeight) maxHeight = child.fullHeight;
        }
    }

    public function addChild(p_uiControl:GUIControl):Void {
        g2d_children.push(p_uiControl);
    }
}
