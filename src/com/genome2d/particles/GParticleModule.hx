package com.genome2d.particles;

/**
 * ...
 * @author ...
 */
class GParticleModule
{
	public var spawnModule:Bool = false;
	public var updateModule:Bool = false;
	public var enabled:Bool = true;
	
	public function new() {}
	
	public function spawn(p_emitter:GEmitter, p_particle:GNewParticle):Void {}
	
	public function update(p_emitter:GEmitter, p_particle:GNewParticle, p_deltaTime:Float):Void {}
}