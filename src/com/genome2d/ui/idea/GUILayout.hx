package com.genome2d.ui.idea;

import com.genome2d.proto.IGPrototypable;
@:access(com.genome2d.ui.idea.GUIElement)
class GUILayout implements IGPrototypable {

    @prototype public var gap:Float = 10;

    private function init():Void {

    }

    private function calculateWidth(p_element:GUIElement):Void {
        p_element.g2d_prefferedWidth = p_element.g2d_minWidth = 0;
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.calculateWidth();
            p_element.g2d_minWidth += child.g2d_minWidth+gap;
            p_element.g2d_prefferedWidth += child.g2d_prefferedWidth+gap;
        }
    }

    private function invalidateWidth(p_element:GUIElement):Void {
        var offsetX:Float = 0;
        var rest:Float = p_element.g2d_finalWidth - p_element.g2d_minWidth;
        if (rest<0) rest = 0;
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.g2d_worldLeft = p_element.g2d_worldLeft + offsetX;
            child.g2d_worldRight = child.g2d_worldLeft + child.g2d_minWidth + rest/p_element.g2d_numChildren;
            child.g2d_finalWidth = child.g2d_worldRight - child.g2d_worldLeft;
            offsetX += child.g2d_finalWidth + gap;

            child.invalidateWidth();
        }
    }

    private function calculateHeight(p_element:GUIElement):Void {
        p_element.g2d_prefferedHeight = p_element.g2d_minHeight = 0;

        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.calculateHeight();
            p_element.g2d_minHeight = p_element.g2d_minHeight < child.g2d_minHeight ? child.g2d_minHeight : p_element.g2d_minHeight;
            p_element.g2d_prefferedHeight = p_element.g2d_prefferedHeight < child.g2d_prefferedHeight ? child.g2d_prefferedHeight : p_element.g2d_prefferedHeight;
        }
    }

    private function invalidateHeight(p_element:GUIElement):Void {
        var rest:Float = p_element.g2d_finalHeight - p_element.g2d_minHeight;

        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.g2d_worldTop = p_element.g2d_worldTop;
            child.g2d_worldBottom = child.g2d_worldTop + p_element.g2d_finalHeight;
            child.g2d_finalWidth = p_element.g2d_finalHeight;

            child.invalidateHeight();
        }
    }
}
