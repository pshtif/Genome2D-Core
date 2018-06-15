package com.genome2d.macros;

#if macro
import haxe.macro.Type.ModuleType;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

import haxe.crypto.Md5;
import haxe.Timer;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
#end

class MGBuild {

    #if macro	
    static public var prototypeCache:String;

    macro public static function myFunc() {
        trace("Start macro compilation.");
        prototypeCache = "";
		
        Context.onAfterTyping(onAfterTyping);
        Context.onGenerate(onGenerate);
        Context.onTypeNotFound(onTypeNotFound);
        Context.onMacroContextReused(onMacroContextReused);
        return { expr:EBlock([]), pos:Context.currentPos() }
    }

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
			var buildFilePath:String = FileSystem.fullPath( Context.resolvePath( "build.hxml" ) );
			var prototypeFilePath:String = Path.directory(buildFilePath) + "/prototypes.def";

            // Macro context reused compilation didn't happen
            if (prototypeCache == "") {
                // use custom cache
                if (FileSystem.exists(prototypeFilePath)) {
                    prototypeCache = File.getContent(prototypeFilePath);
                } else {
                    throw "No prototype cache something went wrong!";
                }
            // Compilation did happen write down the output to custom cache
            } else {
                if (FileSystem.exists(prototypeFilePath)) {
                    FileSystem.deleteFile(prototypeFilePath);
                }
                File.saveContent( prototypeFilePath, prototypeCache);
            }

			var pos = Context.currentPos();
			var prototypes = [];
			var outputArray:Array<String> = prototypeCache.split("\n");
			for (i in 0...outputArray.length-1) {
				var split:Array<String> = outputArray[i].split("|");
				var field = { name : split[0], doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { split[1] } ), pos : pos };
				prototypes.push(field);
			}
			
			var helperName = "com.genome2d.proto.GPrototypeHelper";
			var helperClass = {
				pack:[], name: helperName, pos: pos,
                //{ name:":native", params:[macro "com.genome2d.proto.GPrototypeHelper"], pos:pos }, 
				meta: [{ name:":keep", params:[], pos:pos }], //, { name:":rtti", params:[], pos:pos } ],
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

    macro static public function getBuildId() {
        return macro $v{ Md5.encode(Std.string( Timer.stamp()*Math.random() )) };
    }

    macro static public function getBuildDate() {
        return macro $v{ Date.now().toString() };
    }

    macro static public function getBuildVersion() {
        return macro $v{ loadFile("VERSION") };
    }
}
