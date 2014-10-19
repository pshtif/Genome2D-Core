/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;

/**
    Particle pool management class, used for pooling `GParticle` instances for `GParticleSystem` component instances
**/
import com.genome2d.particles.GParticle;
@:allow(com.genome2d.components.renderables.particles.GParticleSystem)
class GParticlePool
{
    static public var g2d_defaultPool:GParticlePool = new GParticlePool();

    public var g2d_availableInstance:GParticle;
    private var g2d_count:Int = 0;

    private var g2d_particleClass:Class<GParticle>;

    /**
        Create new particle pool, only if you want to implement pooling of custom particles otherwise let Genome2D
        use the default precreated pool shared by all `GParticleSystem` instances to save memory
    **/
    public function new(p_particleClass:Class<GParticle> = null):Void {
        g2d_particleClass = (p_particleClass==null) ? GParticle : p_particleClass;
    }

    /**
        Precache particle instances
    **/
    public function precache(p_precacheCount:Int):Void {
        if (p_precacheCount < g2d_count) return;

        var precached:GParticle = g2d_get();
        while (g2d_count<p_precacheCount) {
            var n:GParticle = g2d_get();
            n.g2d_previous = precached;
            precached = n;
        }

        while (precached != null) {
            var d:GParticle = precached;
            precached = d.g2d_previous;
            d.dispose();
        }
    }

    private function g2d_get():GParticle {
        var instance:GParticle = g2d_availableInstance;
        if (instance != null) {
            g2d_availableInstance = instance.g2d_nextAvailableInstance;
            instance.g2d_nextAvailableInstance = null;
        } else {
            instance = Type.createInstance(g2d_particleClass, [this]);
            g2d_count++;
        }

        return instance;
    }
}