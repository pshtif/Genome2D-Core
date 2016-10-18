/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.postprocess;

import com.genome2d.context.GBlendMode;
import com.genome2d.utils.GRenderTargetStack;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GRectangle;
import com.genome2d.node.GNode;
import com.genome2d.context.GCamera;
import com.genome2d.context.filters.GFilter;
import com.genome2d.context.filters.GHDRPassFilter;
import com.genome2d.textures.GTexture;

class GHDRPP extends GPostProcess
{
    private var g2d_empty:GFilterPP;
    private var g2d_blur:GBlurPP;
    private var g2d_hdrPassFilter:GHDRPassFilter;

    #if swc @:extern #end
    public var blurX(get, set):Int;
    #if swc @:getter(blurX) #end
    public function get_blurX():Int {
        return g2d_blur.blurX;
    }
    #if swc @:setter(blurX) #end
    public function set_blurX(p_value:Int):Int {
        g2d_blur.blurX = p_value;
        g2d_leftMargin = g2d_rightMargin = p_value*2*g2d_blur.passes;
        g2d_empty.setMargins(g2d_leftMargin, g2d_rightMargin, g2d_topMargin, g2d_bottomMargin);
        return p_value;
    }

    #if swc @:extern #end
    public var blurY(get, set):Int;
    #if swc @:getter(blurY) #end
    public function get_blurY():Int {
        return g2d_blur.blurY;
    }
    #if swc @:setter(blurY) #end
    public function set_blurY(p_value:Int):Int {
        g2d_blur.blurY = p_value;
        g2d_topMargin = g2d_bottomMargin = p_value*2*g2d_blur.passes;
        g2d_empty.setMargins(g2d_leftMargin, g2d_rightMargin, g2d_topMargin, g2d_bottomMargin);
        return p_value;
    }

    #if swc @:extern #end
    public var saturation(get, set):Float;
    #if swc @:getter(saturation) #end
    public function get_saturation():Float {
        return g2d_hdrPassFilter.saturation;
    }
    #if swc @:setter(saturation) #end
    public function set_saturation(p_value:Float):Float {
        g2d_hdrPassFilter.saturation = p_value;
        return p_value;
    }

    public function new(p_blurX:Int = 3, p_blurY:Int = 3, p_blurPasses:Int = 2, p_saturation:Float = 1.3) {
        super(2);

        g2d_leftMargin = g2d_rightMargin = p_blurX*2*p_blurPasses;
        g2d_topMargin = g2d_bottomMargin = p_blurY*2*p_blurPasses;

        g2d_empty = new GFilterPP([null]);
        g2d_empty.setMargins(g2d_leftMargin, g2d_rightMargin, g2d_topMargin, g2d_bottomMargin);

        g2d_blur = new GBlurPP(p_blurX, p_blurY, p_blurPasses);

        g2d_hdrPassFilter = new GHDRPassFilter(p_saturation);
    }

    override public function render(p_source:GTexture, p_x:Float, p_y:Float, p_bounds:GRectangle = null, p_target:GTexture = null):Void {
        var bounds:GRectangle = (p_bounds == null) ? g2d_definedBounds : p_bounds;
        // Invalid bounds
        if (bounds.x > 4096) return;

        updatePassTextures(bounds);

        var context:IGContext = Genome2D.getInstance().getContext();
        if (p_target == null) GRenderTargetStack.pushRenderTarget(context.getRenderTarget(),context.getRenderTargetMatrix());

        g2d_empty.render(p_source,p_x,p_y,bounds,g2d_passTextures[0]);
        g2d_blur.render(g2d_passTextures[0], 0, 0, bounds, g2d_passTextures[1]);

        g2d_hdrPassFilter.texture = g2d_empty.getPassTexture(0);

        if (p_target == null) {
            GRenderTargetStack.popRenderTarget(context);
            context.draw(g2d_passTextures[1], GBlendMode.NORMAL, bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, g2d_hdrPassFilter);
        } else {
            context.setRenderTarget(p_target);
            context.draw(g2d_passTextures[1], GBlendMode.NORMAL, bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, g2d_hdrPassFilter);
        }
    }

    override public function renderNode(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GCamera, p_node:GNode, p_bounds:GRectangle = null, p_source:GTexture = null, p_target:GTexture = null):Void {
        var bounds:GRectangle = (g2d_definedBounds != null) ? g2d_definedBounds : p_node.getBounds(null, g2d_activeBounds);

        // Invalid bounds
        if (bounds.x > 4096) return;

        updatePassTextures(bounds);

        g2d_empty.renderNode(p_parentTransformUpdate, p_parentColorUpdate, p_camera, p_node, bounds, null, g2d_passTextures[0]);
        g2d_blur.renderNode(p_parentTransformUpdate, p_parentColorUpdate, p_camera, p_node, bounds, g2d_passTextures[0], g2d_passTextures[1]);

        g2d_hdrPassFilter.texture = g2d_empty.getPassTexture(0);

        var context:IGContext = Genome2D.getInstance().getContext();

        context.setRenderTarget(null);
        context.setActiveCamera(p_camera);
        context.draw(g2d_passTextures[1], GBlendMode.NORMAL, bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, g2d_hdrPassFilter);
    }

    override public function dispose():Void {
        g2d_blur.dispose();

        super.dispose();
    }
}