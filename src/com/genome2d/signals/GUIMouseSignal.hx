/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.signals;

import com.genome2d.ui.element.GUIElement;

/**

**/
class GUIMouseSignal {
    public var target:GUIElement;
    public var dispatcher:GUIElement;
    public var type:String;

    public var localX:Float;
    public var localY:Float;

    private var g2d_contextSignal:GMouseSignal;
    #if swc @:extern #end
    @prototype public var contextSignal(get, never):GMouseSignal;
    #if swc @:getter(contextSignal) #end
    public function get_contextSignal():GMouseSignal {
        return g2d_contextSignal;
    }

    public function new(p_type:String, p_target:GUIElement, p_dispatcher:GUIElement, p_localX:Float, p_localY:Float, p_contextSignal:GMouseSignal) {
        type = p_type;
        target = p_target;
        dispatcher = p_dispatcher;

        localX = p_localX;
        localY = p_localY;

        g2d_contextSignal = p_contextSignal;
    }
}
