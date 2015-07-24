package com.genome2d.proto;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GPrototypeParser
{

	static public function parseTo(p_prototype:Dynamic, p_instance:IGPrototypable):Void {
		var prototypeClass:Class<IGPrototypable> = Type.getClass(p_instance);
		var prototypeName:String = Reflect.field(prototypeClass, "PROTOTYPE_NAME");
		var propertyNames:Array<String> = Reflect.field(prototypeClass, "PROTOTYPE_PROPERTY_NAMES");
		var propertyTypes:Array<String> = Reflect.field(prototypeClass, "PROTOTYPE_PROPERTY_TYPES");
		var propertyExtras:Array<Int> = Reflect.field(prototypeClass, "PROTOTYPE_PROPERTY_EXTRAS");
		trace(propertyExtras);
	}
	
}