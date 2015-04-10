/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.callbacks;

import com.genome2d.input.GMouseInput;
import com.genome2d.node.GNode;

/**

**/
class GNodeMouseInput {
    public var target:GNode;
    public var dispatcher:GNode;
    public var type:String;

    public var localX:Float;
    public var localY:Float;

    private var g2d_contextInput:GMouseInput;
    #if swc @:extern #end
    @prototype public var contextInput(get, never):GMouseInput;
    #if swc @:getter(contextInput) #end
    public function get_contextInput():GMouseInput {
        return g2d_contextInput;
    }

    public function new(p_type:String, p_target:GNode, p_dispatcher:GNode, p_localX:Float, p_localY:Float, p_contextInput:GMouseInput) {
        type = p_type;
        target = p_target;
        dispatcher = p_dispatcher;

        localX = p_localX;
        localY = p_localY;

        g2d_contextInput = p_contextInput;
    }
}
