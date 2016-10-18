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
import com.genome2d.node.GNode;
import com.genome2d.context.GCamera;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.filters.GBloomPassFilter;
import com.genome2d.context.filters.GBrightPassFilter;
import com.genome2d.context.filters.GFilter;
import com.genome2d.textures.GTexture;

class GBloomPP extends GPostProcess
{
    private var g2d_blur:GBlurPP;
    private var g2d_bright:GFilterPP;
    private var g2d_bloomFilter:GBloomPassFilter;

    public function new(p_blurX:Int = 2, p_blurY:Int = 2, p_blurPasses:Int = 1, p_brightTreshold:Float=.2) {
        super(2);

        g2d_blur = new GBlurPP(p_blurX, p_blurY, p_blurPasses);

        g2d_bright = new GFilterPP([new GBrightPassFilter(p_brightTreshold)]);

        g2d_bloomFilter = new GBloomPassFilter();

        g2d_leftMargin = g2d_rightMargin = Std.int(g2d_blur.blurX*g2d_blur.passes*.5);
        g2d_topMargin = g2d_bottomMargin = Std.int(g2d_blur.blurY*g2d_blur.passes*.5);
        g2d_bright.setMargins(g2d_leftMargin, g2d_rightMargin, g2d_topMargin, g2d_bottomMargin);
    }

    override public function render(p_source:GTexture, p_x:Float, p_y:Float, p_bounds:GRectangle = null, p_target:GTexture = null):Void {
        var bounds:GRectangle = (p_bounds == null) ? g2d_definedBounds : p_bounds;

        // Invalid bounds
        if (bounds.width > 4096) return;

        updatePassTextures(bounds);

        var context:IGContext = Genome2D.getInstance().getContext();

        if (p_target == null) GRenderTargetStack.pushRenderTarget(context.getRenderTarget(), context.getRenderTargetMatrix());

        g2d_bright.render(p_source, p_x, p_y, bounds, g2d_passTextures[0]);
        g2d_blur.render(g2d_passTextures[0], 0, 0, bounds, g2d_passTextures[1]);

        g2d_bloomFilter.texture = g2d_bright.getPassTexture(0);
        if (p_target == null) {
            GRenderTargetStack.popRenderTarget(context);
            context.draw(g2d_passTextures[1], GBlendMode.NORMAL, bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, g2d_bloomFilter);
        } else {
            context.setRenderTarget(p_target);
            context.draw(g2d_passTextures[1], GBlendMode.NORMAL, bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, g2d_bloomFilter);
        }
    }

    override public function renderNode(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GCamera, p_node:GNode, p_bounds:GRectangle = null, p_source:GTexture = null, p_target:GTexture = null):Void {
        var bounds:GRectangle = (g2d_definedBounds != null) ? g2d_definedBounds : p_node.getBounds(null, g2d_activeBounds);

        // Invalid bounds
        if (bounds.width > 4096) return;

        updatePassTextures(bounds);

        var context:IGContext = Genome2D.getInstance().getContext();

        g2d_bright.renderNode(p_parentTransformUpdate, p_parentColorUpdate, p_camera, p_node, bounds, null, g2d_passTextures[0]);
        g2d_blur.renderNode(p_parentTransformUpdate, p_parentColorUpdate, p_camera, p_node, bounds, g2d_passTextures[0], g2d_passTextures[1]);

        g2d_bloomFilter.texture = g2d_bright.getPassTexture(0);

        context.setRenderTarget(null);
        context.setActiveCamera(p_camera);
        context.draw(g2d_passTextures[1], GBlendMode.NORMAL, bounds.x-g2d_leftMargin, bounds.y-g2d_topMargin, 1, 1, 0, 1, 1, 1, 1, g2d_bloomFilter);
    }

    override public function dispose():Void {
        g2d_blur.dispose();
        g2d_bright.dispose();

        super.dispose();
    }
}