#if flash
package com.genome2d.components.renderable.flash;

import flash.text.TextField;
import flash.text.TextFormat;
class GFlashText extends GFlashObject {
    private var g2d_textFormat:TextFormat;
    private var g2d_textField:TextField;

    #if swc @:extern #end
    public var textField(get,never):TextField;
    #if swc @:getter(textField) #end
    public function get_textField():TextField {
        return g2d_textField;
    }

    override public function init():Void {
        updateFrameRate = 1;

        nativeObject = g2d_textField = new TextField();
		
		super.init();
    }
}
#end