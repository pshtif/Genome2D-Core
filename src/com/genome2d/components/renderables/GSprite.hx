/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables;

import com.genome2d.textures.GTexture;

/**
    Component used for rendering single texture
**/
class GSprite extends GTexturedQuad
{
    /**
        Texture id used by this sprite
    **/
    #if swc @:extern #end
    @prototype public var textureId(get, set):String;
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
}