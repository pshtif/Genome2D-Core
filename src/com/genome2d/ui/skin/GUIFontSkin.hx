package com.genome2d.ui.skin;
import com.genome2d.input.GMouseInput;
import com.genome2d.text.GFontManager;
import com.genome2d.text.GTextureFont;
import com.genome2d.ui.element.GUIElement;
import com.genome2d.ui.skin.GUIFontSkin;
import com.genome2d.context.IGContext;
import com.genome2d.text.GTextureTextRenderer;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;

@prototypeName("fontSkin")
class GUIFontSkin extends GUISkin {
	
	#if swc @:extern #end
    @prototype
	public var vAlign(get, set):Int;
    #if swc @:getter(vAlign) #end
    inline private function get_vAlign():Int {
        return g2d_textRenderer.vAlign;
    }
    #if swc @:setter(vAlign) #end
    inline private function set_vAlign(p_value:Int):Int {
        g2d_textRenderer.vAlign = p_value;
        return p_value;
    }
	
	#if swc @:extern #end
    @prototype
	public var hAlign(get, set):Int;
    #if swc @:getter(hAlign) #end
    inline private function get_hAlign():Int {
        return g2d_textRenderer.hAlign;
    }
    #if swc @:setter(hAlign) #end
    inline private function set_hAlign(p_value:Int):Int {
        g2d_textRenderer.hAlign = p_value;
        return p_value;
    }
	
	#if swc @:extern #end
    @prototype
	public var color(get, set):Int;
	#if swc @:getter(color) #end
    inline private function get_color():Int {
        var color:Int = 0;
		color += Std.int(g2d_textRenderer.red * 0xFF) << 16;
		color += Std.int(g2d_textRenderer.green * 0xFF) << 8;
		color += Std.int(g2d_textRenderer.blue * 0xFF);
		return color;
    }
	#if swc @:setter(color) #end
	inline public function set_color(p_value:Int):Int {
		red = Std.int(p_value >> 16 & 0xFF) / 0xFF;
        green = Std.int(p_value >> 8 & 0xFF) / 0xFF;
        blue = Std.int(p_value & 0xFF) / 0xFF;
		return p_value;
	}
	
	#if swc @:extern #end
    @prototype
	public var red(get, set):Float;
    #if swc @:getter(red) #end
    inline private function get_red():Float {
        return g2d_textRenderer.red;
    }
    #if swc @:setter(red) #end
    inline private function set_red(p_value:Float):Float {
        g2d_textRenderer.red = p_value;
        return p_value;
    }
	
	#if swc @:extern #end
    @prototype
	public var green(get, set):Float;
    #if swc @:getter(green) #end
    inline private function get_green():Float {
        return g2d_textRenderer.green;
    }
    #if swc @:setter(green) #end
    inline private function set_green(p_value:Float):Float {
        g2d_textRenderer.green = p_value;
        return p_value;
    }
	
	#if swc @:extern #end
    @prototype
	public var blue(get, set):Float;
    #if swc @:getter(blue) #end
    inline private function get_blue():Float {
        return g2d_textRenderer.blue;
    }
    #if swc @:setter(blue) #end
    inline private function set_blue(p_value:Float):Float {
        g2d_textRenderer.blue = p_value;
        return p_value;
    }
	
	#if swc @:extern #end
    @prototype
	public var alpha(get, set):Float;
    #if swc @:getter(alpha) #end
    inline private function get_alpha():Float {
        return g2d_textRenderer.alpha;
    }
    #if swc @:setter(alpha) #end
    inline private function set_alpha(p_value:Float):Float {
        g2d_textRenderer.alpha = p_value;
        return p_value;
    }
	
    #if swc @:extern #end
	public var text(get, set):String;
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
    @prototype
	public var autoSize(get, set):Bool;
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
    @prototype 
	public var fontScale(get, set):Float;
    #if swc @:getter(fontScale) #end
    inline private function get_fontScale():Float {
        return g2d_textRenderer.fontScale;
    }
    #if swc @:setter(fontScale) #end
    inline private function set_fontScale(p_value:Float):Float {
        g2d_textRenderer.fontScale = p_value;
        return p_value;
    }
	
	#if swc @:extern #end
    @prototype
	public var fontId(get, set):String;
    #if swc @:getter(fontId) #end
    inline private function get_fontId():String {
        return g2d_textRenderer.textureFont.id;
    }
    #if swc @:setter(fontId) #end
    inline private function set_fontId(p_value:String):String {
        g2d_textRenderer.textureFont = GFontManager.getFont(p_value);
        return p_value;
    }
	
	#if swc @:extern #end
    public var cursorStartIndex(get, set):Int;
    #if swc @:getter(cursorStartIndex) #end
    inline private function get_cursorStartIndex():Int {
        return g2d_textRenderer.cursorStartIndex;
    }
    #if swc @:setter(cursorStartIndex) #end
    inline private function set_cursorStartIndex(p_value:Int):Int {
        g2d_textRenderer.cursorStartIndex = p_value;

        return p_value;
    }
	
	#if swc @:extern #end
    public var cursorEndIndex(get, set):Int;
    #if swc @:getter(cursorEndIndex) #end
    inline private function get_cursorEndIndex():Int {
        return g2d_textRenderer.cursorEndIndex;
    }
    #if swc @:setter(cursorEndIndex) #end
    inline private function set_cursorEndIndex(p_value:Int):Int {
        g2d_textRenderer.cursorEndIndex = p_value;

        return p_value;
    }

    override public function getTexture():GTexture {
        return (g2d_textRenderer != null && g2d_textRenderer.textureFont != null) ? g2d_textRenderer.textureFont.texture : null;
    }

    override public function getMinWidth():Float {
        return autoSize ? g2d_textRenderer.width*fontScale : 0;
    }

    override public function getMinHeight():Float {
        return autoSize ? g2d_textRenderer.height*fontScale : 0;
    }

    public function new(p_id:String = "", p_font:GTextureFont = null, p_fontScale:Float = 1, p_autoSize:Bool = true, p_origin:GUIFontSkin = null) {
        super(p_id, p_origin);

        g2d_textRenderer = new GTextureTextRenderer();
        g2d_textRenderer.autoSize = p_autoSize;

        if (p_font != null) fontId = p_font.id;
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

    override private function elementModelChanged_handler(p_element:GUIElement):Void {
        text =  (p_element.getModel() != null) ? p_element.getModel().toString() : "";
    }

    override public function clone():GUISkin {
        var clone:GUIFontSkin = new GUIFontSkin("", g2d_textRenderer.textureFont, fontScale, autoSize, (g2d_origin == null)?this:cast g2d_origin);
		clone.red = red;
		clone.green = green;
		clone.blue = blue;
		clone.alpha = alpha;
		clone.color = color;
		clone.vAlign = vAlign;
		clone.hAlign = hAlign;
        return clone;
    }
	
	override public function captureMouseInput(p_input:GMouseInput):Void {
		g2d_textRenderer.captureMouseInput(p_input);
	}
}
