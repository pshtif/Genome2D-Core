/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderables.particles;

import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GCurve;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.components.renderables.IRenderable;
import com.genome2d.context.GContextCamera;

/**
    Component handling advanced particle systems with unlimited extendibility using custom particle instances and user defined affectors and initializers
 **/
class GParticleSystem extends GComponent implements IRenderable
{
    public var blendMode:Int = 1;

    public var emit:Bool = true;

    private var g2d_initializers:Array<IGInitializer>;
    private var g2d_initializersCount:Int = 0;
    public function addInitializer(p_initializer:IGInitializer):Void {
        g2d_initializers.push(p_initializer);
        g2d_initializersCount++;
    }

    private var g2d_affectors:Array<IGAffector>;
    private var g2d_affectorsCount:Int = 0;
    public function addAffector(p_affector:IGAffector):Void {
        g2d_affectors.push(p_affector);
        g2d_affectorsCount++;
    }

    /**
     *  Duration of the particle system in seconds
     */
    public var duration:Float = 0;
    /**
     *  Loop particle emission
     */
    public var loop:Bool = true;

    public var emission:GCurve;
    public var emissionPerDuration:Bool = true;

    public var particlePool:GParticlePool;

    private var g2d_accumulatedTime:Float = 0;
    private var g2d_accumulatedSecond:Float = 0;
    private var g2d_accumulatedEmission:Float = 0;

    private var g2d_firstParticle:GParticle;
    private var g2d_lastParticle:GParticle;

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
            activateParticle();
        }
    }

    private function update(p_deltaTime:Float):Void {
        if (emit && emission != null ) {
            var dt:Float = p_deltaTime * .001;
            g2d_accumulatedTime += dt;
            g2d_accumulatedSecond += dt;
            if (loop && duration!=0 && g2d_accumulatedTime>duration) g2d_accumulatedTime-=duration;
            if (duration==0 || g2d_accumulatedTime<duration) {
                //while (nAccumulatedTime>duration) nAccumulatedTime-=duration;
                //var currentEmission:Float = emission.calculate(nAccumulatedTime/duration);
                while (g2d_accumulatedSecond>1) g2d_accumulatedSecond-=1;
                var currentEmission:Float = (emissionPerDuration && duration!=0) ? emission.calculate(g2d_accumulatedTime/duration) : emission.calculate(g2d_accumulatedSecond);

                if (currentEmission<0) currentEmission = 0;
                g2d_accumulatedEmission += currentEmission * dt;

                while (g2d_accumulatedEmission > 0) {
                    activateParticle();
                    g2d_accumulatedEmission--;
                }
            }
        }
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;
            for (i in 0...g2d_affectorsCount) {
                g2d_affectors[i].update(this, particle, p_deltaTime);
            }
            // If particle died during update remove it
            if (particle.die) deactivateParticle(particle);
            particle = next;
        }
    }

    public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
        // TODO add matrix transformations
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;

            if (particle.overrideRender) {
                particle.render(p_camera, this);
            } else {
                var tx:Float = node.transform.g2d_worldX + (particle.x-node.transform.g2d_worldX)*1;//node.transform.g2d_worldScaleX;
                    var ty:Float = node.transform.g2d_worldY + (particle.y-node.transform.g2d_worldY)*1;//node.transform.g2d_worldScaleY;

                if (particle.overrideUvs) {
                    var zuvX:Float = particle.texture.uvX;
                    particle.texture.uvX = particle.uvX;
                    var zuvY:Float = particle.texture.uvY;
                    particle.texture.uvY = particle.uvY;
                    var zuvScaleX:Float = particle.texture.uvScaleX;
                    particle.texture.uvScaleX = particle.uvScaleX;
                    var zuvScaleY:Float = particle.texture.uvScaleY;
                    particle.texture.uvScaleY = particle.uvScaleY;
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.transform.g2d_worldScaleX, particle.scaleY*node.transform.g2d_worldScaleY, particle.rotation, particle.red*node.transform.g2d_worldRed, particle.green*node.transform.g2d_worldGreen, particle.blue*node.transform.g2d_worldBlue, particle.alpha*node.transform.g2d_worldAlpha, blendMode);
                    particle.texture.uvX = zuvX;
                    particle.texture.uvY = zuvY;
                    particle.texture.uvScaleX = zuvScaleX;
                    particle.texture.uvScaleY = zuvScaleY;
                } else {
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.transform.g2d_worldScaleX, particle.scaleY*node.transform.g2d_worldScaleY, particle.rotation, particle.red*node.transform.g2d_worldRed, particle.green*node.transform.g2d_worldGreen, particle.blue*node.transform.g2d_worldBlue, particle.alpha*node.transform.g2d_worldAlpha, blendMode);
                }
            }

            particle = next;
        }
    }

    private function activateParticle():Void {
        var particle:GParticle = particlePool.g2d_get();
        if (g2d_firstParticle != null) {
            particle.g2d_next = g2d_firstParticle;
            g2d_firstParticle.g2d_previous = particle;
            g2d_firstParticle = particle;
        } else {
            g2d_firstParticle = particle;
            g2d_lastParticle = particle;
        }

        particle.init(this);

        for (i in 0...g2d_initializersCount) {
            g2d_initializers[i].initialize(this, particle);
        }
    }

    public function deactivateParticle(p_particle:GParticle):Void {
        if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
        if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
        p_particle.dispose();
    }

    public function getBounds(p_target:GRectangle = null):GRectangle {
        return null;
    }
}