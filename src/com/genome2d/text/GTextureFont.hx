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
    private var g2d_kerning:Map<Int,Map<Int,Int>>;
	
	public function new(p_texture:GTexture):Void {
		g2d_texture = p_texture;
	}

    public function getCharById(p_subId:String):GTextureChar {
        return cast g2d_chars.get(p_subId);
    }

    public function addChar(p_charId:String, p_region:GRectangle, p_frame:GRectangle):GTextureChar {
        var texture:GTexture = new GTexture(g2d_texture.id+"_"+p_charId, g2d_texture);
		texture.region = p_region;
		
		var char:GTextureChar = new GTextureChar(texture);
        g2d_chars.set(p_charId, char);

        return char;
    }

    public function getKerning(p_first:Int, p_second:Int):Float {
        if (g2d_kerning != null) {
            var map:Map<Int,Int> = g2d_kerning.get(p_first);
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