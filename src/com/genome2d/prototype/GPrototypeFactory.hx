package com.genome2d.prototype;
import Reflect;
import com.genome2d.error.GError;
import haxe.rtti.Meta;
class GPrototypeFactory {
    static private var lookupsInitialized:Bool = false;
    static private var lookups:Map<String,Class<IGPrototypable>>;

    static public function createPrototype(p_prototypeXml:Xml):IGPrototypable {
        if (!lookupsInitialized) {
            lookups = new Map<String,Class<IGPrototypable>>();

            var fields:Dynamic = Meta.getType(IGPrototypable);
            for (i in Reflect.fields(fields)) {
                trace(i, Reflect.field(fields,i));
                var className:String = Reflect.field(fields,i)[0];
                var cls:Class<IGPrototypable> = cast Type.resolveClass(className);
                lookups.set(i, cls);
            }
        }

        var prototypeName:String = p_prototypeXml.nodeName;
        var prototypeClass:Class<IGPrototypable> = lookups[prototypeName];
        if (prototypeClass == null) {
            new GError("Non existing prototype class "+prototypeName);
        }
        var prototype:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (prototype == null) new GError("Invalid prototype.");

        prototype.initPrototype(p_prototypeXml);

        return prototype;
        /**/
    }
    /**/
}
