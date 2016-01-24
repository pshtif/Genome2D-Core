package com.genome2d.particles;

import com.genome2d.context.GBlendMode;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GCurve;
import com.genome2d.textures.GTexture;
import flash.Vector;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GEmitter
{
	public var useWorldSpace:Bool = true;
	
	public var texture:GTexture;
	public var blendMode:Int;
	
	public var x:Float = 0;
	public var y:Float = 0;
	
	public var emit:Bool = true;	
	
	public var duration:Float = 0;
	public var durationVariance:Float = 0;
	private var g2d_currentDuration:Float = -1;
	
	public var loop:Bool = false;
	
	public var delay:Float = 0;
	public var delayVariance:Float = 0;
	
	public var rate:GCurve;
	public var burstDistribution:Vector<Float>;
	
	private var g2d_accumulatedTime:Float = 0;
    private var g2d_accumulatedSecond:Float = 0;
    private var g2d_accumulatedEmission:Float = 0;
	
	private var g2d_firstParticle:GNewParticle;
    private var g2d_lastParticle:GNewParticle;
	
	private var g2d_particlePool:GNewParticlePool;
	
	@:allow(com.genome2d.particles.GParticleSystem)
	private var g2d_particleSystem:GParticleSystem;
	inline public function getParticleSystem():GParticleSystem {
		return g2d_particleSystem;
	}
	
	private var g2d_modules:Array<GParticleModule>;
	private var g2d_moduleCount:Int = 0;
	
	public function new(p_particlePool:GNewParticlePool = null) {
		g2d_particlePool = (p_particlePool == null) ? GNewParticlePool.g2d_defaultPool : p_particlePool;
		g2d_modules = new Array<GParticleModule>();
	}	
	
	public function addModule(p_module:GParticleModule):Void {
		g2d_moduleCount = g2d_modules.push(p_module);
	}
	
	public function removeModule(p_module:GParticleModule):Void {
		if (g2d_modules.remove(p_module)) g2d_moduleCount--;
	}
	
	public function update(p_deltaTime:Float):Void {
		g2d_doEmission(p_deltaTime);

		var particle:GNewParticle = g2d_firstParticle;
		
        while (particle != null) {
			var next:GNewParticle = particle.g2d_next;
			if (particle.implementUpdate) particle.g2d_update(this, p_deltaTime);
			for (module in g2d_modules) {
				if (module.updateModule) module.update(this, particle, p_deltaTime);
			}
			particle = next;
		}
		
		var particle:GNewParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GNewParticle = particle.g2d_next;
            if (particle.die) disposeParticle(particle);
            particle = next;
        }
	}
	
	inline private function g2d_doEmission(p_deltaTime:Float):Void {
		if (emit && rate != null && p_deltaTime > 0) {
			// If the current duration isn't calculated do it
			if (g2d_currentDuration == -1) g2d_currentDuration = duration + Math.random() * durationVariance;
			// Accumulate time
			var dt:Float = p_deltaTime * .001;
			g2d_accumulatedTime += dt;
			
			// If we passed duration and not looping stop the emitter
			if (g2d_accumulatedTime > g2d_currentDuration && !loop) emit = false;
			
			// If we passed current duration substract it
			if (g2d_accumulatedTime > g2d_currentDuration) {
				//g2d_currentDuration = duration + Math.random() * durationVariance;
				g2d_accumulatedTime-=g2d_currentDuration;
			}
			// If we are within current duration
			if (g2d_accumulatedTime < g2d_currentDuration) {
				// Calculate current rate and emit particles
				var currentRate:Float = rate.calculate(g2d_accumulatedTime / g2d_currentDuration);
				g2d_accumulatedEmission += currentRate * dt;
				// Create emitted particles
				while (g2d_accumulatedEmission >= 1) {
					spawnParticle();
					g2d_accumulatedEmission--;
				}
			}
        }
	}
	
	public function render(p_context:IGContext, p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Void {
        // TODO add matrix transformations
        var particle:GNewParticle = g2d_firstParticle;
		var tx:Float = (useWorldSpace) ? 0 : p_x + (x * p_scaleX);
		var ty:Float = (useWorldSpace) ? 0 : p_y + (y * p_scaleY);
        while (particle!=null) {
            var next:GNewParticle = particle.g2d_next;
            if (particle.implementRender) {
                particle.g2d_render(p_context, this, tx, ty, p_scaleX, p_scaleY, p_red, p_green, p_blue, p_alpha);
            } else {
                p_context.draw(particle.texture, tx + particle.x * p_scaleX, ty + particle.y * p_scaleY, p_scaleX + particle.scaleX, particle.scaleY * p_scaleY, particle.rotation, p_red * particle.red, p_green * particle.green, p_blue * particle.blue, p_alpha * particle.alpha, blendMode);
            }

            particle = next;
        }
    }
	
	private function spawnParticle():Void {
        var particle:GNewParticle = g2d_particlePool.g2d_get();
        if (g2d_lastParticle != null) {
            particle.g2d_previous = g2d_lastParticle;
            g2d_lastParticle.g2d_next = particle;
            g2d_lastParticle = particle;
        } else {
            g2d_firstParticle = particle;
            g2d_lastParticle = particle;
        }

        particle.g2d_spawn(this);
		
		for (module in g2d_modules) {
			if (module.spawnModule) module.spawn(this, particle);
		}
    }

    public function disposeParticle(p_particle:GNewParticle):Void {
        if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
        if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
        p_particle.g2d_dispose();
    }
}