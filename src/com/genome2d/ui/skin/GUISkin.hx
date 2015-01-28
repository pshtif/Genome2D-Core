package com.genome2d.ui.skin;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.textures.GContextTexture;
import com.genome2d.textures.GTexture;
import com.genome2d.debug.GDebug;

@:access(com.genome2d.ui.skin.GUISkinManager)
class GUISkin implements IGPrototypable {
    private var g2d_id:String;
    #if swc @:extern #end
    @prototype public var id(get, set):String;
    #if swc @:getter(id) #end
    inline private function get_id():String {
        return g2d_id;
    }
    #if swc @:setter(id) #end
    inline private function set_id(p_value:String):String {
        if (p_value != g2d_id && p_value.length>0) {
            if (GUISkinManager.getSkinById(p_value) != null) GDebug.error("Duplicate style id: "+p_value);
            GUISkinManager.g2d_references.set(p_value,this);

            if (GUISkinManager.getSkinById(g2d_id) != null) GUISkinManager.g2d_references.remove(g2d_id);
            g2d_id = p_value;
        }

        return g2d_id;
    }

    private var g2d_clones:Array<GUISkin>;
    private var g2d_origin:GUISkin;
    private var g2d_element:GUIElement;

    public function getMinWidth():Float {
        return 0;
    }
    public function getMinHeight():Float {
        return 0;
    }

    static private var g2d_instanceCount:Int = 0;
    public function new(p_id:String = "") {
        g2d_instanceCount++;
        id = (p_id != "") ? p_id : "GUISkin"+g2d_instanceCount;
        g2d_clones = new Array<GUISkin>();
    }

    public function render(p_x:Float, p_y:Float, p_width:Float, p_height:Float):Void {
    }

    public function getTexture():GContextTexture {
        return null;
    }

    private function attach(p_element:GUIElement):GUISkin {
        var origin:GUISkin = (g2d_origin == null) ? this : g2d_origin;
        var clone:GUISkin = origin.clone();
        clone.g2d_origin = origin;
        clone.g2d_element = p_element;
        clone.elementValueChangedHandler(p_element);
        origin.g2d_clones.push(clone);
        p_element.onValueChanged.add(clone.elementValueChangedHandler);
        return clone;
    }

    private function remove(p_element:GUIElement):Void {
        dispose();
    }

    private function elementValueChangedHandler(p_element:GUIElement):Void {
    }

    private function clone():GUISkin {
        return null;
    }

    private function dispose():Void {
        if (g2d_origin != null) {
            g2d_origin.g2d_clones.remove(this);
            g2d_element.onValueChanged.remove(elementValueChangedHandler);
            g2d_element = null;
        }
    }
}
