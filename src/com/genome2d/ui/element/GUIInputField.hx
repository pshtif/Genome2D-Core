/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.element;
import com.genome2d.input.GFocusManager;
import com.genome2d.input.GKeyboardInput;
import com.genome2d.input.GKeyboardInputType;
import com.genome2d.ui.skin.GUIFontSkin;

class GUIInputField extends GUIElement
{
	public function new(p_skin:GUIFontSkin) {
		super(p_skin);
		
		cast (g2d_activeSkin,GUIFontSkin).textRenderer.enableCursor = true;
		
		Genome2D.getInstance().onKeyboardInput.add(keyboardInput_handler);
	}
	
	private function keyboardInput_handler(input:GKeyboardInput):Void {
		if (GFocusManager.hasFocus(this) && input.type == GKeyboardInputType.KEY_DOWN && g2d_activeSkin != null) {
			var skin:GUIFontSkin = cast g2d_activeSkin;
			switch (input.keyCode) {
				// ENTER
				case 1315251:
					var newValue:String = g2d_model.substring(0, skin.cursorStartIndex);
					newValue += String.fromCharCode(input.charCode);
					newValue += g2d_model.substring(skin.cursorEndIndex, g2d_model.length);
					setModel(newValue);
				// BACKSPACE
				case 8:
					if (skin.cursorStartIndex != skin.cursorEndIndex) {
						var newValue:String = g2d_model.substring(0, skin.cursorStartIndex);
						newValue += g2d_model.substring(skin.cursorEndIndex, g2d_model.length);
						setModel(newValue);
						skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex;
					} else {
						var newValue:String = g2d_model.substring(0, skin.cursorStartIndex-1);
						newValue += g2d_model.substring(skin.cursorEndIndex, g2d_model.length);
						setModel(newValue);
						skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex>0?skin.cursorStartIndex-1:0;
					}
				// DELETE
				case 46:
					if (skin.cursorStartIndex != skin.cursorEndIndex) {
						var newValue:String = g2d_model.substring(0, skin.cursorStartIndex);
						newValue += g2d_model.substring(skin.cursorEndIndex, g2d_model.length);
						setModel(newValue);
						skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex;
					} else {
						var newValue:String = g2d_model.substring(0, skin.cursorStartIndex);
						newValue += g2d_model.substring(skin.cursorEndIndex+1, g2d_model.length);
						setModel(newValue);
					}
				// RIGHT ARROW
				case 39:
					if (skin.cursorStartIndex == skin.cursorEndIndex) {
						skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex + 1;
					} else {
						skin.cursorStartIndex = skin.cursorEndIndex;
					}
				// LEFT ARROW
				case 37:
					if (skin.cursorStartIndex == skin.cursorEndIndex) {
						skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex - 1;
					} else {
						skin.cursorEndIndex = skin.cursorStartIndex;
					}
				case 16:
				case _:
					if (input.charCode != 0) {
						var newValue:String = g2d_model.substring(0, skin.cursorStartIndex);
						newValue += String.fromCharCode(input.charCode);
						newValue += g2d_model.substring(skin.cursorEndIndex, g2d_model.length);
						setModel(newValue);
						skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex + 1;
					}
			}
		}
	}	
}