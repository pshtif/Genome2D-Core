package com.genome2d.ui.skin;
import com.genome2d.textures.GTexture;
import com.genome2d.error.GError;

class GUISkin {
    public var type:Float = 0;

    public function getMinWidth():Float {
        return 0;
    }
    public function getMinHeight():Float {
        return 0;
    }

    public function new(p_skinTextureIds:Array<String>) {
        if (p_skinTextureIds == null || p_skinTextureIds.length == 0) new GError("Invalid skin texture array.");
    }

    public function render(p_x:Float, p_y:Float):Void {
    }
}
