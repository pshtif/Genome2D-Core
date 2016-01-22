/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable.particles;

import com.genome2d.input.GMouseInput;
import com.genome2d.particles.IGParticleSystem;
import com.genome2d.textures.GTextureManager;
import com.genome2d.particles.GParticlePool;
import com.genome2d.particles.IGInitializer;
import com.genome2d.particles.IGAffector;
import com.genome2d.particles.GParticle;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GCurve;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.context.GCamera;

/**
    Component handling advanced particles systems with unlimited extendibility using custom particles instances and user defined affectors and initializers
 **/
@:access(com.genome2d.particles.GParticle)
class GParticleSystem extends IGParticleSystem
{
    public var timeDilation:Float = 1;

    /**
     *  Loop particles emission
     */
    public var loop:Bool = true;

    public var emission:GCurve;
    public var emissionPerDuration:Bool = true;

    public var particlePool:GParticlePool;

    public var texture:GTexture;

    override public function init():Void {
        particlePool = GParticlePool.g2d_defaultPool;

        g2d_initializers = new Array<IGInitializer>();
        g2d_affectors = new Array<IGAffector>();

        node.core.onUpdate.add(update);
    }

    public function reset():Void {
        g2d_accumulatedTime = 0;
        g2d_accumulatedSecond = 0;
        g2d_accumulatedEmission = 0;
    }

    public function burst(p_emission:Int):Void {
        for (i in 0...p_emission) {
            createParticle();
        }
    }

    public function update(p_deltaTime:Float):Void {
        p_deltaTime *= timeDilation;
        
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;

            if (particle.die) disposeParticle(particle);
            particle = next;
        }
    }

    public function render(p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Void {
        // TODO add matrix transformations
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;

            if (particle.overrideRender) {
                particle.render(p_x, p_y, p_scaleX, p_scaleY, p_red, p_green, p_blue, p_alpha, this);
            } else {
                node.core.getContext().draw(particle.texture, p_x + particle.x * p_scaleX, p_y + particle.y * p_scaleY, p_scaleX + particle.scaleX, particle.scaleY * p_scaleY, particle.rotation, p_red * particle.red, p_green * particle.green, p_blue * particle.blue, p_alpha * particle.alpha, blendMode);
            }

            particle = next;
        }
    }

    public function dispose():Void {
        while (g2d_firstParticle != null) disposeParticle(g2d_firstParticle);
        node.core.onUpdate.remove(update);

        super.dispose();
    }
}