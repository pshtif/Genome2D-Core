package com.genome2d.ui;
import com.genome2d.prototype.IGPrototypable;
import com.genome2d.ui.GUIStyleManager;
import com.genome2d.ui.GUIStyleManager;
import com.genome2d.ui.GUIStyleManager;
import com.genome2d.ui.GUIStyleManager;
import com.genome2d.error.GError;
import msignal.Signal;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.utils.GHAlignType;
import com.genome2d.utils.GVAlignType;


@prototypeName("style")
class GUIStyle implements IGPrototypable {

    #if swc @:extern #end
    @prototype public var id(default, null):String;

    public var g2d_autoMargin:Bool;
    #if swc @:extern #end
    @prototype public var autoMargin(get, set):Bool;
    #if swc @:getter(autoMargin) #end
    inline private function get_autoMargin():Bool {
        return g2d_autoMargin;
    }
    #if swc @:setter(autoMargin) #end
    inline private function set_autoMargin(p_value:Bool):Bool {
        g2d_autoMargin = p_value;
        onChange.dispatch();
        return g2d_autoMargin;
    }

    public var g2d_marginLeft:Float;
    #if swc @:extern #end
    @prototype public var marginLeft(get, set):Float;
    #if swc @:getter(marginLeft) #end
    inline private function get_marginLeft():Float {
        return g2d_marginLeft;
    }
    #if swc @:setter(marginLeft) #end
    inline private function set_marginLeft(p_value:Float):Float {
        g2d_marginLeft = p_value;
        onChange.dispatch();
        return g2d_marginLeft;
    }

    public var g2d_marginRight:Float;
    #if swc @:extern #end
    public var marginRight(get, set):Float;
    #if swc @:getter(marginRight) #end
    inline private function get_marginRight():Float {
        return g2d_marginRight;
    }
    #if swc @:setter(marginRight) #end
    inline private function set_marginRight(p_value:Float):Float {
        g2d_marginRight = p_value;
        onChange.dispatch();
        return g2d_marginRight;
    }

    public var g2d_marginTop:Float;
    #if swc @:extern #end
    public var marginTop(get, set):Float;
    #if swc @:getter(marginTop) #end
    inline private function get_marginTop():Float {
        return g2d_marginTop;
    }
    #if swc @:setter(marginTop) #end
    inline private function set_marginTop(p_value:Float):Float {
        g2d_marginTop = p_value;
        onChange.dispatch();
        return g2d_marginTop;
    }

    public var g2d_marginBottom:Float;
    #if swc @:extern #end
    public var marginBottom(get, set):Float;
    #if swc @:getter(marginBottom) #end
    inline private function get_marginBottom():Float {
        return g2d_marginBottom;
    }
    #if swc @:setter(marginBottom) #end
    inline private function set_marginBottom(p_value:Float):Float {
        g2d_marginBottom = p_value;
        onChange.dispatch();
        return g2d_marginBottom;
    }

    public var g2d_autoSize:Bool;
    #if swc @:extern #end
    public var autoSize(get, set):Bool;
    #if swc @:getter(autoSize) #end
    inline private function get_autoSize():Bool {
        return g2d_autoSize;
    }
    #if swc @:setter(autoSize) #end
    inline private function set_autoSize(p_value:Bool):Bool {
        g2d_autoSize = p_value;
        onChange.dispatch();
        return g2d_autoSize;
    }

    private var g2d_textVAlign:Int;
    #if swc @:extern #end
    public var textVAlign(get, set):Int;
    #if swc @:getter(textVAlign) #end
    inline private function get_textVAlign():Int {
        return g2d_textVAlign;
    }
    #if swc @:setter(textVAlign) #end
    inline private function set_textVAlign(p_value:Int):Int {
        g2d_textVAlign = p_value;
        onChange.dispatch();
        return g2d_textVAlign;
    }

    private var g2d_textHAlign:Int;
    #if swc @:extern #end
    public var textHAlign(get, set):Int;
    #if swc @:getter(textHAlign) #end
    inline private function get_textHAlign():Int {
        return g2d_textHAlign;
    }
    #if swc @:setter(textHAlign) #end
    inline private function set_textHAlign(p_value:Int):Int {
        g2d_textHAlign = p_value;
        onChange.dispatch();
        return g2d_textHAlign;
    }

