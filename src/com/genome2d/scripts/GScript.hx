/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.scripts;

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
			} else {
				preparsedSource += line + "\n";
			}
		}

		return preparsedSource;
	}
	
	public function recompile():Void {
		g2d_interpreter = new hscript.Interp();
		if (includeMath) g2d_interpreter.variables.set("Math", Math);
		g2d_interpreter.variables.set("genome", Genome2D.getInstance());

		var preparsedSource:String = preparseSource();

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
}