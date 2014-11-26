package com.genome2d.ui.skin;
import com.genome2d.prototype.IGPrototypable;
import com.genome2d.textures.GContextTexture;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.ui.GUISkinManager;
import com.genome2d.textures.GTexture;
import com.genome2d.error.GError;

class GUISkin implements IGPrototypable {
    public var type:Float;

    #if swc @:extern #end
    @prototype public var id(default, null):String;

    public function getMinWidth():Float {
        return 0;
    }
    public function getMinHeight():Float {
        return 0;
    }

    public function new(p_id:String) {
        id = p_id;
        init();
    }

    private function initDefault():Void {
        type = 0;
    }

    @:access(com.genome2d.ui.GUISkinManager)
    private function init():Void {
        if (id != null && id.length>0) {
            if (GUISkinManager.g2d_references == null) GUISkinManager.g2d_references = new Map<String, GUISkin>();
            if (GUISkinManager.g2d_references[id] != null) new GError("Duplicate style id: "+id);
            GUISkinManager.g2d_references[id] = this;
        }
    }

    public function render(p_x:Float, p_y:Float, p_width:Float, p_height:Float):Void {
    }

    public function getTexture():GContextTexture {
        return null;
    }
}
