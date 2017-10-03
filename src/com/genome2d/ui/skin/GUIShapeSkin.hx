/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.skin;
import com.genome2d.context.GBlendMode;
import com.genome2d.textures.GTexture;
import com.genome2d.particles.GParticleSystem;

class GUIShapeSkin extends GUISkin {

    public var blendMode:GBlendMode;
    public var texture:GTexture;
    public var rotation:Float = 0;

    private var g2d_vertices:Array<Float>;
    private var g2d_uvs:Array<Float>;

    override public function getMinWidth():Float {
        return 0;
    }

    override public function getMinHeight():Float {
        return 0;
    }

    public function new(p_id:String = "", p_texture:GTexture, p_vertices:Array<Float>, p_uvs:Array<Float>, p_origin:GUIShapeSkin = null) {
        super(p_id, p_origin);

        blendMode = GBlendMode.NORMAL;
        texture = p_texture;
        g2d_vertices = p_vertices;
        g2d_uvs = p_uvs;
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Bool {
        Genome2D.getInstance().getContext().drawPoly(texture, blendMode, g2d_vertices, g2d_uvs, p_left, p_top, 1, 1, rotation, red, green, blue, alpha);

        return true;
    }

    override public function clone():GUISkin {
        var clone:GUIShapeSkin = new GUIShapeSkin("", texture, g2d_vertices, g2d_uvs, (g2d_origin == null)?this:cast g2d_origin);
        clone.red = red;
        clone.green = green;
        clone.blue = blue;
        clone.alpha = alpha;
        clone.blendMode = blendMode;
        return clone;
    }
}
