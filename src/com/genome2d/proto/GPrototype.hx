package com.genome2d.proto;
import haxe.rtti.Meta;
import com.genome2d.macros.MGDebug;
import com.genome2d.debug.GDebug;

/**
 * @author Peter @sHTiF Stefcek
 */
class GPrototype
{
	public var prototypeName:String;
	public var prototypeClass:Class<IGPrototypable>;
	
	public var properties:Map<String, GPrototypeProperty>;
	public var children:Map<String,Array<GPrototype>>;
	
	public function new() {
		properties = new Map<String,GPrototypeProperty>();
		
		children = new Map<String,Array<GPrototype>>();
	}
	
	public function process(p_instance:IGPrototypable, p_prototypeName:String):Void {
		var currentPrototypeClass:Class<IGPrototypable> = GPrototypeFactory.getPrototypeClass(p_prototypeName);

		if (prototypeClass == null) {
			prototypeName = p_prototypeName;
			prototypeClass = currentPrototypeClass;
		}
		
		var propertyNames:Array<String> = Reflect.field(currentPrototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
		var propertyDefaults:Array<Dynamic> = Reflect.field(currentPrototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_DEFAULTS);
		var propertyTypes:Array<String> = Reflect.field(currentPrototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_TYPES);
		var propertyExtras:Array<Int> = Reflect.field(currentPrototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_EXTRAS);

		for (i in 0...propertyNames.length) {
			var name:String = propertyNames[i];
			var extras:Int = propertyExtras[i];

			// Find property meta data and since it can be anywhere in inheritance chain we need to look up for it
			var lookupClass:Class<IGPrototypable> = prototypeClass;
			var meta = Reflect.getProperty(Meta.getFields(lookupClass), name);
			while (meta == null && lookupClass != null) {
				lookupClass = cast Type.getSuperClass(lookupClass);
				if (lookupClass != null) {
					propertyNames = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
					meta = Reflect.getProperty(Meta.getFields(lookupClass), name);
				}
			}

			if (extras & GPrototypeExtras.SETTER == 0) {
				var value = Reflect.getProperty(p_instance, name);
				//if (value != null) {
				//if (value != propertyDefaults[i]) {
					var property:GPrototypeProperty = createPrototypeProperty(name, propertyTypes[i], extras, meta, null);
					property.setDynamicValue(value);
				//}
			}
		}
	}
	
	public function bind(p_instance:IGPrototypable, p_prototypeName:String):Void {
		var currentPrototypeClass:Class<IGPrototypable> = GPrototypeFactory.getPrototypeClass(p_prototypeName);
		
		var propertyNames:Array<String> = Reflect.field(currentPrototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
		
		for (property in properties) {
			var name:String = property.name.split(".")[0];
			if (propertyNames.indexOf(name) != -1 && (property.extras & GPrototypeExtras.IGNORE_AUTO_BIND) == 0) {
				property.bind(p_instance);
			}
		}
	}
	
	public function addChild(p_prototype:GPrototype, p_groupName:String):Void {
		if (!children.exists(p_groupName)) children.set(p_groupName, new Array<GPrototype>());
		children.get(p_groupName).push(p_prototype);
	}
	
	public function getGroup(p_groupName:String):Array<GPrototype> {
		return children.get(p_groupName);
	}
	
	public function getProperty(p_propertyName:String):GPrototypeProperty {
		return properties.get(p_propertyName);
	}
	
	public function setPropertyFromString(p_name:String, p_value:String):Void {
		var split:Array<String> = p_name.split(".");
		var lookupClass:Class<IGPrototypable> = prototypeClass;
		var propertyNames:Array<String> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);

		while (propertyNames.indexOf(split[0]) == -1 && lookupClass != null) {
			lookupClass = cast Type.getSuperClass(lookupClass);
			if (lookupClass != null) {
				propertyNames = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
			}
		}

		if (lookupClass != null) {
			var propertyTypes:Array<String> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_TYPES);
			var propertyExtras:Array<Int> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_EXTRAS);
			var propertyIndex:Int = propertyNames.indexOf(split[0]);
			var meta = Reflect.getProperty(Meta.getFields(lookupClass),p_name);

			var property:GPrototypeProperty = createPrototypeProperty(p_name, propertyTypes[propertyIndex], propertyExtras[propertyIndex], meta, null);
			property.setStringValue(p_value);
		} else {
			// Create property even if its not found among macro generated properties, could be custom
			// TODO: Think about better implementation to define customs
			createPrototypeProperty(p_name, "String", 0, null, p_value);
		}
	}
	
	public function createPrototypeProperty(p_name:String, p_type:String, p_extras:Int, p_meta:Dynamic, p_value:Dynamic):GPrototypeProperty {
		var property:GPrototypeProperty = new GPrototypeProperty(p_name, p_type, p_extras, p_meta);

		properties.set(p_name, property);
		property.value = p_value;
		
		return property;
	}
}

