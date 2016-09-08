package com.genome2d.scripts;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GScript
{
	public var id:String;
	public var includeMath:Bool = true;
	
	private var g2d_interpreter:hscript.Interp;
	
	private var g2d_source:String;
	public function getSource():String {
		return g2d_source;
	}
	
	public function setSource(p_source:String):Void {
		g2d_source = p_source;
	}
	
	public function recompile():Void {
		g2d_interpreter = new hscript.Interp();
		if (includeMath) g2d_interpreter.variables.set("Math", Math);
		var compiled:Bool = true;
		try {
			g2d_program = g2d_parser.parseString(g2d_source);
			g2d_interpreter.execute(g2d_program);
		} catch (e:Dynamic) {
			compiled = false;
		}

		/*
		if (compiled) {
			g2d_executeSpawn = interp.variables.get("spawn");
			g2d_executeUpdate = interp.variables.get("update"); 
			spawnModule = g2d_executeSpawn != null;
			updateModule = g2d_executeUpdate != null;
		}
		/**/
	}
	
	private var g2d_parser:hscript.Parser;
	private var g2d_program:Dynamic;
	
	public function new() {
		g2d_parser = new hscript.Parser();
		g2d_parser.allowTypes = true;
	}
	
	public function dispose():Void {
		
	}
	
	private function internalDispose():Void {
		
	}
}