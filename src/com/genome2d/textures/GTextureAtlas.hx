/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.textures;

#if flash
import flash.utils.Dictionary;
#end
import com.genome2d.textures.GTexture;
import com.genome2d.context.IContext;
import com.genome2d.geom.GRectangle;

class GTextureAtlas extends GContextTexture {
    static public function getTextureAtlasById(p_id:String):GTextureAtlas {
        return cast GContextTexture.getContextTextureById(p_id);
    }

    #if flash
    private var g2d_textures:Dictionary;
    public function getSubTexture(p_subId:String):GTexture {
        return untyped g2d_textures[p_subId];
    }
    #else
    private var g2d_textures:Map<String, GTexture>;
    public function getSubTexture(p_subId:String):GTexture {
        return g2d_textures.get(p_subId);
    }
    #end

    public function new(p_context:IContext, p_id:String, p_sourceType:Int, p_source:Dynamic, p_region:GRectangle, p_format:String, p_uploadCallback:Void->Void) {
        super(p_context, p_id, p_sourceType, p_source, p_region, p_format, false, 0, 0);

        g2d_type = GTextureType.ATLAS;
        #if flash
        g2d_textures = new Dictionary(false);
        #else
        g2d_textures = new Map<String,GTexture>();
        #end
    }

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

        #if flash
        var textureIds:Array<String> = untyped __keys__(g2d_textures);
        for (i in 0...textureIds.length) {
            var texture:GTexture = untyped g2d_textures[textureIds[i]];
            texture.nativeTexture = nativeTexture;
            texture.g2d_gpuWidth = g2d_gpuWidth;
            texture.g2d_gpuHeight = g2d_gpuHeight;
        }
        #else
        for (key in g2d_textures.keys()) {
            var texture:GTexture = g2d_textures.get(key);
            texture.nativeTexture = nativeTexture;
            texture.g2d_gpuWidth = g2d_gpuWidth;
            texture.g2d_gpuHeight = g2d_gpuHeight;
        }
        #end
    }

    public function addSubTexture(p_subId:String, p_region:GRectangle, p_pivotX:Float = 0, p_pivotY:Float = 0):GTexture {
        var texture:GTexture = new GTexture(g2d_context, g2d_id+"_"+p_subId, g2d_sourceType, g2d_nativeSource, p_region, g2d_format, false, p_pivotX, p_pivotY, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.nativeTexture = nativeTexture;

        #if flash
        untyped g2d_textures[p_subId] = texture;
        #else
        g2d_textures.set(p_subId, texture);
        #end

        return texture;
    }

    public function removeSubTexture(p_subId:String):Void {
        #if flash
        untyped g2d_textures[p_subId].dispose();
        untyped __delete__(g2d_textures, p_subId);
        #else
        g2d_textures.get(p_subId).dispose();
        g2d_textures.remove(p_subId);
        #end
    }

    private function g2d_disposeSubTextures():Void {
        #if flash
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
