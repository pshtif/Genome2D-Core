/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.layout;

import com.genome2d.ui.element.GUIElement;

@:access(com.genome2d.ui.element.GUIElement)
@prototypeName("vertical")
class GUIVerticalLayout extends GUILayout {

    @prototype 
	public var gap:Float = 0;

    @prototype
    public var useChildrenWidth:Bool = false;

    @prototype
    public var skipLastGap:Bool = false;
	
	public function new() {
		type = GUILayoutType.VERTICAL;
	}

    override private function calculateWidth(p_element:GUIElement):Void {
        p_element.g2d_preferredWidth = p_element.g2d_minWidth = 0;

        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.calculateWidth();

            p_element.g2d_minWidth = p_element.g2d_minWidth < child.g2d_minWidth ? child.g2d_minWidth : p_element.g2d_minWidth;
            if (useChildrenWidth == true) {
                p_element.g2d_preferredWidth = p_element.g2d_preferredWidth < child.g2d_preferredWidth ? child.g2d_preferredWidth : p_element.g2d_preferredWidth;
            }
        }
    }

    override private function invalidateWidth(p_element:GUIElement):Void {
        var rest:Float = p_element.g2d_finalWidth - p_element.g2d_minWidth;
        if (rest<0) rest = 0;
        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];

            child.g2d_worldLeft = p_element.g2d_worldLeft;
            child.g2d_worldRight = child.g2d_worldLeft + p_element.g2d_finalWidth;
            child.g2d_finalWidth = p_element.g2d_finalWidth;

            child.invalidateWidth();
        }
    }

    override private function calculateHeight(p_element:GUIElement):Void {
        p_element.g2d_preferredHeight = p_element.g2d_minHeight = 0;
        var layoutGap:Float = gap;

        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];
            child.calculateHeight();

            if (skipLastGap == true && i >= p_element.g2d_numChildren - 1) {
                layoutGap = 0;
            }

            p_element.g2d_minHeight += child.g2d_minHeight + layoutGap;
            p_element.g2d_preferredHeight += child.g2d_preferredHeight + layoutGap;
        }
    }

    override private function invalidateHeight(p_element:GUIElement):Void {
        var offsetY:Float = 0;
        var rest:Float = p_element.g2d_finalHeight - p_element.g2d_minHeight;
        if (rest<0) rest = 0;
        var layoutGap:Float = gap;

        for (i in 0...p_element.g2d_numChildren) {
            var child:GUIElement = p_element.g2d_children[i];

            child.g2d_worldTop = p_element.g2d_worldTop + offsetY;
			// Top priority rest space distribution
			var childDif:Float = (child.g2d_preferredHeight > child.g2d_minHeight)?child.g2d_preferredHeight - child.g2d_minHeight:0;
			childDif = rest < childDif?rest:childDif;
			rest -= childDif;
            child.g2d_worldBottom = child.g2d_worldTop + child.g2d_minHeight + childDif;
            child.g2d_finalHeight = child.g2d_worldBottom - child.g2d_worldTop;

            if (skipLastGap == true && i >= p_element.g2d_numChildren - 1) {
                layoutGap = 0;
            }
            offsetY += child.g2d_finalHeight + layoutGap;

            child.invalidateHeight();
        }
    }
}
