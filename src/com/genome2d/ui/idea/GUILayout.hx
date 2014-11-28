package com.genome2d.ui.idea;

@:access(com.genome2d.ui.idea.GUIElement)
class GUILayout {
    public var g2d_element:GUIElement;

    private var g2d_minWidth:Float;

    private var g2d_offsetX:Float;

    public function new() {
    }

    private function calculateWidth(p_element:GUIElement):Void {
        p_element.g2d_minWidth = 0;
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.calculateWidth();
            p_element.g2d_minWidth += child.g2d_minWidth;
            p_element.g2d_width += child.g2d_width;
        }
    }

    private function invalidateWidth(p_element:GUIElement):Void {
        var offsetX:Float = 0;
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.g2d_worldLeft = p_element.g2d_worldLeft + g2d_offsetX;
            child.g2d_worldRight = child.g2d_worldLeft + p_element.g2d_width/p_element.g2d_numChildren;
            g2d_offsetX += p_element.g2d_width;
        }
    }

    private function calculateHeight(p_element:GUIElement):Void {
        /*
        var minHeight:Float = 0;
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.calculateHeight();
            minHeight += child.g2d_minHeight;
        }
        /**/
    }

    private function invalidateHeight(p_element:GUIElement):Void {

    }
}
