package com.genome2d.components.renderables.particles;

/**
 * ...
 * @author Peter "sHTiF" Stefcek
 */
import com.genome2d.geom.GFloatRectangle;
class GParticlePool
{
    static public var g2d_defaultPool:GParticlePool = new GParticlePool();

    public var g2d_availableInstance:GParticle;
    private var g2d_count:Int = 0;

    private var g2d_particleClass:Class<GParticle>;

    public function new(p_particleClass:Class<GParticle> = null):Void {
        g2d_particleClass = (p_particleClass==null) ? GParticle : p_particleClass;
    }

    public function precache(p_precacheCount:Int):Void {
        if (p_precacheCount < g2d_count) return;

        var precached:GParticle = get();
        while (g2d_count<p_precacheCount) {
            var n:GParticle = get();
            n.g2d_previous = precached;
            precached = n;
        }

        while (precached != null) {
            var d:GParticle = precached;
            precached = d.g2d_previous;
            d.dispose();
        }
    }

    public function get():GParticle {
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