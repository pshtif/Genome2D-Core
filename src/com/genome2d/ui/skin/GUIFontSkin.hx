package com.genome2d.ui.skin;
import com.genome2d.textures.GContextTexture;
import com.genome2d.textures.GTextureManager;
import com.genome2d.textures.GTextureFontAtlas;

@prototypeName("skinFont")
class GUIFontSkin extends GUISkin {
    public var fontAtlas:GTextureFontAtlas;

    #if swc @:extern #end
    @prototype public var fontAtlasId(get, set):String;
    #if swc @:getter(fontAtlasId) #end
    inline private function get_fontAtlasId():String {
        return (fontAtlas != null) ? fontAtlas.id : "";
    }
    #if swc @:setter(fontAtlasId) #end
    inline private function set_fontAtlasId(p_value:String):String {
        fontAtlas = GTextureManager.getFontAtlasById(p_value);
        return p_value;
    }

    override public function getTexture():GContextTexture {
        return fontAtlas;
    }
}
