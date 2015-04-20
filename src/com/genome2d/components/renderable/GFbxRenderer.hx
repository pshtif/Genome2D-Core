package com.genome2d.components.renderable;
import com.genome2d.input.GMouseInput;
import com.genome2d.geom.GRectangle;
import com.genome2d.components.GComponent;
import com.genome2d.context.GCamera;

class GFbxRenderer extends GComponent implements IRenderable
{

	override public function init():Void {
		
	}
	
	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		
	}

	public function getBounds(p_target:GRectangle = null):GRectangle {
		return null;		
	}
	
	public function captureMouseInput(p_input:GMouseInput):Void {
		
	}
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
		return false;
	}
	
}