package com.genome2d.macros;

import haxe.macro.Type.ModuleType;
import haxe.macro.Expr;
import haxe.macro.Context;

import haxe.crypto.Md5;
import haxe.Timer;

class MGBuild {

    macro public static function myFunc() {
        trace("Start macro compilation.");
        Context.onAfterTyping(onAfterTyping);
        Context.onGenerate(onGenerate);
        //Context.onTypeNotFound(onTypeNotFound);
        return { expr:EBlock([]), pos:Context.currentPos() }
    }

    #if macro
    static public function onTypeNotFound(p_type:String):TypeDefinition {
        trace("onTypeNotFound", p_type);
        return null;
    }

    static function onAfterTyping(p_types:Array<ModuleType>) {
        trace("onAfterTyping");
        /*
        for (moduleType in p_types) {
            trace(moduleType);
        }
        /**/
    }

    static function onGenerate(p_types:Array<haxe.macro.Type>) {
        trace("onGenerate");
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
