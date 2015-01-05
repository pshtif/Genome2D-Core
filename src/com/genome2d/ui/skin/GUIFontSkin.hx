package com.genome2d.ui.skin;
import com.genome2d.context.IContext;
import com.genome2d.text.GTextureTextRenderer;
import com.genome2d.textures.GContextTexture;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTextureFontAtlas;

@prototypeName("fontSkin")
class GUIFontSkin extends GUISkin {

    private var g2d_text:String;
    #if swc @:extern #end
    @prototype public var text(get, set):String;
    #if swc @:getter(text) #end
    inline private function get_text():String {
        return g2d_text;
    }
    #if swc @:setter(text) #end
    inline private function set_text(p_value:String):String {
        g2d_text = p_value;

        return g2d_text;
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

    override public function getTexture():GContextTexture {
        return g2d_textRenderer.textureAtlas;
    }

    public function new(p_id:String = "") {
        super(p_id);

        g2d_textRenderer = new GTextureTextRenderer();
        g2d_textRenderer.autoSize = true;
        g2d_textRenderer.text = "Hello world";
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Void {
        var context:IContext = Genome2D.getInstance().getContext();

        g2d_textRenderer.width = p_right - p_left;
        g2d_textRenderer.height = p_bottom - p_top;
        g2d_textRenderer.render(p_left,p_top,1,1,0);
    }
}
