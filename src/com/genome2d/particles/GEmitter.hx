package com.genome2d.particles;

import com.genome2d.geom.GCurve;
import flash.Vector;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GEmitter
{
	public var x:Float = 0;
	public var y:Float = 0;
	
	public var emit:Bool = true;	
	
	public var duration:Float = 0;
	public var durationVariance:Float = 0;
	public var loop:Bool = false;
	
	public var delay:Float = 0;
	public var delayVariance:Float = 0;
	
	public var rate:GCurve;
	public var burstDistribution:Vector<Float>;
	
	private var g2d_accumulatedTime:Float = 0;
    private var g2d_accumulatedSecond:Float = 0;
    private var g2d_accumulatedEmission:Float = 0;
	
	private var g2d_firstParticle:GParticle;
    private var g2d_lastParticle:GParticle;
	
	public function new(p_system:GParticleSystem) {
		
	}	
	
	public function update(p_deltaTime:Float):Void {
		if (emit && emission != null ) {
            var dt:Float = p_deltaTime * .001;
            if (dt>0) {
                g2d_accumulatedTime += dt;
                if (loop && duration!=0 && g2d_accumulatedTime>duration) g2d_accumulatedTime-=duration;
                if (duration==0 || g2d_accumulatedTime<duration) {
                    var currentEmission:Float = emission.calculate(g2d_accumulatedTime / duration);

                    if (currentEmission<0) currentEmission = 0;
                    g2d_accumulatedEmission += currentEmission * dt;

                    while (g2d_accumulatedEmission > 0) {
                        createParticle();
                        g2d_accumulatedEmission--;
                    }
                }
            }
        }
	}
	
	private function createParticle():Void {
        var particle:GParticle = particlePool.g2d_get();
        if (g2d_lastParticle != null) {
            particle.g2d_previous = g2d_lastParticle;
            g2d_lastParticle.g2d_next = particle;
            g2d_lastParticle = particle;
        } else {
            g2d_firstParticle = particle;
            g2d_lastParticle = particle;
        }

        particle.init(this);
    }

    public function disposeParticle(p_particle:GParticle):Void {
        if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
        if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
        p_particle.dispose();
    }
}