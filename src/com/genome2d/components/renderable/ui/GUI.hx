package com.genome2d.components.renderable.ui;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.input.GMouseInput;
import com.genome2d.input.GMouseInputType;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.components.renderable.IRenderable;

@:access(com.genome2d.ui.element.GUIElement)
@:access(com.genome2d.ui.skin.GUISkin)
class GUI extends GComponent implements IRenderable {

    public var root:GUIElement;

    override public function init():Void {
        root = new GUIElement();
        root.g2d_worldLeft = 0;
        root.g2d_worldRight = 1024;
        root.g2d_worldTop = 0;
        root.g2d_worldBottom = 768;
        root.g2d_finalWidth = 1024;
        root.g2d_finalHeight = 768;
        root.name = "root";
        root.mouseEnabled = false;
    }

    public function invalidate():Void {
        root.calculateWidth();
        root.invalidateWidth();
        root.calculateHeight();
        root.invalidateHeight();
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        invalidate();

        root.render();
        GUISkin.flushBatch();
    }

    public function getBounds(p_target:GRectangle = null):GRectangle {
        return null;
    }

    public function captureMouseInput(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextInput:GMouseInput):Bool {
        if (p_captured && p_contextInput.type == GMouseInputType.MOUSE_UP) node.g2d_mouseDownNode = null;

        var capture:Bool = root.processMouseInput(p_captured, p_cameraX, p_cameraY, p_contextInput);

        if (!p_captured && capture) {
            var tx:Float = p_cameraX - node.g2d_worldX;
            var ty:Float = p_cameraY - node.g2d_worldY;

            if (node.g2d_mouseOverNode != node) {
                node.dispatchMouseCallback(GMouseInputType.MOUSE_OVER, node, tx, ty, p_contextInput);
            }
        } else {
            if (node.g2d_mouseOverNode == node) node.dispatchMouseCallback(GMouseInputType.MOUSE_OUT, node, 0, 0, p_contextInput);
        }

        return p_captured || capture;
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
        return false;
    }
}
