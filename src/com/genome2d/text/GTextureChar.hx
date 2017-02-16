/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.text;

import com.genome2d.textures.GTexture;

class GTextureChar {
    private var g2d_xoffset:Float = 0;
    #if swc @:extern #end
    public var xoffset(get, set):Float;
    #if swc @:getter(xoffset) #end
    inline private function get_xoffset():Float {
        return g2d_xoffset * g2d_texture.scaleFactor;
    }
    #if swc @:setter(xoffset) #end
    inline private function set_xoffset(p_value:Float):Float {
        g2d_xoffset = p_value / g2d_texture.scaleFactor;
        return g2d_xoffset;
    }

    private var g2d_yoffset:Float = 0;
    #if swc @:extern #end
    public var yoffset(get, set):Float;
    #if swc @:getter(yoffset) #end
    inline private function get_yoffset():Float {
        return g2d_yoffset * g2d_texture.scaleFactor;
    }
    #if swc @:setter(yoffset) #end
    inline private function set_yoffset(p_value:Float):Float {
        g2d_yoffset = p_value / g2d_texture.scaleFactor;
        return g2d_yoffset;
    }

    private var g2d_xadvance:Float = 0;
    #if swc @:extern #end
    public var xadvance(get, set):Float;
    #if swc @:getter(xadvance) #end
    inline private function get_xadvance():Float {
        return g2d_xadvance * g2d_texture.scaleFactor;
    }
    #if swc @:setter(xadvance) #end
    inline private function set_xadvance(p_value:Float):Float {
        g2d_xadvance = p_value / g2d_texture.scaleFactor;
        return g2d_xadvance;
    }
	
	private var g2d_texture:GTexture;
	#if swc @:extern #end
    public var texture(get, never):GTexture;
    #if swc @:getter(texture) #end
    inline private function get_texture():GTexture {
        return g2d_texture;
    }
	
	public function new(p_texture:GTexture):Void {
		g2d_texture = p_texture;
	}

    public function dispose():Void {
        g2d_texture = null;
    }
}