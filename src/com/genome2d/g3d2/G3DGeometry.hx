package com.genome2d.g3d2;
import src.com.genome2d.g3d2.G3DBase;

/**
 * @author Peter @sHTiF Stefcek
 */
class G3DGeometry extends G3DBase
{
	private var g2d_polys:Array<G3DPoly>;
	
	public function new(p_id:String, p_polys:Array<G3DPoly>) {
		super(p_id);
		g2d_polys = p_polys;
	}
	
}