    private var g2d_fontAtlasId:String;
    #if swc @:extern #end
    public var fontAtlasId(get, set):String;
    #if swc @:getter(fontAtlasId) #end
    inline private function get_fontAtlasId():String {
        return g2d_fontAtlasId;
    }
    #if swc @:setter(fontAtlasId) #end
    inline private function set_fontAtlasId(p_value:String):String {
        g2d_fontAtlasId = p_value;
        onChange.dispatch();
        return g2d_fontAtlasId;
    }

    public var fontScale:Float;

    private var g2d_onChange:Signal0;
    #if swc @:extern #end
    public var onChange(get, never):Signal0;
    #if swc @:getter(onChange) #end
    inline private function get_onChange():Signal0 {
        if (g2d_onChange == null) g2d_onChange = new Signal0();
        return g2d_onChange;
    }

    private var g2d_layout:Int;
    #if swc @:extern #end
    public var layout(get, set):Int;
    #if swc @:getter(layout) #end
    inline private function get_layout():Int {
        return g2d_layout;
    }
    #if swc @:setter(layout) #end
    inline private function set_layout(p_value:Int):Int {
        g2d_layout = p_value;
        onChange.dispatch();
        return g2d_layout;
    }

    private var g2d_usePercentageWidth:Bool;
    private var g2d_minWidth:Float;
    #if swc @:extern #end
    @prototype public var minWidth(get, set):Float;
    #if swc @:getter(minWidth) #end
    inline private function get_minWidth():Float {
        return g2d_minWidth;
    }
    #if swc @:setter(minWidth) #end
    inline private function set_minWidth(p_value:Float):Float {
        if (p_value<0) p_value = 0;
        g2d_minWidth = p_value;
        if (g2d_minWidth>g2d_maxWidth) g2d_maxWidth = g2d_minWidth;
        onChange.dispatch();
        return g2d_minWidth;
    }

    private var g2d_usePercentageHeight:Bool;
    private var g2d_minHeight:Float;
    #if swc @:extern #end
    @prototype public var minHeight(get, set):Float;
    #if swc @:getter(minHeight) #end
    inline private function get_minHeight():Float {
        return g2d_minHeight;
    }
    #if swc @:setter(minHeight) #end
    inline private function set_minHeight(p_value:Float):Float {
        if (p_value<0) p_value = 0;
        g2d_minHeight = p_value;
        if (g2d_minHeight>g2d_maxHeight) g2d_maxHeight = g2d_minHeight;
        onChange.dispatch();
        return g2d_minHeight;
    }

    private var g2d_maxWidth:Float;
    #if swc @:extern #end
    public var maxWidth(get, set):Float;
    #if swc @:getter(maxWidth) #end
    inline private function get_maxWidth():Float {
        return g2d_maxWidth;
    }
    #if swc @:setter(maxWidth) #end
    inline private function set_maxWidth(p_value:Float):Float {
        if (p_value<0) p_value = 0;
        g2d_maxWidth = p_value;
        if (g2d_maxWidth<g2d_minWidth) g2d_minWidth = g2d_maxWidth;
        onChange.dispatch();
        return g2d_maxWidth;
    }

    private var g2d_maxHeight:Float;
    #if swc @:extern #end
    public var maxHeight(get, set):Float;
    #if swc @:getter(maxHeight) #end
    inline private function get_maxHeight():Float {
        return g2d_maxHeight;
    }
    #if swc @:setter(maxHeight) #end
    inline private function set_maxHeight(p_value:Float):Float {
        if (p_value<0) p_value = 0;
        g2d_maxHeight = p_value;
        if (g2d_maxHeight<g2d_minHeight) g2d_minHeight = g2d_maxHeight;
        onChange.dispatch();
        return g2d_maxHeight;
    }

    public var g2d_usePercentageVertical:Bool;
    public var g2d_useLeft:Bool;
    private var g2d_left:Float = 0;
    #if swc @:extern #end
    public var left(get, set):Float;
    #if swc @:getter(left) #end
    inline private function get_left():Float {
        return g2d_left;
    }
    #if swc @:setter(left) #end
    inline private function set_left(p_value:Float):Float {
        g2d_useLeft = true;
        g2d_left = p_value;
        onChange.dispatch();
        return g2d_left;
    }

