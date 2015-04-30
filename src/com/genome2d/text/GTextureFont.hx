/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.text;

import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;

class GTextureFont {
	private var g2d_texture:GTexture;
    public var lineHeight:Int = 0;
	private var g2d_chars:Map<String,GTextureChar>;
    public var kerning:Map<Int,Map<Int,Int>>;
	
	public function new(p_texture:GTexture):Void {
		g2d_texture = p_texture;
		g2d_chars = new Map<String,GTextureChar>();
	}

    public function getCharById(p_subId:String):GTextureChar {
        return cast g2d_chars.get(p_subId);
    }

    public function addChar(p_charId:String, p_region:GRectangle, p_xoffset:Float, p_yoffset:Float, p_xadvance:Float):GTextureChar {
        var texture:GTexture = new GTexture(g2d_texture.id+"_"+p_charId, g2d_texture);
		texture.region = p_region;
		texture.pivotX = -p_region.width/2;
        texture.pivotY = -p_region.height/2;
		
		var char:GTextureChar = new GTextureChar(texture);
		char.xoffset = p_xoffset;
		char.yoffset = p_yoffset;
		char.xadvance = p_xadvance;
        g2d_chars.set(p_charId, char);

        return char;
    }

    public function getKerning(p_first:Int, p_second:Int):Float {
        if (kerning != null) {
            var map:Map<Int,Int> = kerning.get(p_first);
            if (map != null) {
                if (!map.exists(p_second)) {
                    return 0;
                } else {
                    return map.get(p_second)*g2d_texture.scaleFactor;
                }
            }
        }
		/**/
        return 0;
    }
}