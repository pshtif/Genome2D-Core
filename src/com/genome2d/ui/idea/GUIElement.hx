package com.genome2d.ui.idea;

import com.genome2d.ui.utils.GUILayoutType;
import com.genome2d.ui.skin.GUISkin;

class GUIElement {
    public var name:String;
    public var mouseEnabled:Bool;

    public var g2d_layout:GUILayout;

    private var g2d_activeSkin:GUISkin;

    private var g2d_dirty:Bool;
    private function setDirty():Void {
        g2d_dirty = true;
        if (g2d_parent != null) g2d_parent.setDirty();
    }

    public var g2d_anchorX:Float;
    public var g2d_anchorY:Float;

    public var g2d_anchorLeft:Float;
    public var g2d_anchorTop:Float;
    public var g2d_anchorRight:Float;
    public var g2d_anchorBottom:Float;

    public var g2d_left:Float;
    public var g2d_top:Float;
    public var g2d_right:Float;
    public var g2d_bottom:Float;

    public var g2d_pivotX:Float;
    public var g2d_pivotY:Float;

    public var g2d_worldLeft:Float;
    public var g2d_worldTop:Float;
    public var g2d_worldRight:Float;
    public var g2d_worldBottom:Float;

    private var g2d_minWidth:Float;
    private var g2d_width:Float;
    private var g2d_variableWidth:Float;

    private var g2d_minHeight:Float;
    private var g2d_height:Float;
    private var g2d_variableHeight:Float;

    private var g2d_parent:GUIElement;

    private var g2d_numChildren:Int;
    private var g2d_children:Array<GUIElement>;

    public function new(p_skin:GUISkin = null) {
        initDefault();
        g2d_activeSkin = p_skin;
        if (g2d_activeSkin != null) {
            g2d_width = g2d_minWidth = p_skin.getMinWidth();
            g2d_height = g2d_minHeight = p_skin.getMinHeight();
        }
    }

    private function initDefault():Void {
        g2d_numChildren = 0;
        g2d_dirty = true;
        g2d_anchorX = 0;
        g2d_anchorY = 0;

        g2d_anchorLeft = .5;
        g2d_anchorTop = .5;
        g2d_anchorRight = .5;
        g2d_anchorBottom = .5;

        g2d_left = 0;
        g2d_top = 0;
        g2d_right = 0;
        g2d_bottom = 0;

        g2d_pivotX = .5;
        g2d_pivotY = .5;
    }

    public function addChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent == this) return;
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        g2d_children.push(p_child);
        g2d_numChildren++;
        p_child.g2d_parent = this;
    }

    private function invalidate():void {
        calculateWidth();
        invalidateWidth();

        calculateHeight();
        invalidateHeight();
    }

    private function calculateWidth():Void {
        if (g2d_layout != null) {
            g2d_layout.calculateWidth(this);
        }
    }

    private function invalidateWidth():Void {
        if (g2d_parent.layout != null) {
            g2d_parent.layout.invalidateWidth(this);
        } else {
            var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + (g2d_parent.g2d_worldRight - g2d_parent.g2d_worldLeft) * g2d_anchorLeft;
            var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + (g2d_parent.g2d_worldRight - g2d_parent.g2d_worldLeft) * g2d_anchorRight;
            if (g2d_anchorLeft != g2d_anchorRight) {
                g2d_worldLeft = worldAnchorLeft + g2d_left;
                g2d_worldRight = worldAnchorRight - g2d_right;
            } else {
                g2d_worldLeft = worldAnchorLeft + g2d_anchorX - g2d_width * g2d_pivotX;
                g2d_worldRight = worldAnchorLeft + g2d_anchorX + g2d_width * (1 - g2d_pivotX);
            }

            for (i in 0...g2d_numChildren) {
                g2d_children[i].invalidateWidth();
            }
        }
    }

    private function calculateHeight():Void {
        if (false) {
            g2d_parent.layout.calculateHeight(this);
        }
    }

    private function invalidateHeight():Void {
        if (false) {
            g2d_parent.layout.invalidateHeight(this);
        } else {
            var worldAnchorTop:Float = g2d_parent.g2d_worldTop + (g2d_parent.g2d_worldBottom - g2d_parent.g2d_worldTop) * g2d_anchorTop;
            var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + (g2d_parent.g2d_worldBottom - g2d_parent.g2d_worldTop) * g2d_anchorBottom;
            if (g2d_anchorTop != g2d_anchorBottom) {
                g2d_worldTop = worldAnchorTop + g2d_top;
                g2d_worldBottom = worldAnchorBottom - g2d_bottom;
            } else {
                g2d_worldTop = worldAnchorTop + g2d_anchorY - g2d_height * g2d_pivotY;
                g2d_worldBottom = worldAnchorTop + g2d_anchorY + g2d_height * (1 - g2d_pivotY);
            }

            for (i in 0...g2d_numChildren) {
                g2d_children[i].calculateHeight();
            }
        }
    }

    public function render():Void {
        if (g2d_dirty) invalidate();
        if (g2d_activeSkin != null) g2d_activeSkin.render(g2d_worldLeft, g2d_worldTop, g2d_worldRight, g2d_worldBottom);

        for (i in 0...g2d_numChildren) {
            g2d_children[i].render();
        }
    }
}