class GPrototypeProperty {
	public var name:String;
	public var value:Dynamic;
	public var type:String;
	public var extras:Int;
	public var isParameter:Bool = false;
	public var meta:Dynamic;
	
	public function new(p_name:String, p_type:String, p_extras:Int, p_meta:Dynamic):Void {
		name = p_name;
		type = p_type;
		extras = p_extras;
		meta = p_meta;
	}
	
	public function setDynamicValue(p_value:Dynamic):Void {
		if ((extras & GPrototypeExtras.REFERENCE_GETTER) != 0) {
			value = (p_value != null) ? cast(p_value, IGPrototypable).toReference() : null;
		} else {
			if (isBasicType()) {
				value = p_value;
			} else {
				var split:Array<String> = type.split(":");
				if (split.length == 2 && split[0] == "E") {
					value = p_value;
				} else {
					try {
						value = (p_value == null) ? null : cast(p_value, IGPrototypable).getPrototype();
					} catch (e:Dynamic) {
						MGDebug.ERROR("Invalid prototype property", name, type);
					}
				}
			}
		}
	}
	
	public function setStringValue(p_value:String):Void {
		if (p_value.indexOf("$") == 0) {
			isParameter = true;
			value = p_value.substr(1);
		} else {
			value = getRealValue(p_value);
		}
	}

	private function getRealValue(p_value:String):Dynamic {
		var realValue:Dynamic = null;
		if ((extras & GPrototypeExtras.REFERENCE_GETTER) != 0) {
			realValue = p_value == "null" ? null : p_value;
		} else {
			switch (type) {
				case "Bool":
					realValue = (p_value != "false" && p_value != "0");
				case "Int":
					realValue = Std.parseInt(p_value);
				case "Float":
					realValue = Std.parseFloat(p_value);
				case "String" | "Dynamic" :
					realValue = p_value;
				case _:
					var split:Array<String> = type.split(":");
					if (split.length == 2 && split[0] == "Array") {
						// We need to strip the string of brackets before splitting
						realValue = p_value == "null" ? null : p_value.split(",");//(p_value).substr(1,p_value.length-2).split(",");
					} else if (split.length == 2 && split[0] == "E") {
						try {
							realValue = p_value == "null" ? null : Type.createEnum(Type.resolveEnum(split[1]), Std.string(p_value));
						} catch(e:String) {
							MGDebug.ERROR("Cannot create prototype enum", e);
						}
					} else {
						GDebug.error("Error during prototype binding invalid value for type: " + type);
					}
			}
		}

		return realValue;
	}

	public function bind(p_instance:IGPrototypable):Void {
		var realValue:Dynamic;
		var mapValue:Dynamic = value;
		if (isParameter) {
			if (!GPrototypeFactory.getParameters().hasParameter(value)) GDebug.error("Invalid parameter in prototype", value);
			mapValue = getRealValue(GPrototypeFactory.getParameters().getParameter(value));
		}

		if (isReference()) {
			var c:Class<IGPrototypable> = GPrototypeFactory.getPrototypeClass(type);
			realValue = Reflect.callMethod(c, Reflect.field(c,"fromReference"), [mapValue]);
		} else if (isPrototype() && mapValue != null) {
			realValue = GPrototypeFactory.createPrototype(mapValue);
		} else {
			realValue = mapValue;
		}

		var split:Array<String> = name.split(".");
		if (split.length == 1 || split[1].split("-").indexOf("default") != -1) {
			try {
				if ((extras & GPrototypeExtras.SETTER) != 0) {
					Reflect.callMethod(p_instance, Reflect.field(p_instance, split[0]), [realValue]);
				} else {
					Reflect.setProperty(p_instance, split[0], realValue);
				}
			} catch (e:Dynamic) {
				//GDebug.error("Error during prototype binding: ", e);
			}
		}
			
		p_instance.g2d_prototypeStates.setProperty(split[0], realValue, extras, split[1], split[2]);
	}

	inline public function isBasicType():Bool {
		return (type == "Bool" || type == "Int" || type == "Float" || type == "String" || type.indexOf("Array")==0);
	}
	
	inline public function isReference():Bool {
		return (extras & GPrototypeExtras.REFERENCE_GETTER) != 0;
	}
	
	inline public function isPrototype():Bool {
		return value == null || Std.is(value, GPrototype);
	}

	inline public function isEnum():Bool {
		return type.indexOf("E:") == 0;
	}
}