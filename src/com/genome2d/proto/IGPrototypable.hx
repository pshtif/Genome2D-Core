/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.proto;

import com.genome2d.macros.MGPrototypeProcessor;

/**
    Prototypable interface
**/
@:autoBuild(com.genome2d.macros.MGPrototypeProcessor.build())
interface IGPrototypable {
	public var g2d_prototypeStates:GPrototypeStates;
	public var g2d_currentState:String;

  public function getPrototype(p_prototype:GPrototype = null):GPrototype;
  public function bindPrototype(p_prototype:GPrototype):Void;
	public function toReference():String;
	public function setPrototypeState(p_stateName:String):Void;
}
