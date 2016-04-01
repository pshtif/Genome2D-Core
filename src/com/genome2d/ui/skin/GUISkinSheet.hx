package com.genome2d.ui.skin;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;

/**
 * @author Peter @sHTiF Stefcek
 */
@prototypeName("skinSheet")
@prototypeDefaultChildGroup("*")
class GUISkinSheet implements IGPrototypable
{
	private var g2d_skins:Array<GUISkin>;

	public function new() {
	}

	public function bindPrototype(p_prototype:GPrototype):Void {
		bindPrototypeDefault(p_prototype);
		var skinPrototypes:Array<GPrototype> = p_prototype.getGroup("*");
		
		for (skinPrototype in skinPrototypes) {
			var skin:GUISkin = cast GPrototypeFactory.createPrototype(skinPrototype);
		}
	}
}