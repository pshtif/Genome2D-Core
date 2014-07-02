package com.genome2d.components;

import com.genome2d.components.renderables.GSprite;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
import flash.events.Event;
class GScreenManager extends GComponent {
    private var g2d_cameraController:GCameraController;
    private var g2d_screenWidth:Int;
    private var g2d_screenHeight:Int;

    override public function init():Void {
        g2d_cameraController = cast GNodeFactory.createNodeWithComponent(GCameraController);
        node.addChild(g2d_cameraController.node);
    }

    public function setup(p_screenWidth:Int, p_screenHeight:Int, p_resize:Bool = true):Void {
        g2d_screenWidth = p_screenWidth;
        g2d_screenHeight = p_screenHeight;

        g2d_cameraController.node.transform.setPosition(g2d_screenWidth*.5, g2d_screenHeight*.5);

        if (p_resize) {
            node.core.getContext().onResizeSignal.add(resizeHandler);
        }
    }

    private var oldZoom:Int = 1;

    private function resizeHandler(p_width:Int, p_height:Int):Void {
        var aw:Float = p_width/g2d_screenWidth;
        var ah:Float = p_height/g2d_screenHeight;

        var a:Float = Math.min(aw, ah);
        g2d_cameraController.zoom = a;

        if (a!=oldZoom) {
            var child:GNode = node.firstChild.nextNode;
            while (child != null) {
                var sprite:GSprite = cast child.getComponent(GSprite);
                sprite.textureId = (a>1.5) ? "textureHD" : "textureSD";
                child = child.nextNode;
            }
        }
    }
}