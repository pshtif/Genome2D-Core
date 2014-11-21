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
    static public function getTextureAtlasById(p_id:String):GTextureAtlas {
        return cast GContextTexture.getContextTextureById(p_id);
    }

    #if swc
    private var g2d_textures:Dictionary;
    public function getSubTexture(p_subId:String):GTexture {
        return untyped g2d_textures[p_subId];
    }
    public function getSubTextures(p_regExp:RegExp = null):Array<GTexture> {
        var found:Array<GTexture> = new Array<GTexture>();
        var textureIds:Array<String> = untyped __keys__(g2d_textures);
        for (i in 0...textureIds.length) {
            var textures:GTexture = untyped g2d_textures[textureIds[i]];
            if (p_regExp != null) {
                if (p_regExp.test(textures.getId())) {
                    found.push(textures);
                }
            } else {
                found.push(textures);
            }
        }

        return found;
    }
    #else
    private var g2d_textures:Map<String, GTexture>;
    public function getSubTexture(p_subId:String):GTexture {
        return g2d_textures.get(p_subId);
    }
    public function getSubTextures(p_regExp:EReg = null) {
        var found:Array<GTexture> = new Array<GTexture>();
        for (tex in g2d_textures) {
            if (p_regExp != null) {
                if (p_regExp.match(tex.getId())) {
                    found.push(tex);
                }
            } else {
                found.push(tex);
            }
        }

        return found;
    }
    #end

    public function new(p_context:IContext, p_id:String, p_sourceType:Int, p_source:Dynamic, p_region:GRectangle, p_format:String, p_scaleFactor:Float, p_uploadCallback:Void->Void) {
        super(p_context, p_id, p_sourceType, p_source, p_region, p_format, false, 0, 0, p_scaleFactor);

        g2d_type = GTextureType.ATLAS;
        #if swc
        g2d_textures = new Dictionary(false);
        #else
        g2d_textures = new Map<String,GTexture>();
        #end
    }

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

        #if swc
        var textureIds:Array<String> = untyped __keys__(g2d_textures);
        for (i in 0...textureIds.length) {
            var textures:GTexture = untyped g2d_textures[textureIds[i]];
            textures.nativeTexture = nativeTexture;
            textures.g2d_gpuWidth = g2d_gpuWidth;
            textures.g2d_gpuHeight = g2d_gpuHeight;
        }
        #else
        for (tex in g2d_textures) {
            tex.nativeTexture = nativeTexture;
            tex.g2d_gpuWidth = g2d_gpuWidth;
            tex.g2d_gpuHeight = g2d_gpuHeight;
        }
        #end
    }

    public function addSubTexture(p_subId:String, p_region:GRectangle, p_frameX:Int, p_frameY:Int, p_frameWidth:Int, p_frameHeight:Int):GTexture {
        var texture:GTexture = new GTexture(g2d_context, g2d_id+"_"+p_subId, g2d_sourceType, g2d_nativeSource, p_region, g2d_format, false, 0, 0, g2d_scaleFactor, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.nativeTexture = nativeTexture;

        texture.pivotX = (p_frameWidth-p_region.width)*.5 + p_frameX;
        texture.pivotY = (p_frameHeight-p_region.height)*.5 + p_frameY;
        texture.frameX = p_frameX;
        texture.frameY = p_frameY;
        texture.frameWidth = p_frameWidth;
        texture.frameHeight = p_frameHeight;

        #if swc
        untyped g2d_textures[p_subId] = textures;
        #else
        g2d_textures.set(p_subId, texture);
        #end

        return texture;
    }

    public function removeSubTexture(p_subId:String):Void {
        #if swc
        untyped g2d_textures[p_subId].dispose();
        untyped __delete__(g2d_textures, p_subId);
        #else
        g2d_textures.get(p_subId).dispose();
        g2d_textures.remove(p_subId);
        #end
    }

    private function g2d_disposeSubTextures():Void {
        #if swc
        var textureIds:Array<String> = untyped __keys__(g2d_textures);
        for (i in 0...textureIds.length) {
            untyped g2d_textures[textureIds[i]].dispose();
            untyped __delete__(g2d_textures, textureIds[i]);
        }
        #else
        for (key in g2d_textures.keys()) {
            g2d_textures.get(key).dispose();
            g2d_textures.remove(key);
        }
        #end
    }

    /**
	 * 	Dispose this atlas and all its sub textures
	 */
    override public function dispose():Void {
        g2d_disposeSubTextures();

        super.dispose();
    }
}
