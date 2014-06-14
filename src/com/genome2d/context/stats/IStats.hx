/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.context.stats;

import com.genome2d.context.IContext;

/**
    Interface for implementing custom stats class
**/
interface IStats {

    /**
        Clear stats at the beginning of the rendering
    **/
    function clear():Void;

    /**
        Render stats to the screen
    **/
    function render(p_context:IContext):Void;
}
