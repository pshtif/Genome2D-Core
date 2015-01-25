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
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.textures.GTexture;

/**
    Component used for rendering textured quads used as a super class for `GSprite` and `GMovieClip`
**/
class GTexturedQuad extends GComponent implements IRenderable
{
    /**
        Blend mode used for rendering
    **/
    @prototype public var blendMode:Int = 1;

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
	public var texture:GTexture;

    /**
        Filter used for rendering
    **/
    public var filter:GFilter;

    public var ignoreMatrix:Bool = false;

    @:dox(hide)
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
    public function hitTestPoint(p_x:Float, p_y:Float, p_pixelEnabled:Bool = false, p_w:Float = 0, p_h:Float = 0):Bool {
        var tx:Float = p_x - node.g2d_worldX;
        var ty:Float = p_y - node.g2d_worldY;

        if (node.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.g2d_worldRotation);
            var sin:Float = Math.sin(-node.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.g2d_worldScaleX*texture.width;
        ty /= node.g2d_worldScaleY*texture.height;

        if (p_w != 0) p_w /= node.g2d_worldScaleX*texture.width;
        if (p_h != 0) p_h /= node.g2d_worldScaleY*texture.height;

        tx += .5;
        ty += .5;

        if (tx+p_w >= -texture.pivotX / texture.width && tx-p_w <= 1 - texture.pivotX / texture.width && ty+p_h >= -texture.pivotY / texture.height && ty-p_h <= 1 - texture.pivotY / texture.height) {
            if (p_pixelEnabled && texture.getAlphaAtUV(tx+texture.pivotX/texture.width, ty+texture.pivotY/texture.height) <= mousePixelTreshold) {
                return false;
            }
            return true;
        }

        return false;
    }

    @:dox(hide)
	public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
		if (p_captured && p_contextSignal.type == GMouseSignalType.MOUSE_UP) node.g2d_mouseDownNode = null;

		if (p_captured || texture == null || texture.width == 0 || texture.height == 0 || node.g2d_worldScaleX == 0 || node.g2d_worldScaleY == 0) {
			if (node.g2d_mouseOverNode == node) node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, 0, 0, p_contextSignal);
			return false;
		}

        // Invert translations
        var tx:Float = p_cameraX - node.g2d_worldX;
        var ty:Float = p_cameraY - node.g2d_worldY;

        if (node.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.g2d_worldRotation);
            var sin:Float = Math.sin(-node.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.g2d_worldScaleX*texture.width;
        ty /= node.g2d_worldScaleY*texture.height;

        tx += .5;
        ty += .5;

		if (tx >= -texture.pivotX / texture.width && tx <= 1 - texture.pivotX / texture.width && ty >= -texture.pivotY / texture.height && ty <= 1 - texture.pivotY / texture.height) {
			if (mousePixelEnabled && texture.getAlphaAtUV(tx+texture.pivotX/texture.width, ty+texture.pivotY/texture.height) <= mousePixelTreshold) {
				if (node.g2d_mouseOverNode == node) {
					node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
				}
				return false;
			}

			node.dispatchNodeMouseSignal(p_contextSignal.type, node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
			if (node.g2d_mouseOverNode != node) {
				node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
			}
			
			return true;
		} else {
			if (node.g2d_mouseOverNode == node) {
				node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*texture.width-texture.width*.5, ty*texture.height-texture.height*.5, p_contextSignal);
			}
		}
		
		return false;
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
            else p_bounds = new GRectangle(-texture.width*.5-texture.pivotX, -texture.height*.5-texture.pivotY, texture.width, texture.height);
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