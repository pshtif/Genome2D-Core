package com.genome2d.components.ui;
import com.genome2d.ui.GUIContainer;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextCamera;
import com.genome2d.components.renderables.IRenderable;
class GUI extends GComponent implements IRenderable {
    public var root:GUIContainer;

    override public function init():Void {
        root = new GUIContainer();
    }

    public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
        root.render(node.transform.g2d_worldX, node.transform.g2d_worldY);
    }

    public function getBounds(p_target:GRectangle = null):GRectangle {
        return null;
    }
}
