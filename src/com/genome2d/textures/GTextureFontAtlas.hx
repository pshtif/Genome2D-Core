/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.textures;

import com.genome2d.geom.GRectangle;
class GTextureFontAtlas extends GTextureAtlas
{
    public var lineHeight:Int = 0;
    public var g2d_kerning:Map<Int,Map<Int,Int>>;

    static public function getTextureFontAtlasById(p_id:String):GTextureFontAtlas {
        return cast GContextTexture.getContextTextureById(p_id);
    }

    #if swc
    override public function getSubTexture(p_subId:String):GCharTexture {
        return untyped g2d_textures[p_subId];
    }
    #else
    override public function getSubTexture(p_subId:String):GCharTexture {
        return cast g2d_textures.get(p_subId);
    }
    #end

    override public function addSubTexture(p_subId:String, p_region:GRectangle, p_pivotX:Float = 0, p_pivotY:Float = 0):GCharTexture {
        var texture:GCharTexture = new GCharTexture(g2d_context, g2d_id+"_"+p_subId, g2d_sourceType, g2d_nativeSource, p_region, g2d_format, false, p_pivotX, p_pivotY, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.nativeTexture = nativeTexture;

        #if swc
        untyped g2d_textures[p_subId] = texture;
        #else
        g2d_textures.set(p_subId, texture);
        #end

        return texture;
    }

    public function getKerning(p_first:Int, p_second:Int):Int {
        if (g2d_kerning != null) {
            var map:Map<Int,Int> = g2d_kerning.get(p_first);
            if (map != null) {
                if (!map.exists(p_second)) {
                    return 0;
                } else {
                    return map.get(p_second);
                }
            }
        }

        return 0;
    }
}