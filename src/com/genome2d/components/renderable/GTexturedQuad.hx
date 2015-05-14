/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable;

import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.filters.GFilter;
import com.genome2d.context.GCamera;
import com.genome2d.input.GMouseInputType;
import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
import com.genome2d.input.GMouseInput;
import com.genome2d.textures.GTexture;

/**
    Component used for rendering textured quads used as a super class for `GSprite` and `GMovieClip`
**/
class GTexturedQuad extends GComponent implements IRenderable
{
    /**
        Blend mode used for rendering
    **/
    @prototype 
	public var blendMode:Int = 1;

    /**
        Enable/disable pixel perfect mouse detection, not supported by all contexts.
        Default false
    **/
    public var mousePixelEnabled:Bool = false;

    /**
        Specify alpha treshold for pixel perfect mouse detection, works with mousePixelEnabled true
    **/
    public var mousePixelTreshold:Int = 0;

    /**
        Texture used for rendering
    **/
	@reference
	public var texture:GTexture;

    /**
        Filter used for rendering
    **/
    public var filter:GFilter;

    /**
        Renderer should always ignore matrix
    **/
    public var ignoreMatrix:Bool = false;

    @:dox(hide)
    @:access(com.genome2d.Genome2D)
	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		if (texture != null) {
            if (p_useMatrix && !ignoreMatrix) {
                var matrix:GMatrix = node.core.g2d_renderMatrix;
                node.core.getContext().drawMatrix(texture, matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty, node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha, blendMode, filter);
            } else {
                node.core.getContext().draw(texture, node.g2d_worldX, node.g2d_worldY, node.g2d_worldScaleX, node.g2d_worldScaleY, node.g2d_worldRotation, node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha, blendMode, filter);
            }
		}
	}

	/**
        Check if a point is inside this quad
    **/
    inline public function hitTest(p_x:Float, p_y:Float):Bool {
		var hit:Bool = false;
		if (texture != null) {
			p_x = p_x / texture.width + .5;
			p_y = p_y / texture.height + .5;

			hit = (p_x >= -texture.pivotX / texture.width && p_x <= 1 - texture.pivotX / texture.width && p_y >= -texture.pivotY / texture.height && p_y <= 1 - texture.pivotY / texture.height &&
				  (!mousePixelEnabled || texture.getAlphaAtUV(p_x + texture.pivotX / texture.width, p_y + texture.pivotY / texture.height) <= mousePixelTreshold));
		}
		return hit;
    }

	inline public function captureMouseInput(p_input:GMouseInput):Void {
        p_input.g2d_captured = p_input.g2d_captured || hitTest(p_input.localX, p_input.localY);
	}

	/**
        Get local bounds
    **/
    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (texture == null) {
            if (p_bounds != null) p_bounds.setTo(0, 0, 0, 0);
            else p_bounds = new GRectangle(0, 0, 0, 0);
        } else {
            if (p_bounds != null) p_bounds.setTo(-texture.width*.5-texture.pivotX, -texture.height*.5-texture.pivotY, texture.width, texture.height);
            else p_bounds = new GRectangle( -texture.width * .5 - texture.pivotX, -texture.height * .5 - texture.pivotY, texture.width, texture.height);
        }

        return p_bounds;
    }

/*
public function hitTestObject(p_sprite:GTexturedQuad):Boolean {
			var tvs1:Vector.<Number> = p_sprite.getTransformedVertices3D();
			var tvs2:Vector.<Number> = getTransformedVertices3D();

			var cx:Number = (tvs1[0]+tvs1[3]+tvs1[6]+tvs1[9])/4;
			var cy:Number = (tvs1[1]+tvs1[4]+tvs1[7]+tvs1[10])/4;

			if (isSeparating(tvs1[3], tvs1[4], tvs1[0]-tvs1[3], tvs1[1]-tvs1[4], cx, cy, tvs2)) return false;

			if (isSeparating(tvs1[6], tvs1[7], tvs1[3]-tvs1[6], tvs1[4]-tvs1[7], cx, cy, tvs2)) return false;

			if (isSeparating(tvs1[9], tvs1[10], tvs1[6]-tvs1[9], tvs1[7]-tvs1[10], cx, cy, tvs2)) return false;

			if (isSeparating(tvs1[0], tvs1[1], tvs1[9]-tvs1[0], tvs1[10]-tvs1[1], cx, cy, tvs2)) return false;

			cx = (tvs2[0]+tvs2[3]+tvs2[6]+tvs2[9])/4;
			cy = (tvs2[1]+tvs2[4]+tvs2[7]+tvs2[10])/4;

			if (isSeparating(tvs2[3], tvs2[4], tvs2[0]-tvs2[3], tvs2[1]-tvs2[4], cx, cy, tvs1)) return false;

			if (isSeparating(tvs2[6], tvs2[7], tvs2[3]-tvs2[6], tvs2[4]-tvs2[7], cx, cy, tvs1)) return false;

			if (isSeparating(tvs2[9], tvs2[10], tvs2[6]-tvs2[9], tvs2[7]-tvs2[10], cx, cy, tvs1)) return false;

			if (isSeparating(tvs2[0], tvs2[1], tvs2[9]-tvs2[0], tvs2[10]-tvs2[1], cx, cy, tvs1)) return false;

			return true;
		}

		private function isSeparating(p_sx:Number, p_sy:Number, p_ex:Number, p_ey:Number, p_cx:Number, p_cy:Number, p_vertices:Vector.<Number>):Boolean {
			var rx:Number = -p_ey;
			var ry:Number = p_ex;

			var sideCenter:Number = rx * (p_cx - p_sx) + ry * (p_cy - p_sy);

			var sideV1:Number = rx * (p_vertices[0] - p_sx) + ry * (p_vertices[1] - p_sy);
			var sideV2:Number = rx * (p_vertices[3] - p_sx) + ry * (p_vertices[4] - p_sy);
			var sideV3:Number = rx * (p_vertices[6] - p_sx) + ry * (p_vertices[7] - p_sy);
			var sideV4:Number = rx * (p_vertices[9] - p_sx) + ry * (p_vertices[10] - p_sy);

			if (sideCenter < 0 && sideV1 >= 0 && sideV2 >= 0 && sideV3 >= 0 && sideV4 >= 0) return true;
			if (sideCenter > 0 && sideV1 <= 0 && sideV2 <= 0 && sideV3 <= 0 && sideV4 <= 0) return true;

			return false;
		}
 */
}