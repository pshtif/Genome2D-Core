package com.genome2d.components.renderable.ui;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.input.GMouseInput;
import com.genome2d.input.GMouseInputType;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.components.renderable.IGRenderable;

@:access(com.genome2d.ui.element.GUIElement)
@:access(com.genome2d.ui.skin.GUISkin)
class GUI extends GComponent implements IGRenderable {

    public var root:GUIElement;
	public var useNodePosition:Bool = false;
	private var g2d_bounds:GRectangle;

    override public function init():Void {
        root = new GUIElement();
		root.name = "root";
        root.g2d_isRoot = true;
        root.mouseEnabled = false;
		
		setBounds(new GRectangle(0, 0, node.core.getContext().getStageViewRect().width, node.core.getContext().getStageViewRect().height));
    }

    public function invalidate():Void {
		root.g2d_worldLeft = g2d_bounds.left + (useNodePosition ? node.g2d_worldX : 0);
		root.g2d_worldRight = g2d_bounds.right + (useNodePosition ? node.g2d_worldX : 0);
		root.g2d_worldTop = g2d_bounds.top + (useNodePosition ? node.g2d_worldY : 0);
		root.g2d_worldBottom = g2d_bounds.bottom + (useNodePosition ? node.g2d_worldY : 0);
		root.g2d_finalWidth = root.g2d_worldRight - root.g2d_worldLeft;
		root.g2d_finalHeight = root.g2d_worldBottom - root.g2d_worldTop;
		
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
	
	public function setBounds(p_bounds:GRectangle):Void {
		g2d_bounds = p_bounds;
		invalidate();
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
