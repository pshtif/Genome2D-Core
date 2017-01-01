/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles.modules;
import com.genome2d.proto.IGPrototypable;

/**
 * Particle emitter module abstract
 */
class GParticleEmitterModule implements IGPrototypable
{
	@prototype
	public var spawnParticleModule:Bool = false;

	@prototype
	public var updateParticleModule:Bool = false;

	@prototype
	public var updateEmitterModule:Bool = false;

	@prototype
	public var enabled:Bool = true;
	
	public function new() {}
	
	public function spawnParticle(p_emitter:GParticleEmitter, p_particle:GParticle):Void {}
	
	public function updateParticle(p_emitter:GParticleEmitter, p_particle:GParticle, p_deltaTime:Float):Void {}

	public function updateEmitter(p_emitter:GParticleEmitter, p_deltaTime:Float):Void {}

	public function addedToEmitter(p_emitter:GParticleEmitter):Void {}

	public function removedFromEmitter(p_emitter:GParticleEmitter):Void {}
}