/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */

package com.genome2d.components.renderable.particles;

import com.genome2d.components.GComponent;
import com.genome2d.components.renderable.IGRenderable;
import com.genome2d.context.GCamera;
import com.genome2d.geom.GRectangle;
import com.genome2d.input.GMouseInput;
import com.genome2d.particles.GParticleEmitter;
import com.genome2d.particles.GParticleSystem;

/**
 * Component encapsulating the GParticleSystem class
 * 
 * @author Peter @sHTiF Stefcek
 */
class GParticleSystemComponent extends GComponent implements IGRenderable
{
	@prototype
	public var particleSystem:GParticleSystem;
	
	override public function init():Void {
		particleSystem = new GParticleSystem();
		
		node.core.onUpdate.add(update);
	}
	
	private function update(p_deltaTime:Float):Void {
		particleSystem.x = node.x;
		particleSystem.y = node.y;
		
		particleSystem.update(p_deltaTime);
	}

	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		particleSystem.x = node.x;
		particleSystem.y = node.y;
		
		particleSystem.render(node.core.getContext());
	}

    public function getBounds(p_target:GRectangle = null):GRectangle {
		return null;
	}

	public function captureMouseInput(p_input:GMouseInput):Void {
		
	}
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
		return false;
	}
	
	override public function dispose():Void {
		node.core.onUpdate.remove(update);
	}
	
}