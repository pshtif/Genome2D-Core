/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.prototype;

import com.genome2d.prototype.MGPrototypeProcessor;

/**
    Prototypable interface
**/
@:autoBuild(com.genome2d.prototype.MGPrototypeProcessor.build())
interface IGPrototypable {
    private function initDefault():Void;
    private function init():Void;
    public function getPrototype():Xml;
    public function initPrototype(p_xml:Xml):Void;
}