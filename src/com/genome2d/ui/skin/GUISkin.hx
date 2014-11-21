package com.genome2d.ui.skin;
import com.genome2d.prototype.IGPrototypable;
import com.genome2d.textures.GContextTexture;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.textures.GTexture;
import com.genome2d.error.GError;

@prototypeName("skin")
class GUISkin implements IGPrototypable {
    public var type:Float = 0;

    private var g2d_id:String;
    inline public function getId():String {
        return g2d_id;
    }

    public function getMinWidth():Float {
        return 0;
    }
    public function getMinHeight():Float {
        return 0;
    }

    @:access(com.genome2d.ui.GUISkinManager)
    public function new(p_id:String) {
        if (GUISkinManager.g2d_references == null) GUISkinManager.g2d_references = new Map<String, GUISkin>();
        if (p_id == null || p_id.length == 0) new GError("Invalid style id");
        if (GUISkinManager.g2d_references[p_id] != null) new GError("Duplicate style id: "+p_id);

        g2d_id = p_id;
        GUISkinManager.g2d_references[g2d_id] = this;
    }

    public function render(p_x:Float, p_y:Float, p_width:Float, p_height:Float):Void {
    }

    public function getTexture():GContextTexture {
        return null;
    }

    public function getPrototype():Xml {
        var prototypeXml:Xml = Xml.createElement("skin");
        prototypeXml.set("id", g2d_id);
        prototypeXml.set("class", Type.getClassName(Type.getClass(this)));

        var properties:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_PROPERTIES");

        if (properties != null) {
            for (i in 0...properties.length) {
                var property:Array<String> = properties[i].split("|");
                prototypeXml.set(property[0],Std.string(Reflect.getProperty(this, property[0])));
            }
        }

        return prototypeXml;
    }

    public function initPrototype(p_xml:Xml):Void {

    }
}
