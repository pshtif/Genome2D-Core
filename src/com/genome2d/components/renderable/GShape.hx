/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable;

import com.genome2d.context.IGRenderer;
import com.genome2d.input.GMouseInput;
import com.genome2d.debug.GDebug;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GBlendMode;
import com.genome2d.context.GCamera;
import com.genome2d.textures.GTexture;

/**
    Component used for shape rendering
**/
class GShape extends GComponent implements IGRenderable
{
    public var texture:GTexture;
    public var blendMode:GBlendMode;

    private var g2d_vertices:Array<Float>;
    private var g2d_uvs:Array<Float>;

    private var g2d_shapeRenderer:IGRenderer;
    private var g2d_bounds:GRectangle;

    override public function init():Void {
        blendMode = GBlendMode.NORMAL;

        g2d_bounds = new GRectangle(0,0,0,0);
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        if (texture == null || g2d_vertices == null || g2d_uvs == null) return;
        if (g2d_shapeRenderer == null) {
            node.core.getContext().drawPoly(texture, blendMode, g2d_vertices, g2d_uvs, node.g2d_worldX, node.g2d_worldY, node.g2d_worldScaleX, node.g2d_worldScaleY, node.g2d_worldRotation, node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha, null);
        } else {
            node.core.getContext().setRenderer(g2d_shapeRenderer);
            untyped g2d_shapeRenderer.draw(texture);
        }
    }

    public function setup(p_vertices:Array<Float>, p_uvs:Array<Float>, p_calculateBounds:Bool = true):Void {
        if (p_vertices == null || p_uvs == null) GDebug.error("Vertices and UVs can't be null.");
        if (p_vertices.length == 0) GDebug.error("Shape can't have 0 vertices.");
        if (p_vertices.length != p_uvs.length) GDebug.error("Vertices and UVs need to have same amount of values.");
        g2d_vertices = p_vertices;
        // Calculate bounds
        if (p_calculateBounds) {
            for (i in 0...g2d_vertices.length>>1) {
                var vx:Float = g2d_vertices[i*2];
                var vy:Float = g2d_vertices[i*2+1];
                if (vx<g2d_bounds.left) g2d_bounds.left = vx;
                if (vx>g2d_bounds.right) g2d_bounds.right = vx;
                if (vy<g2d_bounds.top) g2d_bounds.top = vy;
                if (vy>g2d_bounds.bottom) g2d_bounds.bottom = vy;
            }
        }

        g2d_uvs = p_uvs;
    }

    public function cache():Void {
        //g2d_shapeRenderer = new GCustomRenderer(g2d_vertices, g2d_uvs, false);
    }

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (p_bounds != null) {
            p_bounds.setTo(g2d_bounds.x, g2d_bounds.y, g2d_bounds.width, g2d_bounds.height);
        } else {
            p_bounds = g2d_bounds.clone();
        }

        return p_bounds;
    }

    public function captureMouseInput(p_input:GMouseInput):Void {
        p_input.captured = p_input.captured || hitTest(p_input.localX, p_input.localY);
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
        var hit:Bool = g2d_bounds.contains(p_x, p_y);

        return hit;
    }
}