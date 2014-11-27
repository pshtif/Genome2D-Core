package com.genome2d.ui.controls;
import com.genome2d.ui.utils.GUIPositionType;
import com.genome2d.prototype.IGPrototypable;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.context.IContext;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.signals.GMouseSignal;
import msignal.Signal.Signal2;
import com.genome2d.textures.GContextTexture;

@prototypeName("control")
class GUIControl implements IGPrototypable {
    static public var smartBatching:Bool = false;
    static private var postponedRender:Array<GUIControl> = new Array<GUIControl>();
    static private var g2d_batchTexture:GContextTexture;
    static public function clearBatchState():Void {
        g2d_batchTexture = null;
    }
    static public function checkBatchState(p_control:GUIControl):Bool {
        var texture:GContextTexture = (p_control.g2d_activeSkin != null) ? p_control.g2d_activeSkin.getTexture() : null;
        if (g2d_batchTexture != null && texture != null && g2d_batchTexture.nativeTexture != texture.nativeTexture) {
            postponedRender.push(p_control);
            return true;
        }

        g2d_batchTexture = texture;
        return false;
    }
    static public function flushBatch():Void {
        var count:Int = postponedRender.length;
        for (i in 0...count) {
            var control:GUIControl = postponedRender.shift();
            if (control.render(control.g2d_worldX, control.g2d_worldY)) count--;
        }
        clearBatchState();
        if (postponedRender.length>0) flushBatch();
    }

    public var forceBreakBatch:Bool;

    public var position:Int;

    public var name:String;
    public var enabled:Bool;
    public var mouseEnabled:Bool;
    public var visible:Bool;

    private var g2d_activeSkin:GUISkin;

    private var g2d_dirty:Bool;
    inline public function isDirty():Bool {
        return g2d_dirty;
    }
    inline public function setDirty():Void {
        g2d_dirty = true;
        if (g2d_parent != null) g2d_parent.setDirty();
    }

    public var useSkinSize:Bool;

    public var g2d_worldX:Float;
    public var g2d_worldY:Float;

    public var g2d_flowX:Float;
    public var g2d_flowY:Float;

    #if swc @:extern #end
    public var x(get, never):Float;
    #if swc @:getter(x) #end
    public function get_x():Float {
        return g2d_worldX + g2d_flowX + style.marginLeft;
    }

    #if swc @:extern #end
    public var y(get, never):Float;
    #if swc @:getter(y) #end
    inline private function get_y():Float {
        return g2d_worldY + g2d_flowY + style.marginTop;
    }

    private var g2d_width:Float;
    #if swc @:extern #end
    public var width(get, set):Float;
    #if swc @:getter(width) #end
    inline private function get_width():Float {
        return g2d_width;
    }
    #if swc @:setter(width) #end
    inline private function set_width(p_value:Float):Float {
        g2d_width = p_value;
        setDirty();
        return g2d_width;
    }

    private var g2d_height:Float;
    #if swc @:extern #end
    public var height(get, set):Float;
    #if swc @:getter(height) #end
    inline private function get_height():Float {
        return g2d_height;
    }
    #if swc @:setter(height) #end
    inline private function set_height(p_value:Float):Float {
        g2d_height = p_value;
        setDirty();
        return g2d_height;
    }

    public var g2d_parent:GUIContainer;
    public var g2d_mouseOver:Bool;

    private var g2d_style:GUIStyle;
    #if swc @:extern #end
    public var style(get, set):GUIStyle;
    #if swc @:getter(style) #end
    inline private function get_style():GUIStyle {
        return g2d_style;
    }
    #if swc @:setter(style) #end
    inline private function set_style(p_value:GUIStyle):GUIStyle {
        if (g2d_style != null) g2d_style.onChange.remove(setDirty);
        g2d_style = p_value;
        if (g2d_style != null) {
            g2d_style.onChange.add(setDirty);
            g2d_activeSkin = style.normalSkin;
        } else {
            g2d_style = GUIStyleManager.getDefaultStyle().clone();
        }
        setDirty();
        return g2d_style;
    }

    #if swc @:extern #end
    public var styleId(get, set):String;
    #if swc @:getter(styleId) #end
    inline private function get_styleId():String {
        return (g2d_style != null) ? g2d_style.id : "";
    }
    #if swc @:setter(styleId) #end
    inline private function set_styleId(p_value:String):String {
        style = GUIStyleManager.getStyleById(p_value);
        return (g2d_style != null) ? g2d_style.id : "";
    }

