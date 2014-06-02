package com.genome2d.components.renderables;

import com.genome2d.geom.GRectangle;
import com.genome2d.context.GContextCamera;

/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
interface IRenderable {
    function render(p_camera:GContextCamera, p_useMatrix:Bool):Void;

    function getBounds(p_target:GRectangle = null):GRectangle;
}
