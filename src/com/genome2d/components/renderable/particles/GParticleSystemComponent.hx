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
	private var g2d_particleSystem:GParticleSystem;
	public function getParticleSystem():GParticleSystem {
		return g2d_particleSystem;
	}
	
	public function addEmitter(p_emitter:GParticleEmitter):Void {
		g2d_particleSystem.addEmitter(p_emitter);
	}
	
	public function getEmitter(p_index:Int):GParticleEmitter {
		return g2d_particleSystem.getEmitter(p_index);
	}
	
	override public function init():Void {
		g2d_particleSystem = new GParticleSystem();
		
		node.core.onUpdate.add(update);
	}
	
	private function update(p_deltaTime:Float):Void {
		g2d_particleSystem.update(p_deltaTime);
	}

	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
		g2d_particleSystem.x = node.x;
		g2d_particleSystem.y = node.y;
		
		g2d_particleSystem.render(node.core.getContext());
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