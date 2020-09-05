package com.genome2d.particles.modules;

import com.genome2d.macros.MGDebug;
import com.genome2d.particles.GParticleEmitter;
import com.genome2d.particles.GParticle;

/**
 * Update particle velocity based on SPH properties
 *
 * @author Peter @sHTiF Stefcek
 */
class GSPHVelocityModule extends GParticleEmitterModule
{
	public function new() {
		super();		
		
		updateParticleModule = true;
	}
	
	override public function updateParticle(p_emitter:GParticleEmitter, p_particle:GParticle, p_deltaTime:Float):Void {
		if (p_particle.density > 0 && !p_particle.fixed && p_particle.group == null) {
			p_particle.velocityX += p_particle.fluidX / (p_particle.density * 0.9 + 0.1);
			p_particle.velocityY += p_particle.fluidY / (p_particle.density * 0.9 + 0.1);
		}

		/*
		p_particle.velocityY += .2;
		if (!p_particle.fixed) {
			p_particle.x += p_particle.velocityX * p_deltaTime/30;
			p_particle.y += p_particle.velocityY * p_deltaTime / 30;
		}
		p_particle.accumulatedTime += p_deltaTime;

		if (p_particle.accumulatedTime > 5000) p_particle.die = true;
		/*
		*/
	}
	
}