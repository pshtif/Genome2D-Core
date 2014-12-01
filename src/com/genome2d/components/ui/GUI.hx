package com.genome2d.components.ui;
import com.genome2d.ui.idea.GUIElement;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.ui.controls.GUIControl;
import com.genome2d.ui.controls.GUIContainer;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.components.renderable.IRenderable;
class GUI extends GComponent implements IRenderable {
    //public var root:GUIContainer;
    public var root:GUIElement;

    override public function init():Void {
        //root = new GUIContainer(null);
        root = new GUIElement();
        root.g2d_worldLeft = 0;
        root.g2d_worldRight = 1024;
        root.g2d_worldTop = 0;
        root.g2d_worldBottom = 768;
        root.name = "root";
        root.mouseEnabled = false;
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        root.invalidate();

        GUIControl.clearBatchState();
        root.render();
        GUIControl.flushBatch();
    }

    public function getBounds(p_target:GRectangle = null):GRectangle {
        return null;
    }

    override public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
        if (p_captured && p_contextSignal.type == GMouseSignalType.MOUSE_UP) node.g2d_mouseDownNode = null;

        var capture:Bool = true;// = root.processMouseSignal(p_captured, p_cameraX, p_cameraY, p_contextSignal);

        if (!p_captured && capture) {
            var tx:Float = p_cameraX - node.transform.g2d_worldX;
            var ty:Float = p_cameraY - node.transform.g2d_worldY;

            if (node.g2d_mouseOverNode != node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, node, tx, ty, p_contextSignal);
            }
        } else {
            if (node.g2d_mouseOverNode == node) node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, 0, 0, p_contextSignal);
        }

        return p_captured || capture;
    }
}
