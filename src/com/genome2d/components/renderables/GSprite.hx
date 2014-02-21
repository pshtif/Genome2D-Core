package com.genome2d.components.renderables;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

/**
 * ...
 * @author 
 */
class GSprite extends GTexturedQuad
{
    /**
     *  Texture id used by this sprite
     **/
    #if swc @:extern #end
    public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    inline private function get_textureId():String {
        var id:String = "";
        if (texture != null) id = texture.getId();
        return id;
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        texture = GTexture.getTextureById(p_value);
        return p_value;
    }

    /**
     *  @private
     **/
	public function new(p_node:GNode) {
		super(p_node);

        g2d_prototypableProperties.push("textureId");
	}
	
}