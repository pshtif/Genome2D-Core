package com.genome2d.ui.idea;

import com.genome2d.ui.idea.GUIElement;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.ui.skin.GUISkin;

@:access(com.genome2d.ui.idea.GUILayout)
@prototypeName("element")
class GUIElement implements IGPrototypable {
    public var name:String;
    public var mouseEnabled:Bool;

    private var g2d_layout:GUILayout;
    #if swc @:extern #end
    @prototype public var layout(get, set):GUILayout;
    #if swc @:getter(layout) #end
    inline private function get_layout():GUILayout {
        return g2d_layout;
    }
    #if swc @:setter(layout) #end
    inline private function set_layout(p_value:GUILayout):GUILayout {
        g2d_layout = p_value;
        setDirty();
        return g2d_layout;
    }


    private var g2d_activeSkin:GUISkin;

    #if swc @:extern #end
    @prototype public var normalSkinId(get, set):String;
    #if swc @:getter(normalSkinId) #end
    inline private function get_normalSkinId():String {
        return (g2d_normalSkin != null) ? g2d_normalSkin.id : "";
    }
    #if swc @:setter(normalSkinId) #end
    inline private function set_normalSkinId(p_value:String):String {
        normalSkin = GUISkinManager.getSkinById(p_value);
        return normalSkinId;
    }

    private var g2d_normalSkin:GUISkin;
    #if swc @:extern #end
    public var normalSkin(get, set):GUISkin;
    #if swc @:getter(normalSkin) #end
    inline private function get_normalSkin():GUISkin {
        return g2d_normalSkin;
    }
    #if swc @:setter(normalSkin) #end
    inline private function set_normalSkin(p_value:GUISkin):GUISkin {
        g2d_normalSkin = p_value;
        g2d_activeSkin = g2d_normalSkin;
        setDirty();
        return g2d_normalSkin;
    }


    private var g2d_dirty:Bool = true;
    private function setDirty():Void {
        g2d_dirty = true;
        if (g2d_parent != null) g2d_parent.setDirty();
    }

    private var g2d_anchorX:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorX(get, set):Float;
    #if swc @:getter(anchorX) #end
    inline private function get_anchorX():Float {
        return g2d_anchorX;
    }
    #if swc @:setter(anchorX) #end
    inline private function set_anchorX(p_value:Float):Float {
        g2d_anchorX = p_value;
        setDirty();
        return g2d_anchorX;
    }

    private var g2d_anchorY:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorY(get, set):Float;
    #if swc @:getter(anchorY) #end
    inline private function get_anchorY():Float {
        return g2d_anchorY;
    }
    #if swc @:setter(anchorY) #end
    inline private function set_anchorY(p_value:Float):Float {
        g2d_anchorY = p_value;
        setDirty();
        return g2d_anchorY;
    }

    private var g2d_anchorLeft:Float = .5;
    #if swc @:extern #end
    @prototype public var anchorLeft(get, set):Float;
    #if swc @:getter(anchorLeft) #end
    inline private function get_anchorLeft():Float {
        return g2d_anchorLeft;
    }
    #if swc @:setter(anchorLeft) #end
    inline private function set_anchorLeft(p_value:Float):Float {
        g2d_anchorLeft = p_value;
        setDirty();
        return g2d_anchorLeft;
    }

    private var g2d_anchorTop:Float = .5;
    #if swc @:extern #end
    @prototype public var anchorTop(get, set):Float;
    #if swc @:getter(anchorTop) #end
    inline private function get_anchorTop():Float {
        return g2d_anchorTop;
    }
    #if swc @:setter(anchorTop) #end
    inline private function set_anchorTop(p_value:Float):Float {
        g2d_anchorTop = p_value;
        setDirty();
        return g2d_anchorTop;
    }

