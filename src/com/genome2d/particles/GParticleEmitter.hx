/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;

import com.genome2d.context.GBlendMode;
import com.genome2d.context.IGContext;
import com.genome2d.context.stats.GStats;
import com.genome2d.geom.GCurve;
import com.genome2d.textures.GTexture;

/**
 *	Particle emitter
 */
class GParticleEmitter
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
	public var burstDistribution:Array<Float>;
	
	private var g2d_accumulatedTime:Float = 0;
    private var g2d_accumulatedSecond:Float = 0;
    private var g2d_accumulatedEmission:Float = 0;
	
	private var g2d_firstParticle:GParticle;
    private var g2d_lastParticle:GParticle;
	
	private var g2d_particlePool:GParticlePool;
	
	@:allow(com.genome2d.particles.GParticleSystem)
	private var g2d_particleSystem:GParticleSystem;
	inline public function getParticleSystem():GParticleSystem {
		return g2d_particleSystem;
	}
	
	private var g2d_modules:Array<GParticleEmitterModule>;
	private var g2d_moduleCount:Int = 0;
	
	public function new(p_particlePool:GParticlePool = null) {
		g2d_particlePool = (p_particlePool == null) ? GParticlePool.g2d_defaultPool : p_particlePool;
		g2d_modules = new Array<GParticleEmitterModule>();
	}	
	
	public function addModule(p_module:GParticleEmitterModule):Void {
		g2d_moduleCount = g2d_modules.push(p_module);
	}
	
	public function removeModule(p_module:GParticleEmitterModule):Void {
		if (g2d_modules.remove(p_module)) g2d_moduleCount--;
	}
	
	public function update(p_deltaTime:Float):Void {
		// If the current duration isn't calculated do it
		if (g2d_currentDuration == -1) g2d_currentDuration = duration + Math.random() * durationVariance;
		// Accumulate time
		g2d_accumulatedTime += p_deltaTime * .001;
		// If we passed current duration substract it
		if (g2d_accumulatedTime > g2d_currentDuration && loop) {
			//g2d_currentDuration = duration + Math.random() * durationVariance;
			g2d_accumulatedTime-=g2d_currentDuration;
		}
		
		g2d_doEmission(p_deltaTime);

		var updateModules:Array<GParticleEmitterModule> = new Array<GParticleEmitterModule>();
		for (module in g2d_modules) {
			if (module.updateModule) updateModules.push(module);
		}
		
		var particle:GParticle = g2d_firstParticle;
		if (particle != null && (particle.implementUpdate || updateModules.length>0)) {
			while (particle != null) {
				var next:GParticle = particle.g2d_next;
				if (particle.implementUpdate) particle.g2d_update(this, p_deltaTime);
				for (module in updateModules) {
					if (module.updateModule) module.update(this, particle, p_deltaTime);
				}
				particle = next;
			}
		}
		
		var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;
            if (particle.die) disposeParticle(particle);
            particle = next;
        }
	}
	
	inline private function g2d_doEmission(p_deltaTime:Float):Void {
		if (emit) {
			// If we passed duration and not looping stop the emitter
			if (g2d_accumulatedTime > g2d_currentDuration) {
				emit = false;
			// If we are within current duration
			} else {
				if (rate != null) {
					// Calculate current rate and emit particles
					var currentRate:Float = rate.calculate(g2d_accumulatedTime / g2d_currentDuration);
					g2d_accumulatedEmission += currentRate * p_deltaTime * .001;
				}
				
				if (burstDistribution != null) {
					for (i in 0...burstDistribution.length >> 1) {
						var time:Float = burstDistribution[2*i];
						if (time > g2d_accumulatedTime-p_deltaTime * .001 && time < g2d_accumulatedTime) g2d_accumulatedEmission += burstDistribution[2 * i + 1];
					}
				}
			}
        }

		// Create emitted particles
		while (g2d_accumulatedEmission >= 1) {
			spawnParticle();
			g2d_accumulatedEmission--;
		}
	}
	
	public function render(p_context:IGContext, p_x:Float, p_y:Float, p_rotation:Float, p_scaleX:Float, p_scaleY:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Void {
        // TODO add matrix transformations
        var particle:GParticle = g2d_firstParticle;
		var tx:Float = (useWorldSpace) ? 0 : p_x + (x * p_scaleX);
		var ty:Float = (useWorldSpace) ? 0 : p_y + (y * p_scaleY);
		var sx:Float = (useWorldSpace) ? 1 : p_scaleX;
		var sy:Float = (useWorldSpace) ? 1 : p_scaleY;

        while (particle!=null) {
            var next:GParticle = particle.g2d_next;
            if (particle.implementRender) {
                particle.g2d_render(p_context, this, tx, ty, p_rotation, sx, sy, p_red, p_green, p_blue, p_alpha);
            } else {
                p_context.draw(particle.texture, tx + particle.x * sx, ty + particle.y * sy, sx * particle.scaleX, sy * particle.scaleY, particle.rotation, p_red * particle.red, p_green * particle.green, p_blue * particle.blue, p_alpha * particle.alpha, particle.blendMode);
            }
            particle = next;
        }
    }
	
	public function burst(p_emission:Int):Void {
		for (i in 0...p_emission) {
			spawnParticle();
		}
	}
	
	inline inline function spawnParticle() {
        var particle:GParticle = g2d_particlePool.g2d_get();
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

    inline private function disposeParticle(p_particle:GParticle):Void {
        if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
        if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
        p_particle.g2d_dispose();
    }
}