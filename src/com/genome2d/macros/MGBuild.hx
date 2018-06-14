package com.genome2d.macros;

import haxe.macro.Type.ModuleType;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

import haxe.crypto.Md5;
import haxe.Timer;
#if macro
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
#end

class MGBuild {

    macro public static function myFunc() {
        trace("Start macro compilation.");
		
		Compiler.exclude( "com.genome2d.proto.GPrototypeHelper" );
		
        Context.onAfterTyping(onAfterTyping);
        Context.onGenerate(onGenerate);
        Context.onTypeNotFound(onTypeNotFound);
        Context.onMacroContextReused(onMacroContextReused);
        return { expr:EBlock([]), pos:Context.currentPos() }
    }

    #if macro	
    static public function onMacroContextReused():Bool {
        trace("onMacroContextReused");
        return true;
    }

    static public function onTypeNotFound(p_type:String):TypeDefinition {
        //trace("onTypeNotFound", p_type);
        return null;
    }

	static private var FIRST_PASS:Bool = true;
	
    static function onAfterTyping(p_types:Array<ModuleType>) {
        //trace("onAfterTyping");
		
		if (FIRST_PASS) {
			FIRST_PASS = false;
			
			trace("Generating GPrototypeHelper");
			var mainFilePath = FileSystem.fullPath( Context.resolvePath( "build.hxml" ) );
			var classFilePath = Path.directory(mainFilePath) + "/prototypes.def";
			
			File.saveContent( classFilePath, MGPrototypeProcessor.prototypeOutput);

			var pos = Context.currentPos();
			var prototypes = [];
			var outputArray:Array<String> = MGPrototypeProcessor.prototypeOutput.split("\n");
			for (i in 0...outputArray.length-1) {
				var split:Array<String> = outputArray[i].split("|");
				var field = { name : split[0], doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { split[1] } ), pos : pos };
				prototypes.push(field);
			}
			
			var helperName = "com.genome2d.proto.GPrototypeHelper";
			var helperClass = {
				pack:[], name: helperName, pos: pos,
				meta: [ { name:":native", params:[macro "com.genome2d.proto.GPrototypeHelper"], pos:pos }, { name:":keep", params:[], pos:pos }], //, { name:":rtti", params:[], pos:pos } ],
				kind: TDClass(), fields:prototypes
			}
			Context.defineType( helperClass );
		}
    }

    static function onGenerate(p_types:Array<haxe.macro.Type>) {
        trace("onGenerate");
		var output:String = "";
		for (moduleType in p_types) {
			var name:String = cast moduleType;
			output += name + "\n";
		}
		var mainFilePath = FileSystem.fullPath( Context.resolvePath( "build.hxml" ) );
		var classFilePath = Path.directory(mainFilePath) + "/types2.def";
		
		File.saveContent( classFilePath, output);
    }
    #end

    macro static public function getBuildId() {
        return macro $v{ Md5.encode(Std.string( Timer.stamp()*Math.random() )) };
    }

    macro static public function getBuildDate() {
        return macro $v{ Date.now().toString() };
    }

    macro static public function getBuildVersion() {
        return macro $v{ loadFile("VERSION") };
    }

    #if macro
        static function loadFile(path:String) {
            try {
                var p = Context.resolvePath(path);
                Context.registerModuleDependency(Context.getLocalModule(), p);
                return sys.io.File.getContent(p);
            }
            catch(e:Dynamic) {
                return haxe.macro.Context.error('Failed to load file $path: $e', Context.currentPos());
            }
        }
    #end
}
