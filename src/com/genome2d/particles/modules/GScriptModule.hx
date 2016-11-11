package com.genome2d.particles.modules;
import com.genome2d.scripts.GScript;
import com.genome2d.particles.GParticleEmitter;
import com.genome2d.particles.GParticle;
import com.genome2d.particles.GParticleSystem;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
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

	private var g2d_executeSpawn:Dynamic;
	private var g2d_executeUpdate:Dynamic;
	
	public function new() {
		super();
	}
	
	private function invalidate():Void {
		if (g2d_script != null) {
			g2d_executeSpawn = g2d_script.getVariable("spawn");
			g2d_executeUpdate = g2d_script.getVariable("update");
			spawnModule = g2d_executeSpawn != null;
			updateModule = g2d_executeUpdate != null;
		}
	}
	
	override public function spawn(p_emitter:GParticleEmitter, p_particle:GParticle):Void {
		if (g2d_executeSpawn != null) g2d_executeSpawn(p_emitter, p_particle);
	}
	
	override public function update(p_emitter:GParticleEmitter, p_particle:GParticle, p_deltaTime:Float):Void {
		if (g2d_executeUpdate != null) g2d_executeUpdate(p_emitter, p_particle, p_deltaTime);
	}
	
}