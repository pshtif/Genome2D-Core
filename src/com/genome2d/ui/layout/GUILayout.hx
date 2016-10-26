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
import com.genome2d.proto.IGPrototypable;

@:access(com.genome2d.ui.element.GUIElement)
@prototypeName("layout")
class GUILayout implements IGPrototypable {
    @prototype public var type:GUILayoutType = GUILayoutType.HORIZONTAL;

	private function isCalculatingWidth():Bool {
		return true;
	}
	
    private function calculateWidth(p_element:GUIElement):Void {
    }

    private function invalidateWidth(p_element:GUIElement):Void {
    }

	private function isCalculatingHeight():Bool {
		return true;
	}
	
    private function calculateHeight(p_element:GUIElement):Void {
    }

    private function invalidateHeight(p_element:GUIElement):Void {
    }
	
	public function isHorizontalLayout():Bool {
		return type == GUILayoutType.HORIZONTAL;
	}
	
	public function isVerticalLayout():Bool {
		return type == GUILayoutType.VERTICAL;
	}
	
	public function toReference():String {
		return null;
	}
}
