package com.genome2d.ui.idea;

@:access(com.genome2d.ui.idea.GUIElement)
class GUILayout {
    public var g2d_element:GUIElement;

    public var gap:Float = 10;

    public function new() {
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
        trace(p_element.name);
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.g2d_worldLeft = p_element.g2d_worldLeft + offsetX;
            child.g2d_worldRight = child.g2d_worldLeft + (p_element.g2d_width-p_element.g2d_numChildren*gap)/p_element.g2d_numChildren;
            trace(child.name, child.g2d_worldLeft,child.g2d_worldRight,offsetX);
            offsetX += child.g2d_width+gap;

            child.invalidateWidth();
        }
    }

    private function calculateHeight(p_element:GUIElement):Void {
        p_element.g2d_prefferedHeight = p_element.g2d_minHeight = p_element.g2d_activeSkin != null ? p_element.g2d_activeSkin.getMinHeight() : 0;
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
