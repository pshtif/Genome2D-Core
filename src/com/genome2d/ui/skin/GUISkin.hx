package com.genome2d.ui.skin;
import com.genome2d.input.GMouseInput;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTexture;
import com.genome2d.debug.GDebug;

@:access(com.genome2d.ui.skin.GUISkinManager)
@:allow(com.genome2d.ui.skin.GUISkinManager)
class GUISkin implements IGPrototypable {
    static private var g2d_batchQueue:Array<GUISkin>;
    static private var g2d_currentBatchTexture:GTexture;

    static private function batchRender(p_skin:GUISkin):Bool {
        var batched:Bool = false;
        if (g2d_currentBatchTexture != null && !p_skin.getTexture().hasSameGPUTexture(g2d_currentBatchTexture)) {
            g2d_batchQueue.push(p_skin);
            batched = true;
        } else if (g2d_currentBatchTexture == null) {
            g2d_currentBatchTexture = p_skin.getTexture();
        }
        return batched;
    }

    static private function flushBatch():Void {
        g2d_currentBatchTexture = null;
        var queueLength:Int = g2d_batchQueue.length;
        for (i in 0...queueLength) {
            g2d_batchQueue.shift().flushRender();
        }
        if (g2d_batchQueue.length>0) flushBatch();
        g2d_currentBatchTexture = null;
    }

    private var g2d_id:String;
    #if swc @:extern #end
    @prototype public var id(get, set):String;
    #if swc @:getter(id) #end
    inline private function get_id():String {
        return (g2d_origin == null) ? g2d_id : g2d_origin.g2d_id;
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

    private var g2d_renderLeft:Float;
    private var g2d_renderTop:Float;
    private var g2d_renderRight:Float;
    private var g2d_renderBottom:Float;
    public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Bool {
        g2d_renderLeft = p_left;
        g2d_renderTop = p_top;
        g2d_renderRight = p_right;
        g2d_renderBottom = p_bottom;

        return !batchRender(this);
    }

    inline private function flushRender():Void {
        render(g2d_renderLeft, g2d_renderTop, g2d_renderRight, g2d_renderBottom);
    }

    public function getTexture():GTexture {
        return null;
    }

    private function attach(p_element:GUIElement):GUISkin {
        var origin:GUISkin = (g2d_origin == null) ? this : g2d_origin;
        var clone:GUISkin = origin.clone();
        clone.g2d_origin = origin;
        clone.g2d_element = p_element;
        clone.elementValueChanged_handler(p_element);
        origin.g2d_clones.push(clone);
        p_element.onValueChanged.add(clone.elementValueChanged_handler);
        return clone;
    }

    private function remove(p_element:GUIElement):Void {
        dispose();
    }

    private function elementValueChanged_handler(p_element:GUIElement):Void {
    }
	
	public function captureMouseInput(p_input:GMouseInput):Void {
				
	}

    private function clone():GUISkin {
        return null;
    }

    private function dispose():Void {
        if (g2d_origin != null) {
            g2d_origin.g2d_clones.remove(this);
            g2d_element.onValueChanged.remove(elementValueChanged_handler);
            g2d_element = null;
        }

        if (GUISkinManager.getSkinById(g2d_id) != null) GUISkinManager.g2d_references.remove(g2d_id);
    }
	
	public function toReference():String {
		return null;
	}
}
