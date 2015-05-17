package com.genome2d.ui.element;
import com.genome2d.focus.GFocusManager;
import com.genome2d.input.GKeyboardInput;
import com.genome2d.input.GKeyboardInputType;
import com.genome2d.ui.skin.GUIFontSkin;

/**
 * ...
 * @author 
 */
class GUIInputField extends GUIElement
{
	public function new(p_skin:GUIFontSkin) {
		super(p_skin);
		
		cast (g2d_activeSkin,GUIFontSkin).textRenderer.enableCursor = true;
		
		Genome2D.getInstance().onKeyboardInput.add(keyboardInput_handler);
	}
	
	private function keyboardInput_handler(input:GKeyboardInput):Void {
		if (GFocusManager.activeFocus == this && input.type == GKeyboardInputType.KEY_DOWN && g2d_activeSkin != null) {
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
					if (skin.cursorStartIndex == skin.cursorEndIndex)  skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex + 1;
				// LEFT ARROW
				case 37:
					if (skin.cursorStartIndex == skin.cursorEndIndex)  skin.cursorStartIndex = skin.cursorEndIndex = skin.cursorStartIndex - 1;
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