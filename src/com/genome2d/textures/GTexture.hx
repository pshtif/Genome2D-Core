/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.textures;

import com.genome2d.context.IContext;
import com.genome2d.geom.GRectangle;
class GTexture extends GContextTexture
{
    static public function getTextureById(p_id:String):GTexture {
        return cast GContextTexture.getContextTextureById(p_id);
    }

    inline public function getParentAtlas():GTextureAtlas {
        return cast g2d_parentAtlas;
    }
	
	public var g2d_subId:String = "";

    public function getRegion():GRectangle {
        return g2d_region;
    }
	public function setRegion(p_value:GRectangle):GRectangle {
		if (g2d_parentAtlas != null) {
			uvX = p_value.x / g2d_parentAtlas.width;
			uvY = p_value.y / g2d_parentAtlas.height;
			
			uvScaleX = width / g2d_parentAtlas.width;
			uvScaleY = height / g2d_parentAtlas.height;	
		} else {
            uvScaleX = width / GTextureUtils.getNextValidTextureSize(width);
            uvScaleY = height / GTextureUtils.getNextValidTextureSize(height);
        }
		
		return g2d_region = p_value;
	}

	public function new(p_context:IContext, p_id:String, p_sourceType:Int, p_source:Dynamic, p_region:GRectangle, p_format:String, p_repeatable:Bool, p_pivotX:Float, p_pivotY:Float, p_parentAtlas:GTextureAtlas) {
		super(p_context, p_id, p_sourceType, p_source, p_region, p_format, p_repeatable, p_pivotX, p_pivotY);
		
		g2d_parentAtlas = p_parentAtlas;

        g2d_type = (g2d_parentAtlas == null) ? GTextureType.STANDALONE : GTextureType.SUBTEXTURE;
		
		setRegion(p_region);
		
		pivotX = p_pivotX;
		pivotY = p_pivotY;
				
		invalidateNativeTexture(false);
	}

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

        if (g2d_type == GTextureType.SUBTEXTURE) {
            g2d_gpuWidth = g2d_parentAtlas.gpuWidth;
            g2d_gpuHeight = g2d_parentAtlas.gpuHeight;
        }
    }
	
	/**
	 * 	Dispose this textures
	 */
	override public function dispose():Void {
		g2d_parentAtlas = null;
		
		super.dispose();
	}
}