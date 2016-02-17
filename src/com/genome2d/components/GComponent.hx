/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components;

import com.genome2d.debug.GDebug;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.node.GNode;
import com.genome2d.input.GMouseInput;

/**
    Component super class all components need to extend it
**/
@:allow(com.genome2d.node.GNode)
class GComponent implements IGPrototypable
{
	public var prototypable:Bool = true;
	
	private var g2d_active:Bool = true;

    /**
	    Abstract reference to user defined data, if you want keep some custom data binded to component instance use it.
	**/
    private var g2d_userData:Map<String, Dynamic>;
    #if swc @:extern #end
    public var userData(get, never):Map<String, Dynamic>;
    #if swc @:getter(userData) #end
    inline private function get_userData():Map<String, Dynamic> {
        if (g2d_userData == null) g2d_userData = new Map<String,Dynamic>();
        return g2d_userData;
    }

	public function isActive():Bool {
		return g2d_active;
	}
	public function setActive(p_value:Bool):Void {
		g2d_active = p_value;
	}

	private var g2d_node:GNode;
    /**
        Component's node reference
     **/
	#if swc @:extern #end
	public var node(get, never):GNode;
	#if swc @:getter(node) #end
	inline private function get_node():GNode {
		return g2d_node;
	}

	public function new() {
	}

	/**
        Abstract method called after components is initialized on the node
    **/
    public function init():Void {
    }

    public function dispose():Void {

    }
	
	/**
	    Base dispose method, if there is a disposing you need to do in your extending components you should override it and always call super.dispose() its used when a node using this components is being disposed
	**/
	private function g2d_dispose():Void {
        dispose();

		g2d_active = false;
		
		g2d_node = null;
	}
	
	public function toReference():String {
		return null;
	}
}