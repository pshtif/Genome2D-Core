package com.genome2d.components.renderables;

/**
 * ...
 * @author 
 */
class GTextureTextAlignType
{
    #if swc
    static public var TOP_LEFT(get, never):Int;
    @:getter(TOP_LEFT)
    inline static public function get_TOP_LEFT():Int {
        return 0;
    }
    #else
	static public inline var TOP_LEFT:Int = 0;
    #end

    #if swc
    static public var TOP_RIGHT(get, never):Int;
    @:getter(TOP_RIGHT)
    inline static public function get_TOP_RIGHT():Int {
        return 1;
    }
    #else
	static public inline var TOP_RIGHT:Int = 1;
    #end

    #if swc
    static public var MIDDLE(get, never):Int;
    @:getter(MIDDLE)
    inline static public function get_MIDDLE():Int {
        return 2;
    }
    #else
	static public inline var MIDDLE:Int = 2;
    #end
}