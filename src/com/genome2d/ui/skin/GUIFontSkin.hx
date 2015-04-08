package com.genome2d.ui.skin;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.ui.skin.GUIFontSkin;
import com.genome2d.context.IContext;
import com.genome2d.text.GTextureTextRenderer;
import com.genome2d.textures.GContextTexture;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTextureFontAtlas;

@prototypeName("fontSkin")
class GUIFontSkin extends GUISkin {

    #if swc @:extern #end
    @prototype public var text(get, set):String;
    #if swc @:getter(text) #end
    inline private function get_text():String {
        return g2d_textRenderer.text;
    }
    #if swc @:setter(text) #end
    inline private function set_text(p_value:String):String {
        g2d_textRenderer.text = p_value;

        return p_value;
    }

    #if swc @:extern #end
    @prototype public var autoSize(get, set):Bool;
    #if swc @:getter(autoSize) #end
    inline private function get_autoSize():Bool {
        return g2d_textRenderer.autoSize;
    }
    #if swc @:setter(autoSize) #end
    inline private function set_autoSize(p_value:Bool):Bool {
        g2d_textRenderer.autoSize = p_value;

        return p_value;
    }

    private var g2d_textRenderer:GTextureTextRenderer;
    #if swc @:extern #end
    public var textRenderer(get, never):GTextureTextRenderer;
    #if swc @:getter(textRenderer) #end
    inline private function get_textRenderer():GTextureTextRenderer {
        return g2d_textRenderer;
    }

    #if swc @:extern #end
    @prototype public var fontAtlasId(get, set):String;
    #if swc @:getter(fontAtlasId) #end
    inline private function get_fontAtlasId():String {
        return g2d_textRenderer.textureAtlasId;
    }
    #if swc @:setter(fontAtlasId) #end
    inline private function set_fontAtlasId(p_value:String):String {
        g2d_textRenderer.textureAtlasId = p_value;
        return p_value;
    }

    #if swc @:extern #end
    @prototype public var fontScale(get, set):Float;
    #if swc @:getter(fontScale) #end
    inline private function get_fontScale():Float {
        return g2d_textRenderer.fontScale;
    }
    #if swc @:setter(fontScale) #end
    inline private function set_fontScale(p_value:Float):Float {
        g2d_textRenderer.fontScale = p_value;
        return p_value;
    }

    override public function getTexture():GContextTexture {
        return g2d_textRenderer.textureAtlas;
    }

    override public function getMinWidth():Float {
        return autoSize ? g2d_textRenderer.width*fontScale : 0;
    }

    override public function getMinHeight():Float {
        return autoSize ? g2d_textRenderer.height*fontScale : 0;
    }

    public function new(p_id:String = "", p_fontAtlasId:String = "", p_fontScale:Float = 1, p_autoSize:Bool = true) {
        super(p_id);

        g2d_textRenderer = new GTextureTextRenderer();
        g2d_textRenderer.autoSize = p_autoSize;

        if (p_fontAtlasId != "") fontAtlasId = p_fontAtlasId;
        fontScale = p_fontScale;
        autoSize = p_autoSize;
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Bool {
        var rendered:Bool = false;
        if (super.render(p_left, p_top, p_right, p_bottom)) {
            g2d_textRenderer.width = p_right - p_left;
            g2d_textRenderer.height = p_bottom - p_top;
            g2d_textRenderer.render(p_left, p_top, 1, 1, 0);
            rendered = true;
        }
        return rendered;
    }

    override private function elementValueChanged_handler(p_element:GUIElement):Void {
        text =  (p_element.getValue() != null) ? p_element.getValue().toString() : "";
    }

    override public function clone():GUISkin {
        var clone:GUIFontSkin = new GUIFontSkin("", fontAtlasId, fontScale, autoSize);
        return clone;
    }
}