    private var g2d_right:Float;
    #if swc @:extern #end
    public var right(get, set):Float;
    #if swc @:getter(right) #end
    inline private function get_right():Float {
        return g2d_right;
    }
    #if swc @:setter(right) #end
    inline private function set_right(p_value:Float):Float {
        g2d_useLeft = false;
        g2d_right = p_value;
        onChange.dispatch();
        return g2d_right;
    }

    public var g2d_usePercentageHorizontal:Bool;
    public var g2d_useTop:Bool;
    private var g2d_top:Float;
    #if swc @:extern #end
    public var top(get, set):Float;
    #if swc @:getter(top) #end
    inline private function get_top():Float {
        return g2d_top;
    }
    #if swc @:setter(top) #end
    inline private function set_top(p_value:Float):Float {
        g2d_useTop = true;
        g2d_top = p_value;
        onChange.dispatch();
        return g2d_top;
    }

    private var g2d_bottom:Float;
    #if swc @:extern #end
    public var bottom(get, set):Float;
    #if swc @:getter(bottom) #end
    inline private function get_bottom():Float {
        return g2d_bottom;
    }
    #if swc @:setter(bottom) #end
    inline private function set_bottom(p_value:Float):Float {
        g2d_useTop = false;
        g2d_bottom = p_value;
        onChange.dispatch();
        return g2d_bottom;
    }

    public var normalSkin:GUISkin;
    #if swc @:extern #end
    @prototype public var normalSkinId(get, set):String;
    #if swc @:getter(normalSkinId) #end
    inline private function get_normalSkinId():String {
        return (normalSkin!=null) ? normalSkin.id : "";
    }
    #if swc @:setter(normalSkinId) #end
    inline private function set_normalSkinId(p_value:String):String {
        normalSkin = GUISkinManager.getSkinById(p_value);
        return (normalSkin != null) ? normalSkin.id : "";
    }

    public var overSkin:GUISkin;
    #if swc @:extern #end
    public var overSkinId(get, set):String;
    #if swc @:getter(overSkinId) #end
    inline private function get_overSkinId():String {
        return (overSkin!=null) ? overSkin.id : "";
    }
    #if swc @:setter(overSkinId) #end
    inline private function set_overSkinId(p_value:String):String {
        overSkin = GUISkinManager.getSkinById(p_value);
        return (overSkin != null) ? overSkin.id : "";
    }

    public function new(p_id:String) {
        initDefault();
        id = p_id;
        init();
    }

    private function initDefault():Void {
        g2d_left = g2d_right = g2d_top = g2d_bottom = 0;
        g2d_marginLeft = g2d_marginRight = g2d_marginTop = g2d_marginBottom = 0;
        g2d_maxWidth = g2d_maxHeight = g2d_minWidth = g2d_minHeight = 0;
        g2d_textHAlign = GHAlignType.LEFT;
        g2d_textVAlign = GVAlignType.TOP;
        fontScale = 1;
        g2d_usePercentageVertical = g2d_usePercentageHorizontal = g2d_usePercentageWidth = g2d_usePercentageHeight = false;
        g2d_autoMargin = g2d_autoSize = false;
        g2d_useTop = g2d_useLeft = true;
    }

    @:access(com.genome2d.ui.GUIStyleManager)
    public function init():Void {
        if (id != null && id.length>0) {
            if (GUIStyleManager.g2d_references == null) GUIStyleManager.g2d_references = new Map<String, GUIStyle>();
            //if (GUIStyleManager.g2d_references[id] != null) new GError("Duplicate style id: "+id);
            GUIStyleManager.g2d_references[id] = this;
        }

        g2d_onChange = new Signal0();
    }

    public function clone():GUIStyle {
        trace(marginTop, id);
        var style:GUIStyle = new GUIStyle("");
        style.marginLeft = marginLeft;
        style.marginRight = marginRight;
        style.marginTop = marginTop;
        style.marginBottom = marginBottom;

        style.autoSize = autoSize;
        style.textHAlign = textHAlign;
        style.textVAlign = textVAlign;
        style.fontAtlasId = fontAtlasId;
        style.fontScale = fontScale;

        style.normalSkinId = normalSkinId;
        style.overSkinId = overSkinId;

        return style;
    }
}
