/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.geom;

class GVector2 {
    public var x:Float;
    public var y:Float;

    public function new(p_x:Float = 0, p_y:Float = 0) {
        x = p_x;
        y = p_y;
    }

    #if swc @:extern #end
    public var length(get, never):Float;
    #if swc @:getter(length) #end
    inline private function get_length():Float {
        return Math.sqrt(x * x + y * y);
    }

    public function GVector2(p_x:Float = 0, p_y:Float = 0 ) {
        x = p_x;
        y = p_y;
    }

    public function addEq(p_vector:GVector2):Void {
        x += p_vector.x;
        y += p_vector.y;
    }

    public function subEq(p_vector:GVector2):Void {
        x -= p_vector.x;
        y -= p_vector.y;
    }

    public function mulEq(p_s:Float):Void {
        x *= p_s;
        y *= p_s;
    }

    public function dot(p_vector:GVector2):Float {
        return x * p_vector.x + y * p_vector.y;
    }

    public function normalize():GVector2 {
        var l:Float = Math.sqrt(x * x + y * y);
        if(l != 0) {
            x /= l;
            y /= l;
        }
        return this;
    }

    public function toString():String {
        return "["+x+","+y+"]";
    }
}