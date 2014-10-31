/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderables;

import com.genome2d.error.GError;
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
    @prototype
    public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    inline private function get_textureId():String {
        return (texture != null) ? texture.getId() : "";
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        if (p_value == "") {
            texture = null;
        } else {
            texture = GTexture.getTextureById(p_value);
            if (texture == null) new GError("Invalid texture with id "+p_value);
        }
        return p_value;
    }
}