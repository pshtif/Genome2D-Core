package com.genome2d.components.renderable.ui;

import com.genome2d.geom.GPoint;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.input.GMouseInput;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;
import com.genome2d.components.renderable.IGRenderable;

@:access(com.genome2d.ui.element.GUIElement)
@:access(com.genome2d.ui.skin.GUISkin)
class GUI extends GComponent implements IGRenderable {

    public var root:GUIElement;
	public var useNodePosition:Bool = false;
    public var enableBoundsCulling:Bool = false;
	private var g2d_bounds:GRectangle;

    override public function init():Void {
        root = new GUIElement();
        root.g2d_gui = this;
		root.name = "root";
        root.g2d_root = root;
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

    inline public function getBounds(p_target:GRectangle = null):GRectangle {
        return g2d_bounds;
    }

    public function captureMouseInput(p_input:GMouseInput):Void {
        root.captureMouseInput(p_input);
    }

	public function hitTest(p_x:Float, p_y:Float):Bool {
        return false;
    }

    public function worldToUi(p_world:GPoint, p_result:GPoint = null):GPoint {
        if (p_result == null) p_result = new GPoint();

        p_result.x = p_world.x - root.g2d_worldLeft;
        p_result.y = p_world.y - root.g2d_worldTop;

        return p_result;
    }
}