    #if swc @:extern #end
    public var flowWidth(get, never):Float;
    #if swc @:getter(flowWidth) #end
    inline private function get_flowWidth():Float {
        return style.marginLeft+g2d_width+style.marginRight;
    }

    #if swc @:extern #end
    public var flowHeight(get, never):Float;
    #if swc @:getter(flowHeight) #end
    inline private function get_flowHeight():Float {
        return style.marginTop+g2d_height+style.marginBottom;
    }

    public function new(p_style:GUIStyle = null) {
        initDefault();

        style = p_style;
    }

    private function initDefault():Void {
        position = GUIPositionType.RELATIVE;

        forceBreakBatch = false;
        enabled = true;
        mouseEnabled = true;
        visible = true;
        g2d_dirty = true;

        useSkinSize = false;
        g2d_worldX = g2d_worldY = 0;
        g2d_flowX = g2d_flowY = 0;
        g2d_width = g2d_height = 100;
        g2d_mouseOver = false;
    }

    private function init():Void {

    }

    public function invalidate():Void {
        if (g2d_dirty || g2d_style.g2d_usePercentageHorizontal || g2d_style.g2d_usePercentageVertical) {
            //if (useSkinSize) {
                g2d_width = (g2d_activeSkin != null) ? g2d_activeSkin.getMinWidth() : 0;
                g2d_height = (g2d_activeSkin != null) ? g2d_activeSkin.getMinHeight() : 0;
            //}
        }
        g2d_dirty = false;
    }

    public function render(p_x:Float, p_y:Float):Bool {
        g2d_worldX = p_x;
        g2d_worldY = p_y;

        if (smartBatching) {
            if (forceBreakBatch || !checkBatchState(this)) {
                if (forceBreakBatch) flushBatch();
                var context:IContext = Genome2D.getInstance().getContext();
                if (g2d_activeSkin != null) g2d_activeSkin.render(x, y, width, height);
                return true;
            }
            return false;
        }

        var context:IContext = Genome2D.getInstance().getContext();
        if (g2d_activeSkin != null) g2d_activeSkin.render(x, y, width, height);

        return true;
    }

    private var g2d_onMouseUp:Signal2<GUIControl,GMouseSignal>;
    #if swc @:extern #end
    public var onMouseUp(get,never):Signal2<GUIControl,GMouseSignal>;
    #if swc @:getter(onMouseUp) #end
    inline private function get_onMouseUp():Signal2<GUIControl, GMouseSignal> {
        if (g2d_onMouseUp == null) g2d_onMouseUp = new Signal2(GUIControl, GMouseSignal);
        return g2d_onMouseUp;
    }

    private var g2d_onMouseDown:Signal2<GUIControl,GMouseSignal>;
    #if swc @:extern #end
    public var onMouseDown(get,never):Signal2<GUIControl,GMouseSignal>;
    #if swc @:getter(onMouseDown) #end
    inline private function get_onMouseDown():Signal2<GUIControl, GMouseSignal> {
        if (g2d_onMouseDown == null) g2d_onMouseDown = new Signal2(GUIControl, GMouseSignal);
        return g2d_onMouseDown;
    }

    public function processMouseSignal(p_captured:Bool, p_x:Float, p_y:Float, p_contextSignal:GMouseSignal):Bool {
        if (!visible) return p_captured;

        if (!p_captured && g2d_mouseOver && p_contextSignal.type == GMouseSignalType.MOUSE_UP && g2d_onMouseUp != null) onMouseUp.dispatch(this, p_contextSignal);
        if (!p_captured && g2d_mouseOver && p_contextSignal.type == GMouseSignalType.MOUSE_DOWN && g2d_onMouseDown != null) onMouseDown.dispatch(this, p_contextSignal);

        if (g2d_parent.g2d_mouseOver && !p_captured && p_x>=x && p_x<=x+width && p_y>=y && p_y<=y+height) {
            g2d_mouseOver = true;
            if (g2d_style.overSkin != null) g2d_activeSkin = g2d_style.overSkin;
            return true;
        } else {
            if (g2d_mouseOver) {
                g2d_mouseOver = false;
                g2d_activeSkin = g2d_style.normalSkin;
            }
            return false;
        }
    }
}
