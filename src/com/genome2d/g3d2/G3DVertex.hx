package com.genome2d.g3d2;

/**
 * @author Peter @sHTiF Stefcek
 */
class G3DVertex extends G3DBase 
{	
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public function new(p_id:String, p_x:Float, p_y:Float, p_z:Float) {
		super(p_id);
		
		p_x = p_x;
		p_y = p_y;
		p_z = p_z;
	}
	
}