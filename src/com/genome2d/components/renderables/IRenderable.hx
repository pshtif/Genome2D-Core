/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderables;

import com.genome2d.geom.GRectangle;
import com.genome2d.context.GCamera;

/**
    Interfaces implemented by all renderable components

    Every `GNode` can have a single `IRenderable` component at any given time
**/
interface IRenderable {

    /**
        Render the component
    **/
    function render(p_camera:GCamera, p_useMatrix:Bool):Void;

    /**
        Get local bounds of the renderable component
    **/
    function getBounds(p_target:GRectangle = null):GRectangle;
}
