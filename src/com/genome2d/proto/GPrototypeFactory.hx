package com.genome2d.proto;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.idea.GUIElement;
import Reflect;
import com.genome2d.error.GError;
import haxe.rtti.Meta;

//@:access(com.genome2d.protorototypable)
class GPrototypeFactory {
    static private var g2d_helper:GPrototypeHelper;
    static private var g2d_lookupsInitialized:Bool = false;
    static private var g2d_lookups:Map<String,Class<IGPrototypable>>;

    static public function initializePrototypes():Void {
        if (g2d_lookups != null) return;
        g2d_lookups = new Map<String,Class<IGPrototypable>>();

        var fields:Dynamic = Meta.getType(IGPrototypable);
        for (i in Reflect.fields(fields)) {
            var className:String = Reflect.field(fields,i)[0];
            var cls:Class<IGPrototypable> = cast Type.resolveClass(className);
            if (cls != null) g2d_lookups.set(i, cls);
        }
    }

    static public function getPrototypeClass(p_prototypeName:String):Class<IGPrototypable> {
        return g2d_lookups[p_prototypeName];
    }

    static public function createPrototype(p_prototypeXml:Xml):IGPrototypable {
        var prototypeName:String = p_prototypeXml.nodeName;
        var prototypeClass:Class<IGPrototypable> = g2d_lookups[prototypeName];
        if (prototypeClass == null) {
            new GError("Non existing proto class "+prototypeName);
        }

        var proto:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (proto == null) new GError("Invalid proto.");

        proto.initPrototype(p_prototypeXml);

        return proto;
    }

    static public function createEmptyPrototype(p_prototypeName:String):IGPrototypable {
        var prototypeClass:Class<IGPrototypable> = g2d_lookups[p_prototypeName];
        if (prototypeClass == null) {
            new GError("Non existing proto class "+p_prototypeName);
        }

        var proto:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (proto == null) new GError("Invalid proto.");

        return proto;
    }
    /**/
}
