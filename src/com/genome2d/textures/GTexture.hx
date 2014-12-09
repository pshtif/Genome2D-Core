/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.textures;

import com.genome2d.context.GContextFeature;
import com.genome2d.context.IContext;
import com.genome2d.geom.GRectangle;

class GTexture extends GContextTexture
{
	public var g2d_subId:String = "";

    private var g2d_pivotX:Float;
    #if swc @:extern #end
    public var pivotX(get, set):Float;
    #if swc @:getter(pivotX) #end
    inline private function get_pivotX():Float {
        return g2d_pivotX*scaleFactor;
    }
    #if swc @:setter(pivotX) #end
    inline private function set_pivotX(p_value:Float):Float {
        return g2d_pivotX = p_value/scaleFactor;
    }

    private var g2d_pivotY:Float;
    #if swc @:extern #end
    public var pivotY(get, set):Float;
    #if swc @:getter(pivotY) #end
    inline private function get_pivotY():Float {
        return g2d_pivotY*scaleFactor;
    }
    #if swc @:setter(pivotY) #end
    inline private function set_pivotY(p_value:Float):Float {
        return g2d_pivotY = p_value/scaleFactor;
    }

    private var g2d_frame:GRectangle;

    private var g2d_region:GRectangle;
    #if swc @:extern #end
    public var region(get,set):GRectangle;
    #if swc @:getter(nativeSource) #end
    inline private function get_region():GRectangle {
        return g2d_region;
    }
    #if swc @:setter(region) #end
    inline private function set_region(p_value:GRectangle):GRectangle {
        g2d_region = p_value;

        g2d_width = Std.int(g2d_region.width);
        g2d_height = Std.int(g2d_region.height);

        g2d_invalidateUV();

        return g2d_region;
    }

    private function g2d_invalidateUV():Void {
        if (g2d_sourceType == GTextureSourceType.ATLAS) {
            g2d_u = g2d_region.x / g2d_sourceAtlas.gpuWidth;
            g2d_v = g2d_region.y / g2d_sourceAtlas.gpuHeight;

            g2d_uScale = g2d_region.width / g2d_sourceAtlas.gpuWidth;
            g2d_vScale = g2d_region.height / g2d_sourceAtlas.gpuHeight;
        } else {
            g2d_uScale = g2d_region.width / g2d_gpuWidth;
            g2d_vScale = g2d_region.height / g2d_gpuHeight;
        }
    }

    override public function invalidateNativeTexture(p_reinitialize:Bool):Void {
        super.invalidateNativeTexture(p_reinitialize);

        g2d_invalidateUV();
    }

	//public function new(p_id:String, p_source:Dynamic, p_region:GRectangle, p_format:String, p_repeatable:Bool, p_pivotX:Float, p_pivotY:Float, p_scaleFactor:Float, p_parentAtlas:GTextureAtlas) {
    public function new(p_id:String, p_source:Dynamic) {
        super(p_id, p_source);

        g2d_pivotX = g2d_pivotY = 0;

        g2d_init();
	}
}