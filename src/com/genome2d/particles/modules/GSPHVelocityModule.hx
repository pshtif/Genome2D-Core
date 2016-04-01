package com.genome2d.particles.modules;
import com.genome2d.particles.GParticleEmitter;
import com.genome2d.particles.GParticle;
import com.genome2d.particles.GParticleEmitterModule;
import com.genome2d.particles.GParticleSystem;

/**
 * Update particle velocity based on SPH properties
 *
 * @author Peter @sHTiF Stefcek
 */
class GSPHVelocityModule extends GParticleEmitterModule
{
	public function new() {
		super();		
		
		updateModule = true;
	}
	
	override public function update(p_emitter:GParticleEmitter, p_particle:GParticle, p_deltaTime:Float):Void {
		if (p_particle.density > 0 && !p_particle.fixed && p_particle.group == null) {
			p_particle.velocityX += p_particle.fluidX / (p_particle.density * 0.9 + 0.1);
			p_particle.velocityY += p_particle.fluidY / (p_particle.density * 0.9 + 0.1);
		}
	}
	
}