    private var g2d_anchorRight:Float = .5;
    #if swc @:extern #end
    @prototype public var anchorRight(get, set):Float;
    #if swc @:getter(anchorRight) #end
    inline private function get_anchorRight():Float {
        return g2d_anchorRight;
    }
    #if swc @:setter(anchorRight) #end
    inline private function set_anchorRight(p_value:Float):Float {
        g2d_anchorRight = p_value;
        setDirty();
        return g2d_anchorRight;
    }

    private var g2d_anchorBottom:Float = .5;
    #if swc @:extern #end
    @prototype public var anchorBottom(get, set):Float;
    #if swc @:getter(anchorBottom) #end
    inline private function get_anchorBottom():Float {
        return g2d_anchorBottom;
    }
    #if swc @:setter(anchorBottom) #end
    inline private function set_anchorBottom(p_value:Float):Float {
        g2d_anchorBottom = p_value;
        setDirty();
        return g2d_anchorBottom;
    }

    private var g2d_left:Float = 0;
    #if swc @:extern #end
    @prototype public var left(get, set):Float;
    #if swc @:getter(left) #end
    inline private function get_left():Float {
        return g2d_left;
    }
    #if swc @:setter(left) #end
    inline private function set_left(p_value:Float):Float {
        g2d_left = p_value;
        setDirty();
        return g2d_left;
    }

    private var g2d_top:Float = 0;
    #if swc @:extern #end
    @prototype public var top(get, set):Float;
    #if swc @:getter(top) #end
    inline private function get_top():Float {
        return g2d_top;
    }
    #if swc @:setter(top) #end
    inline private function set_top(p_value:Float):Float {
        g2d_top = p_value;
        setDirty();
        return g2d_top;
    }

    private var g2d_right:Float = 0;
    #if swc @:extern #end
    @prototype public var right(get, set):Float;
    #if swc @:getter(right) #end
    inline private function get_right():Float {
        return g2d_right;
    }
    #if swc @:setter(right) #end
    inline private function set_right(p_value:Float):Float {
        g2d_right = p_value;
        setDirty();
        return g2d_right;
    }

    public var g2d_bottom:Float = 0;
    #if swc @:extern #end
    @prototype public var bottom(get, set):Float;
    #if swc @:getter(bottom) #end
    inline private function get_bottom():Float {
        return g2d_bottom;
    }
    #if swc @:setter(bottom) #end
    inline private function set_bottom(p_value:Float):Float {
        g2d_bottom = p_value;
        setDirty();
        return g2d_bottom;
    }

    public var g2d_pivotX:Float = .5;
    #if swc @:extern #end
    @prototype public var pivotX(get, set):Float;
    #if swc @:getter(pivotX) #end
    inline private function get_pivotX():Float {
        return g2d_pivotX;
    }
    #if swc @:setter(pivotX) #end
    inline private function set_pivotX(p_value:Float):Float {
        g2d_pivotX = p_value;
        setDirty();
        return g2d_pivotX;
    }

    public var g2d_pivotY:Float = .5;
    #if swc @:extern #end
    @prototype public var pivotY(get, set):Float;
    #if swc @:getter(pivotY) #end
    inline private function get_pivotY():Float {
        return g2d_pivotY;
    }
    #if swc @:setter(pivotY) #end
    inline private function set_pivotY(p_value:Float):Float {
        g2d_pivotY = p_value;
        setDirty();
        return g2d_pivotY;
    }

    public var g2d_worldLeft:Float;
    public var g2d_worldTop:Float;
    public var g2d_worldRight:Float;
    public var g2d_worldBottom:Float;

    private var g2d_minWidth:Float = 0;
    private var g2d_prefferedWidth:Float = 0;
    private var g2d_variableWidth:Float = 0;
    private var g2d_finalWidth:Float = 0;

    private var g2d_minHeight:Float = 0;
    private var g2d_prefferedHeight:Float = 0;
    private var g2d_variableHeight:Float = 0;
    private var g2d_finalHeight:Float = 0;

    private var g2d_parent:GUIElement;

    private var g2d_numChildren:Int = 0;
    private var g2d_children:Array<GUIElement>;

    public function new(p_skin:GUISkin = null) {
        normalSkin = p_skin;
    }

