/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable;

import com.genome2d.signals.GMouseSignal;
import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;

/**
    Interfaces implemented by all renderable components

    Every `GNode` can have a single `IRenderable` components at any given time
**/
interface IRenderable {

    /**
     *  Render the components
     **/
    function render(p_camera:GCamera, p_useMatrix:Bool):Void;

    /**
     *  Get local bounds of the renderable components
     **/
    function getBounds(p_target:GRectangle = null):GRectangle;

    /**
     *
     **/
    function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool;
}
