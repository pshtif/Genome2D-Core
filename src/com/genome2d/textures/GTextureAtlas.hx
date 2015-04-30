/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.textures;

#if swc
import flash.utils.Dictionary;
import flash.utils.RegExp;
#end
import UInt;
import com.genome2d.textures.GTexture;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GRectangle;

class GTextureAtlas {
    private var g2d_subTextures:Map<String, GTexture>;
    public function getSubTexture(p_id:String):GTexture {
        return g2d_subTextures.get(p_id);
    }
    public function getSubTextures(p_regExp:EReg = null):Array<GTexture> {
        var found:Array<GTexture> = new Array<GTexture>();
        for (tex in g2d_subTextures) {
            if (p_regExp != null) {
                if (p_regExp.match(tex.id)) {
                    found.push(tex);
                }
            } else {
                found.push(tex);
            }
        }

        return found;
    }

    public function new(p_texture:GTexture) {
        g2d_subTextures = new Map<String,GTexture>();
    }

    public function addSubTexture(p_subId:String, p_region:GRectangle, p_frame:GRectangle):GTexture {
        var texture:GTexture = new GTexture(g2d_id+"_"+p_subId, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.g2d_nativeTexture = nativeTexture;
        texture.g2d_scaleFactor = scaleFactor;
        texture.g2d_atfType = g2d_atfType;
        texture.premultiplied = premultiplied;

        if (p_frame != null) {
            texture.g2d_frame = p_frame;
            texture.pivotX = (p_frame.width-p_region.width)*.5 + p_frame.x;
            texture.pivotY = (p_frame.height-p_region.height)*.5 + p_frame.y;
        }

        texture.region = p_region;

        g2d_subTextures.set(p_subId, texture);

        return null;
    }

    public function removeSubTexture(p_subId:String):Void {
        g2d_subTextures.get(p_subId).dispose();
        g2d_subTextures.remove(p_subId);
    }

    public function dispose():Void {
    }
}
