package com.genome2d.g3d2;
import com.genome2d.g3d2.G3DBase;
import com.genome2d.g3d2.G3DVertex;

/**
 * ...
 * @author Peter @sHTiF Stefcek		
 */
class G3DEdge extends G3DBase
{
	private var g2d_vertex1:G3DVertex;
	private var g2d_vertex2:G3DVertex;

	public function new(p_id:String, p_vertex1:G3DVertex, p_vertex2:G3DVertex) {
		super(p_id);
		
		g2d_vertex1 = p_vertex1;
		g2d_vertex2 = p_vertex2;
	}
	
}