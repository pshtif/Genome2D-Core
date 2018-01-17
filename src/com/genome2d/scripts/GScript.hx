/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.scripts;

import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.GPrototypeExtras;
import com.genome2d.proto.GPrototype;
import com.genome2d.callbacks.GCallback.GCallback0;
import com.genome2d.macros.MGDebug;
import com.genome2d.proto.IGPrototypable;
class GScript implements IGPrototypable
{
	#if genome_editor
  	static public var PROTOTYPE_EDITOR:String = "GEUIScriptEditor";
  	#end

	private var g2d_onInvalidated:GCallback0;
	#if swc @:extern #end
	public var onInvalidated(get,null):GCallback0;
	#if swc @:getter(onInvalidated) #end
	inline private function get_onInvalidated():GCallback0 {
		return g2d_onInvalidated;
	}


	private var g2d_id:String;
	/**
	 * 	Id
	 */
	@prototype
	#if swc @:extern #end
	public var id(get,set):String;
	#if swc @:getter(id) #end
	inline private function get_id():String {
		return g2d_id;
	}
	#if swc @:setter(id) #end
	inline private function set_id(p_value:String):String {
		GScriptManager.g2d_removeScript(this);
		g2d_id = p_value;
		GScriptManager.g2d_addScript(this);
		return g2d_id;
	}

	@prototype
	public var includeMath:Bool = true;
	
	private var g2d_interpreter:hscript.Interp;
	private var g2d_parser:hscript.Parser;
	private var g2d_program:Dynamic;

	private var g2d_properties:Map<String,Dynamic>;
	private var g2d_propertyTypes:Map<String,String>;

	private var g2d_compiled:Bool = false;
	public function isCompiled():Bool {
		return g2d_compiled;
	}
	
	private var g2d_source:String;
	public function getSource():String {
		return g2d_source;
	}
	
	public function setSource(p_source:String):Void {
		g2d_source = p_source;
		if (g2d_source != null) recompile();
	}

	public function new() {
		g2d_onInvalidated = new GCallback0();

		g2d_parser = new hscript.Parser();
		g2d_parser.allowTypes = true;
	}

	private function preparseSource():String {
		g2d_properties = new Map<String,Dynamic>();
		g2d_propertyTypes = new Map<String,String>();
		var e:EReg = ~/[\s\r\n]+/gim;
		var preparsedSource:String = "";
		var lines:Array<String> = g2d_source.split("\n");
		for (line in lines) {
			var regLine:String = e.replace(line,"");
			if (regLine.indexOf("import") == 0) {
				var className:String = regLine.substr(6);
				if (className.lastIndexOf(";") == className.length-1) className = className.substr(0,-1);
				var c:Class<Dynamic> = Type.resolveClass(className);
				g2d_interpreter.variables.set(className.substr(className.lastIndexOf(".")+1), c);
			} else if (regLine.indexOf("var") == 0){
				var strip:String = regLine.substr(3);
				if (strip.indexOf(";") == strip.length-1) strip = strip.substr(0,strip.length-1);
				var varName:String = "";
				var varType:String = "";
				var varValue:String = "";
				if (strip.indexOf(":") != -1) {
					var split:Array<String> = strip.split(":");
					varName = split[0];
					strip = split[1];
				}
				if (strip.indexOf("=") != -1) {
					var split:Array<String> = strip.split("=");
					if (varName != "") {
						varType = split[0];
					} else {
						varName = split[0];
					}
					varValue = split[1];
				} else {
					if (varName == "") {
						varName = strip;
					} else {
						varType = strip;
					}
				}
				g2d_properties.set(varName,getVariableValue(varType, varValue));
				g2d_propertyTypes.set(varName,varType == "" ? "String" : varType);
			} else {
				preparsedSource += line + "\n";
			}
		}

		return preparsedSource;
	}

	private function getVariableValue(p_type:String, p_stringValue:String):Dynamic {
		switch (p_type) {
			case "String":
				if (p_stringValue == "") {
					return "";
				} else {
					return p_stringValue;
				}
			case "Float":
				if (p_stringValue == "") {
					return 0;
				} else {
					return Std.parseFloat(p_stringValue);
				}
			case "Int":
				if (p_stringValue == "") {
					return 0;
				} else {
					return Std.parseInt(p_stringValue);
				}
			case _:
				return p_stringValue;
		}
	}
	
	public function recompile():Void {
		g2d_interpreter = new hscript.Interp();
		if (includeMath) g2d_interpreter.variables.set("Math", Math);
		g2d_interpreter.variables.set("genome", Genome2D.getInstance());

		var preparsedSource:String = preparseSource();
		for (key in g2d_properties.keys()) {
			g2d_interpreter.variables.set(key,g2d_properties.get(key));
		}

		g2d_compiled = true;
		try {
			g2d_program = g2d_parser.parseString(preparsedSource);
			g2d_interpreter.execute(g2d_program);
		} catch (e:Dynamic) {
			MGDebug.WARNING("Invalid script", e);
			g2d_compiled = false;
		}
		onInvalidated.dispatch();
	}

	public function setVariable(p_name:String, p_value:Dynamic):Void {
		if (g2d_interpreter != null) {
			g2d_interpreter.variables.set(p_name, p_value);
		}
	}

	public function getVariable(p_name:String):Dynamic {
		return g2d_interpreter == null ? null : g2d_interpreter.variables.get(p_name);
	}

	public function getVariables():Map<String,Dynamic> {
		var variables:Map<String,Dynamic> = new Map<String,Dynamic>();
		if (g2d_interpreter != null) {
			for (variable in g2d_interpreter.variables.keys()) {
				switch (variable) {
					case "null" | "trace" | "true" | "false" | "Math" | "genome":
					case _:
						variables.set(variable, g2d_interpreter.variables.get(variable));
				}
			}
		}
		return variables;
	}
	
	public function dispose():Void {
		g2d_onInvalidated.removeAll();
	}
	
	private function internalDispose():Void {
		
	}

	/*
	 *	Get a reference value
	 */
	public function toReference():String {
		return "@"+g2d_id;
	}

	/*
	 * 	Get an instance from reference
	 */
	static public function fromReference(p_reference:String) {
		return GScriptManager.getScript(p_reference.substr(1));
	}

	public function getPrototype(p_prototype:GPrototype = null):GPrototype {
		p_prototype = getPrototypeDefault(p_prototype);
		for (key in g2d_properties.keys()) {
			p_prototype.createPrototypeProperty(key, g2d_propertyTypes.get(key), GPrototypeExtras.IGNORE_AUTO_BIND, null, g2d_properties.get(key));
		}

		return p_prototype;
	}

	public function bindPrototype(p_prototype:GPrototype):Void {
		GPrototypeFactory.g2d_bindPrototype(this, p_prototype, PROTOTYPE_NAME);

		var gen:Map<String,GPrototypeProperty> = p_prototype.getNonAutoBindProperties();
		for (key in gen.keys()) {
			var property:GPrototypeProperty = gen.get(key);
			g2d_properties.set(key, property.value);
			g2d_propertyTypes.set(key, property.type);
		}
	}
}