package com.genome2d.g3d.importers;

import com.genome2d.g3d.G3DScene;
import haxe.io.Bytes;

/**
 * @author Peter @sHTiF Stefcek
 */
class G3DAbstractImporter
{

	public function new() 
	{
		
	}
	
	@:access(com.genome2d.g3d.G3DScene)
	public function importScene(p_data:Bytes):G3DScene {
		return null;
	}

	public function exportScene(p_scene:G3DScene, p_data:Bytes):Void {
		
	}
	
}