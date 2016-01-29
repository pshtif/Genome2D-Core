/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;

import com.genome2d.context.IGContext;
import com.genome2d.geom.GRectangle;

class GParticleSystem
{
    public var timeDilation:Float = 1;

	private var g2d_emitters:Array<GParticleEmitter>;
	private var g2d_emitterCount:Int = 0;
	
    public function new() {
        g2d_emitters = new Array<GParticleEmitter>();
    }
	
	public function addEmitter(p_emitter:GParticleEmitter):Void {
		p_emitter.g2d_particleSystem = this;
		g2d_emitterCount = g2d_emitters.push(p_emitter);
	}
	
	public function removeEmitter(p_emitter:GParticleEmitter):Void {
		if (g2d_emitters.remove(p_emitter)) {
			p_emitter.g2d_particleSystem = null;
			g2d_emitterCount--;
		}
	}
	
	public function getEmitter(p_emitterIndex:Int):GParticleEmitter {
		return (p_emitterIndex < g2d_emitterCount) ? g2d_emitters[p_emitterIndex] : null;
	}

    public function update(p_deltaTime:Float):Void {
        p_deltaTime *= timeDilation;
        
		for (emitter in g2d_emitters) {
			emitter.update(p_deltaTime);
		}
    }
	
	public function render(p_context:IGContext, p_x:Float, p_y:Float, p_rotation:Float, p_scaleX:Float, p_scaleY:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Void {
		for (emitter in g2d_emitters) {
			emitter.render(p_context, p_x, p_y, p_rotation, p_scaleX, p_scaleY, p_red, p_green, p_blue, p_alpha);
		}
	}
    
    public function dispose():Void {
    }
}