package com.genome2d.particles.modules;
import com.genome2d.particles.GParticleModule;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class TestModule extends GParticleModule
{
	private var g2d_max:Float = 0;
	
	public function new(p_max:Float) {
		super();
		
		g2d_max = p_max;
		spawnModule = true;
		updateModule = true;
	}
	
	override public function spawn(p_emitter:GEmitter, p_particle:GNewParticle):Void {
		p_particle.totalEnergy = 1000;
		p_particle.x = p_emitter.x;
		p_particle.y = p_emitter.y;
		
		p_particle.velocityX = Math.random() * g2d_max*2 - g2d_max;
		p_particle.velocityY = Math.random() * g2d_max*2 - g2d_max;
	}
	
	override public function update(p_emitter:GEmitter, p_particle:GNewParticle, p_deltaTime:Float):Void {
		p_particle.x += p_particle.velocityX * p_deltaTime / 10;
		p_particle.y += p_particle.velocityY * p_deltaTime / 10;
		
		p_particle.totalEnergy -= p_deltaTime;
		p_particle.alpha = p_particle.totalEnergy / 1000;
		if (p_particle.totalEnergy < 0) p_particle.die = true;
	}
	
}