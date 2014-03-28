package com.genome2d.textures;

import com.genome2d.utils.GMap;
import com.genome2d.context.IContext;
import com.genome2d.geom.GRectangle;

class GTextureAtlas extends GContextTexture {
    static public function getTextureAtlasById(p_id:String):GTextureAtlas {
        return cast GContextTexture.getContextTextureById(p_id);
    }

    private var g2d_textures:GMap<String, GTexture>;
    public function getSubTexture(p_subId:String):GTexture {
        return g2d_textures.get(p_subId);
    }

    public function new(p_context:IContext, p_id:String, p_sourceType:Int, p_source:Dynamic, p_region:GRectangle, p_format:String, p_uploadCallback:Void->Void) {
        super(p_context, p_id, p_sourceType, p_source, p_region, p_format, 0, 0);

        g2d_type = GTextureType.ATLAS;
        g2d_textures = new GMap<String,GTexture>();
    }

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

		for (t in g2d_textures) {
			t.nativeTexture = nativeTexture;
		}
    }

    public function addSubTexture(p_subId:String, p_region:GRectangle, p_pivotX:Float = 0, p_pivotY:Float = 0):GTexture {
        var texture:GTexture = new GTexture(g2d_context, g2d_id+"_"+p_subId, g2d_sourceType, g2d_nativeSource, p_region, g2d_format, p_pivotX, p_pivotY, this);
        texture.g2d_subId = p_subId;
        texture.g2d_filteringType = g2d_filteringType;
        texture.nativeTexture = nativeTexture;

        g2d_textures.set(p_subId, texture);
		
        return texture;
    }

    public function removeSubTexture(p_subId:String):Void {
        g2d_textures.get(p_subId).dispose();
        g2d_textures.remove(p_subId);
    }

    private function g2d_disposeSubTextures():Void {
		for (t in g2d_textures) {
            t.dispose();
        }
		g2d_textures = new GMap<String,GTexture>();
		/*for (key in g2d_textures.keys()) {
            g2d_textures.get(key).dispose();
            g2d_textures.remove(key);
        }*/
    }

    /**
	 * 	Dispose this atlas and all its sub textures
	 */
    override public function dispose():Void {
        g2d_disposeSubTextures();

        super.dispose();
    }
}
