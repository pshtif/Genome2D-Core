/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.ui;

class GUIStateTransform {
    public var time:Float;
    public var x:Float;
    public var y:Float;
    public var scaleX:Float;
    public var scaleY:Float;
    public var alpha:Float;

    public function new(p_time:Float, p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_alpha:Float) {
        time = p_time;
        x = p_x;
        y = p_y;
        scaleX = p_scaleX;
        scaleY = p_scaleY;
        alpha = p_alpha;
    }
}
