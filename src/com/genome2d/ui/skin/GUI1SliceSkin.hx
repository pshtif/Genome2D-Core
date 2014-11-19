package com.genome2d.ui.skin;
import com.genome2d.textures.GContextTexture;
import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;

class GUI1SliceSkin extends GUISkin {
    public var texture:GTexture;

    override public function getMinWidth():Float {
        return texture.width;
    }

    override public function getMinHeight():Float {
        return texture.height;
    }

    public function new(p_id:String, p_textureId:String) {
        super(p_id);
        type = GUISkinType.SLICE1;
        texture = GTexture.getTextureById(p_textureId);
        if (texture != null) {
            texture.pivotX = -texture.width/2;
            texture.pivotY = -texture.height/2;
        }
    }

    override public function render(p_x:Float, p_y:Float, p_width:Float, p_height:Float):Void {
        trace(p_x, p_y, p_width, p_height);
        var context:IContext = Genome2D.getInstance().getContext();
        context.draw(texture, p_x, p_y, p_width/texture.width, p_height/texture.height, 0, 1, 1, 1, 1, 1, null);
    }

    override public function getTexture():GContextTexture {
        return texture;
    }
}
