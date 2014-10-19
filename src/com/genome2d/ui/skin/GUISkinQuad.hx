package com.genome2d.ui.skin;
import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;

class GUISkinQuad extends GUISkin {
    public var texture:GTexture;

    override public function getMinWidth():Float {
        return texture.width;
    }

    override public function getMinHeight():Float {
        return texture.height;
    }

    public function new(p_skinTextureIds:Array<String>) {
        super(p_skinTextureIds);
        type = GUISkinType.NORMAL;
        texture = GTexture.getTextureById(p_skinTextureIds[0]);
    }

    override public function render(p_x:Float, p_y:Float):Void {
        var context:IContext = Genome2D.getInstance().getContext();
        context.draw(texture, p_x, p_y, 1, 1, 0, 1, 1, 1, 1, 1, null);
    }
}
