/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.postprocess;

import com.genome2d.context.filters.GFilter;
import com.genome2d.context.GCamera;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GRectangle;
import com.genome2d.node.GNode;
import com.genome2d.context.filters.GBlurPassFilter;
import com.genome2d.postprocess.GPostProcess;
class GBlurPP extends GPostProcess
{
    private var g2d_invalidate:Bool = false;

    private var g2d_colorize:Bool = false;
    #if swc @:extern #end
    public var colorize(get, set):Bool;
    #if swc @:getter(colorize) #end
    inline private function get_colorize():Bool {
        return g2d_colorize;
    }
    #if swc @:setter(colorize) #end
    inline private function set_colorize(p_value:Bool):Bool {
        g2d_colorize = p_value;
        g2d_invalidate = true;
        return g2d_colorize;
    }
    private var g2d_red:Float = 0;
    #if swc @:extern #end
    public var red(get, set):Float;
    #if swc @:getter(red) #end
    inline private function get_red():Float {
        return g2d_red;
    }
    #if swc @:setter(red) #end
    inline private function set_red(p_value:Float):Float {
        g2d_red = p_value;
        g2d_invalidate = true;
        return g2d_red;
    }
    private var g2d_green:Float = 0;
    #if swc @:extern #end
    public var green(get, set):Float;
    #if swc @:getter(green) #end
    inline private function get_green():Float {
        return g2d_green;
    }
    #if swc @:setter(green) #end
    inline private function set_green(p_value:Float):Float {
        g2d_green = p_value;
        g2d_invalidate = true;
        return g2d_green;
    }
    private var g2d_blue:Float = 0;
    #if swc @:extern #end
    public var blue(get, set):Float;
    #if swc @:getter(blue) #end
    inline private function get_blue():Float {
        return g2d_blue;
    }
    #if swc @:setter(blue) #end
    inline private function set_blue(p_value:Float):Float {
        g2d_blue = p_value;
        g2d_invalidate = true;
        return g2d_blue;
    }
    private var g2d_alpha:Float = 1;
    #if swc @:extern #end
    public var alpha(get, set):Float;
    #if swc @:getter(alpha) #end
    inline private function get_alpha():Float {
        return g2d_alpha;
    }
    #if swc @:setter(alpha) #end
    inline private function set_alpha(p_value:Float):Float {
        g2d_alpha = p_value;
        g2d_invalidate = true;
        return g2d_alpha;
    }

    #if swc @:extern #end
    public var passes(get, never):Int;
    #if swc @:getter(passes) #end
    inline private function get_passes():Int {
        return g2d_passes>>1;
    }

    private var g2d_blurX:Float = 0;
    #if swc @:extern #end
    public var blurX(get, set):Int;
    #if swc @:getter(blurX) #end
    inline private function get_blurX():Int {
        return Std.int(g2d_passes*(g2d_blurX/2));
    }
    #if swc @:setter(blurY) #end
    inline private function set_blurX(p_value:Int):Int {
        g2d_blurX = 2*p_value/g2d_passes;
        g2d_invalidate = true;
        return p_value;
    }
    private var g2d_blurY:Float = 0;
    #if swc @:extern #end
    public var blurY(get, set):Int;
    #if swc @:getter(blurY) #end
    inline private function get_blurY():Int {
        return Std.int(g2d_passes*(g2d_blurY/2));
    }
    #if swc @:setter(blurY) #end
    inline private function set_blurY(p_value:Int):Int {
        g2d_blurY = 2*p_value/g2d_passes;
        g2d_invalidate = true;
        return p_value;
    }

    public function new(p_blurX:Int, p_blurY:Int, p_passes:Int = 1) {
        // Double the passes since we need them for vertical and horizontal blur as well
        super(p_passes*2);

        // Multiply by 2 for both ends and divide by Float of passes since its incremental blur per pass
        g2d_blurX = 2*p_blurX/g2d_passes;
        g2d_blurY = 2*p_blurY/g2d_passes;

        // Calculate margins for containment area since blur goes reaches out
        g2d_leftMargin = g2d_rightMargin = Std.int(g2d_blurX * g2d_passes * .5);
        g2d_topMargin = g2d_bottomMargin = Std.int(g2d_blurY * g2d_passes * .5);

        g2d_passFilters = new Array<GFilter>();
        // Generate blur pass filters
        for (i in 0...g2d_passes) {
            var blurPass:GBlurPassFilter = new GBlurPassFilter((i<g2d_passes/2) ? Std.int(g2d_blurY) : Std.int(g2d_blurX), (i<g2d_passes/2) ? GBlurPassFilter.VERTICAL : GBlurPassFilter.HORIZONTAL);
            g2d_passFilters.push(blurPass);
        }
    }

    override public function render(p_parentTransformUpdate:Bool, p_parentColorUpdate:Bool, p_camera:GCamera, p_node:GNode, p_bounds:GRectangle = null, p_source:GTexture = null, p_target:GTexture = null):Void {
        if (g2d_invalidate) invalidateBlurFilters();

        super.render(p_parentTransformUpdate, p_parentColorUpdate, p_camera, p_node, p_bounds, p_source, p_target);
    }

    private function invalidateBlurFilters():Void {
        var i:Int = g2d_passFilters.length-1;
        while (i>=0) {
            var filter:GBlurPassFilter = cast g2d_passFilters[i];
            filter.blur = (i<g2d_passes/2) ? g2d_blurY : g2d_blurX;
            filter.colorize = g2d_colorize;
            filter.red = g2d_red;
            filter.green = g2d_green;
            filter.blue = g2d_blue;
            filter.alpha = g2d_alpha;
            i--;
        }
        g2d_leftMargin = g2d_rightMargin = Std.int(g2d_blurX * g2d_passes * .5);
        g2d_topMargin = g2d_bottomMargin = Std.int(g2d_blurY * g2d_passes * .5);

        g2d_invalidate = false;
    }
}