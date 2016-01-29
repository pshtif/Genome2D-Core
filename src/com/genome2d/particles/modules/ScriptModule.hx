package com.genome2d.particles.modules;
import com.genome2d.particles.GParticleEmitter;
import com.genome2d.particles.GParticle;
import com.genome2d.particles.GParticleEmitterModule;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class ScriptModule extends GParticleEmitterModule
{
	private var g2d_script:String;
	private var g2d_parser:hscript.Parser;
	private var g2d_program:Dynamic;
	private var g2d_executeSpawn:Dynamic;
	private var g2d_executeUpdate:Dynamic;
	
	public function new(p_script:String) {
		super();
		
		g2d_script = p_script;
		if (g2d_script == null) {
			g2d_script = "
var count = 0;
var gravity = .1;
function spawn(p_emitter, p_particle) {
	count = (++count) % 25;
	p_particle.x += -10 + ((count % 5) % 10) * 6;
	p_particle.y += -10 + (Math.floor(count / 5) % 10) * 6;
	p_particle.vy += gravity * 10;
		
	p_particle.totalEnergy = 1000;

}

//function update(p_emitter, p_particle, p_deltaTime) {}
			";
		}
		g2d_parser = new hscript.Parser();
		
		setScript(g2d_script);
	}
	
	public function getScript():String {
		return g2d_script;
	}
	
	public function setScript(p_script:String):Void {
		g2d_script = p_script;
		
		var interp = new hscript.Interp();
		interp.variables.set("Math", Math);
		var compiled:Bool = true;
		try {
			g2d_program = g2d_parser.parseString(g2d_script);
			interp.execute(g2d_program);
		} catch (e:Dynamic) {
			trace(e);
			compiled = false;
		}
		
		if (compiled) {
			g2d_executeSpawn = interp.variables.get("spawn");
			g2d_executeUpdate = interp.variables.get("update"); 
			trace(g2d_executeUpdate);
			spawnModule = g2d_executeSpawn != null;
			updateModule = g2d_executeUpdate != null;
		}
	}
	
	override public function spawn(p_emitter:GParticleEmitter, p_particle:GParticle):Void {
		g2d_executeSpawn(p_emitter, p_particle);
	}
	
	override public function update(p_emitter:GParticleEmitter, p_particle:GParticle, p_deltaTime:Float):Void {
		g2d_executeUpdate(p_emitter, p_particle, p_deltaTime);
	}
	
}