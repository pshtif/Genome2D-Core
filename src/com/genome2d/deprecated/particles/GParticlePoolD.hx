/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.deprecated.particles;

/**
    Particle pool management class, used for pooling `GParticle` instances for `GParticleSystem` components instances
**/
import com.genome2d.deprecated.particles.GParticleD;
import com.genome2d.deprecated.components.renderable.particles.GParticleSystemD;

@:allow(com.genome2d.deprecated.particles.GParticleD)
@:allow(com.genome2d.deprecated.components.renderable.particles.GParticleSystemD)
class GParticlePoolD
{
    static public var g2d_defaultPool:GParticlePoolD = new GParticlePoolD();

    public var g2d_availableInstance:GParticleD;
    private var g2d_count:Int = 0;

    private var g2d_particleClass:Class<GParticleD>;

    /**
        Create new particles pool, only if you want to implement pooling of custom particles otherwise let Genome2D
        use the default precreated pool shared by all `GParticleSystem` instances to save memory
    **/
    public function new(p_particleClass:Class<GParticleD> = null):Void {
        g2d_particleClass = (p_particleClass==null) ? GParticleD : p_particleClass;
    }

    /**
        Precache particles instances
    **/
    public function precache(p_precacheCount:Int):Void {
        if (p_precacheCount < g2d_count) return;

        var precached:GParticleD = g2d_get();
        while (g2d_count<p_precacheCount) {
            var n:GParticleD = g2d_get();
            n.g2d_previous = precached;
            precached = n;
        }

        while (precached != null) {
            var d:GParticleD = precached;
            precached = d.g2d_previous;
            d.dispose();
        }
    }

    private function g2d_get():GParticleD {
        var instance:GParticleD = g2d_availableInstance;
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