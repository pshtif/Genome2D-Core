package com.genome2d.g3d2;

/**

 * @author Peter @sHTiF Stefcek
 */
class G3DBase
{
	private var g2d_id:String;
	inline public function getId():String {
		return g2d_id;
	}
	
	public function new(p_id:String) {
		g2d_id = p_id;
	}
	
}