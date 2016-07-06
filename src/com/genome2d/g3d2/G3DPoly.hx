package com.genome2d.g3d2;
import com.genome2d.g3d2.G3DBase;
import com.genome2d.g3d2.G3DEdge;

/**
 * ...
 * @author ...
 */
class G3DPoly extends G3DBase
{
	private var g2d_edges:Array<G3DEdge>;

	public function new(p_id:String, p_edges:Array<G3DEdge>) {
		super(p_id);
		g2d_edges = p_edges;
	}
	
}