package com.genome2d.ui;
import com.genome2d.context.IContext;
import com.genome2d.components.renderables.GSprite;
import com.genome2d.textures.GTexture;
class GUIButton extends GUIControl {
    public var skin:GTexture;

    override public function invalidate():Void {
        width = skin.width;
        height = skin.height;
    }

    override public function render(p_x:Float, p_y:Float):Void {
        var context:IContext = Genome2D.getInstance().getContext();

        context.draw(skin, p_x+left, p_y+top, 1, 1, 0, 1, 1, 1, 1, 1, null);
    }
}
