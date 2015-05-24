/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable;

import com.genome2d.input.GMouseInput;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;

/**
    Interfaces implemented by all renderable components

    Every `GNode` can have a single `IRenderable` components at any given time
**/
interface IGRenderable {

    /**
     *  Render the components
     **/
    function render(p_camera:GCamera, p_useMatrix:Bool):Void;

    /**
     *  Get local bounds of the renderable components
     **/
    function getBounds(p_target:GRectangle = null):GRectangle;

	/**
     *  Capture mouse input
     **/
	function captureMouseInput(p_input:GMouseInput):Void;
	
	/**
     *  Check for hit test in local space
     **/
	function hitTest(p_x:Float, p_y:Float):Bool;
}
