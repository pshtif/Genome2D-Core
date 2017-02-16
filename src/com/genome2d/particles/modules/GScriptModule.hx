package com.genome2d.particles.modules;

import com.genome2d.scripts.GScript;
import com.genome2d.particles.GParticleEmitter;
import com.genome2d.particles.GParticle;

class GScriptModule extends GParticleEmitterModule
{
	private var g2d_script:GScript = null;
	@prototype("getReference")
	public var script(get,set):GScript;
	#if swc @:getter(script) #end
	inline private function get_script():GScript {
		return g2d_script;
	}
		#if swc @:setter(script) #end
	inline private function set_script(p_value:GScript):GScript {
		if (g2d_script != null) g2d_script.onInvalidated.remove(invalidate);
		g2d_script = p_value;
		g2d_script.onInvalidated.add(invalidate);
		invalidate();
		return g2d_script;
	}

	private var g2d_executeSpawnParticle:Dynamic;
	private var g2d_executeUpdateParticle:Dynamic;
	private var g2d_executeUpdateEmitter:Dynamic;
	private var g2d_executeAddedToEmitter:Dynamic;
	private var g2d_executeRemovedFromEmitter:Dynamic;
	
	public function new() {
		super();
	}
	
	private function invalidate():Void {
		if (g2d_script != null) {
			g2d_executeSpawnParticle = g2d_script.getVariable("spawnParticle");
			g2d_executeUpdateParticle = g2d_script.getVariable("updateParticle");
			g2d_executeUpdateEmitter = g2d_script.getVariable("updateEmitter");
			g2d_executeAddedToEmitter = g2d_script.getVariable("addedToEmitter");
			g2d_executeRemovedFromEmitter = g2d_script.getVariable("removedFromEmitter");

			spawnParticleModule = g2d_executeSpawnParticle != null;
			updateParticleModule = g2d_executeUpdateParticle != null;
			updateEmitterModule = g2d_executeUpdateEmitter != null;
		}
	}
	
	override public function spawnParticle(p_emitter:GParticleEmitter, p_particle:GParticle):Void {
		if (g2d_executeSpawnParticle != null) g2d_executeSpawnParticle(p_emitter, p_particle);
	}
	
	override public function updateParticle(p_emitter:GParticleEmitter, p_particle:GParticle, p_deltaTime:Float):Void {
		if (g2d_executeUpdateParticle != null) g2d_executeUpdateParticle(p_emitter, p_particle, p_deltaTime);
	}

	override public function updateEmitter(p_emitter:GParticleEmitter, p_deltaTime:Float):Void {
		if (g2d_executeUpdateEmitter != null) g2d_executeUpdateEmitter(p_emitter, p_deltaTime);
	}

	override public function addedToEmitter(p_emitter:GParticleEmitter):Void {
		if (g2d_executeAddedToEmitter != null) g2d_executeAddedToEmitter(p_emitter);
	}

	override public function removedFromEmitter(p_emitter:GParticleEmitter):Void {
		if (g2d_executeRemovedFromEmitter != null) g2d_executeRemovedFromEmitter(p_emitter);
	}
}