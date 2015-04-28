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

class GTextureFont {
    public var lineHeight:Int = 0;
    public var g2d_kerning:Map<Int,Map<Int,Int>>;

    public function getCharById(p_subId:String):Void {
        //return cast g2d_subTextures.get(p_subId);
    }

    public function addChar(p_subId:String, p_region:GRectangle, p_frame:GRectangle):Void {
		/*
        var texture:GTextureChar = new GTextureChar(g2d_id+"_"+p_subId, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.g2d_nativeTexture = nativeTexture;
        texture.g2d_scaleFactor = scaleFactor;

        texture.region = p_region;

        g2d_subTextures.set(p_subId, texture);

        return texture;
		/**/
    }

    public function getKerning(p_first:Int, p_second:Int):Float {
		/*
        if (g2d_kerning != null) {
            var map:Map<Int,Int> = g2d_kerning.get(p_first);
            if (map != null) {
                if (!map.exists(p_second)) {
                    return 0;
                } else {
                    return map.get(p_second)*scaleFactor;
                }
            }
        }
		/**/
        return 0;
    }
}