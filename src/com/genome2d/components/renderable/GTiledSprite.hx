package com.genome2d.components.renderable;

import com.genome2d.signals.GMouseSignalType;
import com.genome2d.signals.GMouseSignal;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.GCamera;
import com.genome2d.context.filters.GFilter;
import com.genome2d.textures.GTexture;

class GTiledSprite extends GComponent implements IRenderable {
    /**
        Blend mode used for rendering
    **/
    public var blendMode:Int = 1;

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

    public var ignoreMatrix:Bool = true;

    private var g2d_width:Float = 110;
    @prototype public var width(get, set):Float;
    #if swc @:getter(width) #end
    inline private function get_width():Float {
        return g2d_width;
    }
    #if swc @:setter(width) #end
    inline private function set_width(p_value:Float):Float {
        return g2d_width = p_value;
    }

    private var g2d_height:Float = 110;
    @prototype public var height(get, set):Float;
    #if swc @:getter(height) #end
    inline private function get_height():Float {
        return g2d_height;
    }
    #if swc @:setter(height) #end
    inline private function set_height(p_value:Float):Float {
        return g2d_height = p_value;
    }

    @:dox(hide)
    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        if (texture == null) return;

        // Check rotations
        var sin:Float = 0;
        var cos:Float = 1;
        if (node.transform.g2d_worldRotation != 0) {
            sin = Math.sin(node.transform.g2d_worldRotation);
            cos = Math.cos(node.transform.g2d_worldRotation);
        }

        var ix:Int = Math.ceil(g2d_width/texture.width);
        var iy:Int = Math.ceil(g2d_height/texture.height);

        var w:Float = texture.region.width;
        var h:Float = texture.region.height;
        var cw:Float = w;
        var ch:Float = h;
        var cx:Float = 0;
        var cy:Float = 0;

        for (j in 0...iy) {
            for (i in 0...ix) {
                cw = (i==ix-1 && g2d_width%texture.width!=0) ? w*(g2d_width%texture.width)/texture.width : w;
                ch = (j==iy-1 && g2d_height%texture.height!=0) ? h*(g2d_height%texture.height)/texture.height : h;

                node.core.getContext().drawSource(texture,
                                                  texture.region.x, texture.region.y, cw, ch, -cw*.5, -ch*.5,
                                                  node.transform.g2d_worldX+cx*cos-cy*sin, node.transform.g2d_worldY+cy*cos+cx*sin, node.transform.g2d_worldScaleX, node.transform.g2d_worldScaleY, node.transform.g2d_worldRotation,
                                                  node.transform.g2d_worldRed, node.transform.g2d_worldGreen, node.transform.g2d_worldBlue, node.transform.g2d_worldAlpha,
                                                  blendMode, filter);
                cx += cw*node.transform.g2d_worldScaleX;
            }
            cx = 0;
            cy += ch*node.transform.g2d_worldScaleY;
        }
    }

    @:dox(hide)
    override public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
        if (p_captured && p_contextSignal.type == GMouseSignalType.MOUSE_UP) node.g2d_mouseDownNode = null;

        if (p_captured || texture == null || g2d_width == 0 || g2d_height == 0 || node.transform.g2d_worldScaleX == 0 || node.transform.g2d_worldScaleY == 0) {
            if (node.g2d_mouseOverNode == node) node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, 0, 0, p_contextSignal);
            return false;
        }

        // Invert translations
        var tx:Float = p_cameraX - node.transform.g2d_worldX;
        var ty:Float = p_cameraY - node.transform.g2d_worldY;

        if (node.transform.g2d_worldRotation != 0) {
            var cos:Float = Math.cos(-node.transform.g2d_worldRotation);
            var sin:Float = Math.sin(-node.transform.g2d_worldRotation);

            var ox:Float = tx;
            tx = (tx*cos - ty*sin);
            ty = (ty*cos + ox*sin);
        }

        tx /= node.transform.g2d_worldScaleX*g2d_width;
        ty /= node.transform.g2d_worldScaleY*g2d_height;

        if (tx >= 0 && tx <= 1 && ty >= 0 && ty <= 1) {
            node.dispatchNodeMouseSignal(p_contextSignal.type, node, tx*g2d_width, ty*g2d_height, p_contextSignal);
            if (node.g2d_mouseOverNode != node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OVER, node, tx*g2d_width, ty*g2d_height, p_contextSignal);
            }

            return true;
        } else {
            if (node.g2d_mouseOverNode == node) {
                node.dispatchNodeMouseSignal(GMouseSignalType.MOUSE_OUT, node, tx*g2d_width, ty*g2d_height, p_contextSignal);
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
            if (p_bounds != null) p_bounds.setTo(0,0,g2d_width,g2d_height);
            else p_bounds = new GRectangle(0,0,g2d_width,g2d_height);
        }

        return p_bounds;
    }
}
