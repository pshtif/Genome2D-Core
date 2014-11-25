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
import com.genome2d.context.IContext;
import com.genome2d.geom.GRectangle;

class GTextureAtlas extends GContextTexture {
    private var g2d_textures:Map<String, GTexture>;
    public function getSubTexture(p_subId:String):GTexture {
        return g2d_textures.get(p_subId);
    }
    public function getSubTextures(p_regExp:EReg = null) {
        var found:Array<GTexture> = new Array<GTexture>();
        for (tex in g2d_textures) {
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

    public function new(p_id:String, p_sourceType:Int, p_source:Dynamic, p_region:GRectangle, p_format:String, p_scaleFactor:Float, p_uploadCallback:Void->Void) {
        super(p_id, p_sourceType, p_source, p_region, p_format, false, 0, 0, p_scaleFactor);

        g2d_type = GTextureType.ATLAS;
        g2d_textures = new Map<String,GTexture>();
    }

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

        for (tex in g2d_textures) {
            tex.g2d_nativeTexture = g2d_nativeTexture;
            tex.g2d_gpuWidth = g2d_gpuWidth;
            tex.g2d_gpuHeight = g2d_gpuHeight;
        }
    }

    public function addSubTexture(p_subId:String, p_region:GRectangle, p_frame:GRectangle):GTexture {
        var texture:GTexture = new GTexture(g2d_id+"_"+p_subId, g2d_nativeSourceType, g2d_nativeSource, p_region, g2d_format, false, 0, 0, g2d_scaleFactor, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.g2d_nativeTexture = nativeTexture;

        if (p_frame != null) {
            texture.pivotX = (p_frame.width-p_region.width)*.5 + p_frame.x;
            texture.pivotY = (p_frame.height-p_region.height)*.5 + p_frame.y;
        }
        texture.g2d_frame = p_frame;

        g2d_textures.set(p_subId, texture);

        return texture;
    }

    public function removeSubTexture(p_subId:String):Void {
        g2d_textures.get(p_subId).dispose();
        g2d_textures.remove(p_subId);
    }

    private function g2d_disposeSubTextures():Void {
        for (key in g2d_textures.keys()) {
            g2d_textures.get(key).dispose();
            g2d_textures.remove(key);
        }
    }

    /**
	 * 	Dispose this atlas and all its sub textures
	 */
    override public function dispose():Void {
        g2d_disposeSubTextures();

        super.dispose();
    }
}
