package com.genome2d.proto;
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

			if (extras & GPrototypeExtras.SETTER == 0) {
				var value = Reflect.getProperty(p_instance, name);
				if (value != null) {
				//if (value != propertyDefaults[i]) {
					var property:GPrototypeProperty = createPrototypeProperty(name, propertyTypes[i], extras);
					property.setDynamicValue(value);
				}
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
			if (lookupClass != null) propertyNames = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
		}
		
		if (lookupClass != null) {
			var propertyTypes:Array<String> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_TYPES);
			var propertyExtras:Array<Int> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_EXTRAS);
			var propertyIndex:Int = propertyNames.indexOf(split[0]);

			var property:GPrototypeProperty = createPrototypeProperty(p_name, propertyTypes[propertyIndex], propertyExtras[propertyIndex]);
			property.setStringValue(p_value);
			
		} else {
			createPrototypeProperty(p_name, "String", 0, p_value);
		}
	}
	
	public function createPrototypeProperty(p_name:String, p_type:String, p_extras:Int, p_value:Dynamic = null):GPrototypeProperty {
		var property:GPrototypeProperty = new GPrototypeProperty(p_name, p_type, p_extras);

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
	
	public function new(p_name:String, p_type:String, p_extras:Int):Void {
		name = p_name;
		type = p_type;
		extras = p_extras;
	}
	
	public function setDynamicValue(p_value:Dynamic):Void {
		if ((extras & GPrototypeExtras.REFERENCE_GETTER) != 0) {
			value = cast(p_value, IGPrototypable).toReference();
		} else {
			if (isBasicType()) {
				value = p_value;
			} else {
				value = cast(p_value, IGPrototypable).getPrototype();
			}
		}
	}
	
	public function setStringValue(p_value:String):Void {
		if ((extras & GPrototypeExtras.REFERENCE_GETTER) != 0) {
			value = p_value;
		} else {
			switch (type) {
				case "Bool":
					value = (p_value != "false" && p_value != "0");
				case "Int":
					value = Std.parseInt(p_value);
				case "Float":
					value = Std.parseFloat(p_value);
				case "String" | "Dynamic" :
					value = p_value; 
				case _:
					if (type.indexOf("Array") == 0) {
						// We need to strip the string of brackets before splitting
						value = (p_value).substr(1,p_value.length-2).split(",");
					} else {
						GDebug.error("Error during prototype binding invalid value for type: " + type);
					}
			}
		}
	}
	
	public function bind(p_instance:IGPrototypable):Void {
		var realValue:Dynamic;
		if (isReference()) {
			var c:Class<IGPrototypable> = GPrototypeFactory.getPrototypeClass(type);
			realValue = Reflect.callMethod(c, Reflect.field(c,"fromReference"), [value]);
		} else if (isPrototype()) {
			realValue = GPrototypeFactory.createPrototype(value);
		} else {
			realValue = value;
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
	
	/*
	inline private function getRealValue():Dynamic {
		var realValue:Dynamic = null;

		switch (type) {
			case "Bool":
				realValue = (value != "false" && value != "0");
			case "Int":
				realValue = Std.parseInt(value);
			case "Float":
				realValue = Std.parseFloat(value);
			case "String" | "Dynamic" :
				realValue = value; 
			case _:
				if (isPrototype()) {
					realValue = GPrototypeFactory.createPrototype(value);
				} else if (type.indexOf("Array") == 0) {
					// We need to strip the string of brackets before splitting
					realValue = (value).substr(1,value.length-2).split(",");
				} else {
					GDebug.error("Error during prototype binding invalid value for type: " + type);
				}
		}
		return realValue;
	}
	/**/
	inline public function isBasicType():Bool {
		return (type == "Bool" || type == "Int" || type == "Float" || type == "String" || type.indexOf("Array")==0);
	}
	
	inline public function isReference():Bool {
		return (extras & GPrototypeExtras.REFERENCE_GETTER) != 0;
	}
	
	inline public function isPrototype():Bool {
		return Std.is(value, GPrototype);
	}
}