package com.genome2d.ui.skin;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GContextTexture;
import com.genome2d.context.IContext;
import com.genome2d.textures.GTexture;

@prototypeName("skin1")
class GUI1SliceSkin extends GUISkin {
    public var texture:GTexture;

    #if swc @:extern #end
    @prototype public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    inline private function get_textureId():String {
        return (texture != null) ? texture.id : "";
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        texture = GTextureManager.getTextureById(p_value);

        if (texture != null) {
            texture.pivotX = -texture.width/2;
            texture.pivotY = -texture.height/2;
        }

        return p_value;
    }

    override public function getMinWidth():Float {
        return texture.width;
    }

    override public function getMinHeight():Float {
        return texture.height;
    }

    public function new(p_id:String = "", p_textureId:String = "") {
        super(p_id);

        type = GUISkinType.SLICE1;
        textureId = p_textureId;
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Void {
        var context:IContext = Genome2D.getInstance().getContext();
        var width:Float = p_right - p_left;
        var height:Float = p_bottom - p_top;
        var x:Float = p_left + .5*texture.width + texture.pivotX;
        var y:Float = p_top + .5*texture.height + texture.pivotY;

        context.draw(texture, x, y, width/texture.width, height/texture.height, 0, 1, 1, 1, 1, 1, null);
    }

    override public function getTexture():GContextTexture {
        return texture;
    }
}
