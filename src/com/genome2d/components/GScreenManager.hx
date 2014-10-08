package com.genome2d.components;

import com.genome2d.utils.GHAlignType;
import com.genome2d.utils.GVAlignType;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.IContext;
import com.genome2d.Genome2D;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
class GScreenManager extends GComponent {
    private var g2d_cameraController:GCameraController;

    private var g2d_vAlign:Int = GVAlignType.MIDDLE;
    #if swc @:extern #end
    public var vAlign(get, set):Int;
    #if swc @:getter(vAlign) #end
    inline private function get_vAlign():Int {
        return g2d_vAlign;
    }
    #if swc @:setter(vAlign) #end
    inline private function set_vAlign(p_value:Int):Int {
        return g2d_vAlign = p_value;
    }

    private var g2d_hAlign:Int = GHAlignType.CENTER;
    #if swc @:extern #end
    public var hAlign(get, set):Int;
    #if swc @:getter(hAlign) #end
    inline private function get_hAlign():Int {
        return g2d_hAlign;
    }
    #if swc @:setter(hAlign) #end
    inline private function set_hAlign(p_value:Int):Int {
        return g2d_hAlign = p_value;
    }

    public var stageLeft:Float;
    public var stageTop:Float;
    public var stageRight:Float;
    public var stageBottom:Float;

    public var screenLeft:Float;
    public var screenTop:Float;
    public var screenRight:Float;
    public var screenBottom:Float;

    override public function init():Void {
        g2d_cameraController = cast GNodeFactory.createNodeWithComponent(GCameraController);
        node.addChild(g2d_cameraController.node);
    }

    public function setup(p_stageWidth:Int, p_stageHeight:Int, p_resize:Bool = true):Void {
        stageLeft = 0;
        stageTop = 0;
        stageRight = p_stageWidth;
        stageBottom = p_stageHeight;

        g2d_cameraController.node.transform.setPosition(stageRight*.5, stageBottom*.5);

        if (p_resize) {
            node.core.getContext().onResize.add(resizeHandler);
        }

        var rect:GRectangle = Genome2D.getInstance().getContext().getStageViewRect();
        resizeHandler(rect.width, rect.height);
    }

    private var oldZoom:Int = 1;

    private function resizeHandler(p_width:Float, p_height:Float):Void {
        var aw:Float = p_width/stageRight;
        var ah:Float = p_height/stageBottom;

        var a:Float = Math.min(aw, ah);
        g2d_cameraController.zoom = a;

        if (aw<ah) {
            screenLeft = 0;
            screenRight = stageRight;
            switch (vAlign) {
                case GVAlignType.MIDDLE:
                    screenTop = (stageBottom*a-p_height)/(2*a);
                    screenBottom = stageBottom+(p_height-a*stageBottom)/(2*a);
                case GVAlignType.TOP:
                    screenTop = 0;
                    screenBottom = stageBottom+(p_height-a*stageBottom)/a;
                case GVAlignType.BOTTOM:
                    screenTop = (stageBottom*a-p_height)/a;
                    screenBottom = p_height;
            }
        } else {
            switch (hAlign) {
                case GHAlignType.CENTER:
                    screenLeft = (a*stageRight-p_width)/(2*a);
                    screenRight = stageRight+(p_width-a*stageRight)/(2*a);
                case GHAlignType.LEFT:
                    screenLeft = 0;
                    screenRight = stageRight+(p_width-a*stageRight)/a;
                case GHAlignType.RIGHT:
                    screenLeft = (a*stageRight-p_width)/a;
                    screenRight = p_width;
            }
            screenTop = 0;
            screenBottom = stageBottom;
        }
    }
}