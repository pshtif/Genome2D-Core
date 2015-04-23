package com.genome2d.ui.layout;

import com.genome2d.ui.element.GUIElement;
import com.genome2d.proto.IGPrototypable;
@:access(com.genome2d.ui.element.GUIElement)
@prototypeName("layout")
class GUILayout implements IGPrototypable {
    @prototype public var type:Int = GUILayoutType.HORIZONTAL;

    private function calculateWidth(p_element:GUIElement):Void {
    }

    private function invalidateWidth(p_element:GUIElement):Void {
    }

    private function calculateHeight(p_element:GUIElement):Void {
    }

    private function invalidateHeight(p_element:GUIElement):Void {
    }
	
	public function toReference():String {
		return null;
	}
}
