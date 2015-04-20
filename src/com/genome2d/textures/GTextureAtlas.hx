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

@:access(com.genome2d.textures.GTexture)
class GTextureAtlas extends GContextTexture {
    private var g2d_subTextures:Map<String, GTexture>;
    public function getSubTextureById(p_subId:String):GTexture {
        return g2d_subTextures.get(p_subId);
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

    public function new(p_id:String, p_source:Dynamic) {
        super(p_id, p_source);

        g2d_subTextures = new Map<String,GTexture>();

        g2d_init();
    }

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

        for (tex in g2d_subTextures) {
            tex.invalidateNativeTexture(true);
        }
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
            texture.g2d_pivotX = (p_frame.width-p_region.width)*.5 + p_frame.x;
            texture.g2d_pivotY = (p_frame.height-p_region.height)*.5 + p_frame.y;
        }

        texture.region = p_region;

        g2d_subTextures.set(p_subId, texture);

        return texture;
    }

    public function removeSubTexture(p_subId:String):Void {
        g2d_subTextures.get(p_subId).dispose();
        g2d_subTextures.remove(p_subId);
    }

    private function g2d_disposeSubTextures():Void {
        for (key in g2d_subTextures.keys()) {
            g2d_subTextures.get(key).dispose();
            g2d_subTextures.remove(key);
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
