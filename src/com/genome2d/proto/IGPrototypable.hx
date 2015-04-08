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
    public function getPrototype(p_xml:Xml = null):Xml;
    public function bindPrototype(p_xml:Xml):Void;
}