package com.genome2d.ui.skin;
import com.genome2d.context.filters.GFilter;
import com.genome2d.input.GMouseInput;
import com.genome2d.proto.GPrototype;
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
	static private var g2d_currentBatchFilter:GFilter;
	static public var useBatch:Bool = true;

    static private function batchRender(p_skin:GUISkin):Bool {
        var batched:Bool = false;
        if (g2d_currentBatchTexture != null &&
			p_skin.getTexture() != null && !p_skin.getTexture().hasSameGPUTexture(g2d_currentBatchTexture) &&
			p_skin.getFilter() == g2d_currentBatchFilter) {
            g2d_batchQueue.push(p_skin);
            batched = true;
        } else if (g2d_currentBatchTexture == null &&
				   p_skin.getTexture() != null) {
            g2d_currentBatchTexture = p_skin.getTexture();
			g2d_currentBatchFilter = p_skin.getFilter();
        }
        return batched;
    }

    static private function flushBatch():Void {
		if (useBatch) {
			g2d_currentBatchTexture = null;
			g2d_currentBatchFilter = null;
			var queueLength:Int = g2d_batchQueue.length;
			for (i in 0...queueLength) {
				g2d_batchQueue.shift().flushRender();
			}
			if (g2d_batchQueue.length>0) flushBatch();
			g2d_currentBatchTexture = null;
			g2d_currentBatchFilter = null;
		}
    }

    private var g2d_id:String;
    #if swc @:extern #end
    @prototype public var id(get, never):String;
    #if swc @:getter(id) #end
    inline private function get_id():String {
        return (g2d_origin == null) ? g2d_id : g2d_origin.g2d_id;
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

    public function new(p_id:String = "", p_origin:GUISkin) {
		g2d_origin = p_origin;
        if (g2d_origin == null) {
			g2d_clones = new Array<GUISkin>();
			if (p_id != "") {
				g2d_id = p_id;
				GUISkinManager.g2d_addSkin(g2d_id, this);
			}
		}
    }

    private var g2d_renderLeft:Float;
    private var g2d_renderTop:Float;
    private var g2d_renderRight:Float;
    private var g2d_renderBottom:Float;
	private var g2d_renderRed:Float;
	private var g2d_renderGreen:Float;
	private var g2d_renderBlue:Float;
	private var g2d_renderAlpha:Float;
    public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Bool {
        g2d_renderLeft = p_left;
        g2d_renderTop = p_top;
        g2d_renderRight = p_right;
        g2d_renderBottom = p_bottom;
		g2d_renderRed = p_red;
		g2d_renderGreen = p_green;
		g2d_renderBlue = p_blue;
		g2d_renderAlpha = p_alpha;

        return useBatch ? !batchRender(this) : true;
    }

    inline private function flushRender():Void {
        render(g2d_renderLeft, g2d_renderTop, g2d_renderRight, g2d_renderBottom, g2d_renderRed, g2d_renderGreen, g2d_renderBlue, g2d_renderAlpha);
    }

	private function getTexture():GTexture {
        return null;
    }
	
	private function getFilter():GFilter {
		return null;
	}

    private function attach(p_element:GUIElement):GUISkin {
        var origin:GUISkin = (g2d_origin == null) ? this : g2d_origin;
        var clone:GUISkin = origin.clone();
        clone.g2d_element = p_element;
        clone.elementModelChanged_handler(p_element);
        p_element.onModelChanged.add(clone.elementModelChanged_handler);
		origin.g2d_clones.push(clone);
        return clone;
    }

    private function remove():Void {
        if (g2d_origin != null) {
			g2d_origin.g2d_clones.remove(this);
			if (g2d_element != null) {
				g2d_element.onModelChanged.remove(elementModelChanged_handler);
				g2d_element = null;
			}
        }
    }
	
	private function invalidateClones():Void {	
	}
	
	public function captureMouseInput(p_input:GMouseInput):Void {
	}

    private function elementModelChanged_handler(p_element:GUIElement):Void {
    }

    private function clone():GUISkin {
        return null;
    }
	
	private function g2d_internalDispose():Void {
		if (g2d_origin == null) {
			while (g2d_clones.length > 0) {
				g2d_clones[0].remove();
			}
		} else {
			g2d_origin.dispose();
		}
	}

    public function dispose():Void {
		g2d_internalDispose();
		
		if (g2d_origin == null && GUISkinManager.getSkin(id) != null) GUISkinManager.g2d_removeSkin(id);
    }
	
	/*
	 * 	Get an instance from reference
	 */
	static public function fromReference(p_reference:String):GUISkin {
		var skin:GUISkin = GUISkinManager.getSkin(p_reference.substr(1));
		if (skin == null) GDebug.warning("Invalid skin reference", p_reference);
		return skin;
	}
	
	public function toReference():String {
		return "@"+id;
	}
}