    public function addChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent == this) return;
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        g2d_children.push(p_child);
        g2d_numChildren++;
        setDirty();
        p_child.g2d_parent = this;
    }

    public function invalidate():Void {
        calculateWidth();
        invalidateWidth();
        calculateHeight();
        invalidateHeight();
    }

    private function calculateWidth():Void {
        if (g2d_layout != null) {
            g2d_layout.calculateWidth(this);
        } else {
            g2d_prefferedWidth = g2d_minWidth = g2d_activeSkin != null ? g2d_activeSkin.getMinWidth() : 0;

            for (i in 0...g2d_numChildren) {
                g2d_children[i].calculateWidth();
            }
        }
    }

    private function calculateHeight():Void {
        if (g2d_layout != null) {
            g2d_layout.calculateHeight(this);
        } else {
            g2d_prefferedHeight = g2d_minHeight = g2d_activeSkin != null ? g2d_activeSkin.getMinHeight() : 0;

            for (i in 0...g2d_numChildren) {
                g2d_children[i].calculateHeight();
            }
        }
    }

    private function invalidateWidth():Void {
        if (g2d_parent != null) {
            if (g2d_parent.g2d_layout == null) {
                var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
                var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
                if (g2d_anchorLeft != g2d_anchorRight) {
                    g2d_worldLeft = worldAnchorLeft + g2d_left;
                    g2d_worldRight = worldAnchorRight - g2d_right;
                } else {
                    g2d_worldLeft = worldAnchorLeft + g2d_anchorX - g2d_prefferedWidth * g2d_pivotX;
                    g2d_worldRight = worldAnchorLeft + g2d_anchorX + g2d_prefferedWidth * (1 - g2d_pivotX);
                }
                g2d_finalWidth = g2d_worldRight - g2d_worldLeft;
            }

            if (g2d_layout != null) {
                g2d_layout.invalidateWidth(this);
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateWidth();
                }
            }
        } else {
            for (i in 0...g2d_numChildren) {
                g2d_children[i].invalidateWidth();
            }
        }
    }

    private function invalidateHeight():Void {
        if (g2d_parent != null) {
            if (g2d_parent.g2d_layout == null) {
                var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
                var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;
                if (g2d_anchorTop != g2d_anchorBottom) {
                    g2d_worldTop = worldAnchorTop + g2d_top;
                    g2d_worldBottom = worldAnchorBottom - g2d_bottom;
                } else {
                    g2d_worldTop = worldAnchorTop + g2d_anchorY - g2d_prefferedHeight * g2d_pivotY;
                    g2d_worldBottom = worldAnchorTop + g2d_anchorY + g2d_prefferedHeight * (1 - g2d_pivotY);
                }
                g2d_finalHeight = g2d_worldBottom - g2d_worldTop;
            }

            if (g2d_layout != null) {
                g2d_layout.invalidateHeight(this);
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateHeight();
                }
            }
        } else {
            for (i in 0...g2d_numChildren) {
                g2d_children[i].invalidateHeight();
            }
        }
    }

    public function render():Void {
        if (g2d_activeSkin != null) g2d_activeSkin.render(g2d_worldLeft, g2d_worldTop, g2d_worldRight, g2d_worldBottom);

        for (i in 0...g2d_numChildren) {
            g2d_children[i].render();
        }
    }

    public function getPrototype(p_xml:Xml = null):Xml {
        var xml:Xml = getPrototypeDefault();
        for (i in 0...g2d_numChildren) {
            xml.addChild(g2d_children[i].getPrototype());
        }
        return xml;
    }

    public function initPrototype(p_prototypeXml:Xml):Void {
        initPrototypeDefault(p_prototypeXml);

        var it:Iterator<Xml> = p_prototypeXml.elementsNamed("element");
        while (it.hasNext()) {
            var xml:Xml = it.next();
            var element:GUIElement = cast GPrototypeFactory.createPrototype(xml);
            addChild(element);
        }
    }
}
