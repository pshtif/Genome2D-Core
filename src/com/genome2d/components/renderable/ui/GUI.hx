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
		var rect:GRectangle = node.core.getContext().getStageViewRect();
        root.g2d_worldLeft = 0;
        root.g2d_worldRight = rect.width;
        root.g2d_worldTop = 0;
        root.g2d_worldBottom = rect.height;
        root.g2d_finalWidth = rect.width;
        root.g2d_finalHeight = rect.height;
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

    public function captureMouseInput(p_input:GMouseInput):Void {
        root.captureMouseInput(p_input);
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
        return false;
    }
}
