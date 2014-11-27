package com.genome2d.ui.controls;
import com.genome2d.textures.GTextureFontAtlas;
import com.genome2d.textures.GContextTexture;
import com.genome2d.text.GTextureTextRenderer;
class GUILabel extends GUIControl {
    private var g2d_textRenderer:GTextureTextRenderer;

    private var g2d_text:String = "";
    #if swc @:extern #end
    @prototype public var text(get, set):String;
    #if swc @:getter(text) #end
    public function get_text():String {
        return g2d_text;
    }
    #if swc @:setter(text) #end
    public function set_text(p_value:String):String {
        g2d_text = p_value;
        setDirty();
        return g2d_text;
    }

    public function new(p_style:GUIStyle = null):Void {
        super(p_style);

        g2d_textRenderer = new GTextureTextRenderer();
    }

    override public function invalidate():Void {
        if (g2d_dirty) {
            g2d_textRenderer.autoSize = style.autoSize;
            g2d_textRenderer.textureAtlas = cast g2d_activeSkin.getTexture();
            g2d_textRenderer.vAlign = style.textVAlign;
            g2d_textRenderer.hAlign = style.textHAlign;

            g2d_textRenderer.autoSize = style.autoSize;
            if (!g2d_textRenderer.autoSize && g2d_activeSkin != null) {
                g2d_textRenderer.width = g2d_width/g2d_activeSkin.scale;
                g2d_textRenderer.height = g2d_height/g2d_activeSkin.scale;
            }
            g2d_textRenderer.text = g2d_text;
            if (g2d_textRenderer.autoSize) {
                g2d_width = g2d_textRenderer.width;
                g2d_height = g2d_textRenderer.height;
            }
        }
        super.invalidate();
    }

    override public function render(p_x:Float, p_y:Float):Bool {
        var immediateRender = super.render(p_x, p_y);
        if (immediateRender) {
            g2d_textRenderer.render(x, y, g2d_activeSkin.scale, g2d_activeSkin.scale, 0);
        }
        return immediateRender;
    }
}
