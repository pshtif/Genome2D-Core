/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable.particles;

import com.genome2d.signals.GMouseSignal;
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
     *  Duration of the particles system in seconds
     */
    public var duration:Float = 0;
    /**
     *  Loop particles emission
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

    #if swc @:extern #end
    public var textureId(get, set):String;
    #if swc @:getter(textureId) #end
    inline private function get_textureId():String {
        return (texture != null) ? texture.id : "";
    }
    #if swc @:setter(textureId) #end
    inline private function set_textureId(p_value:String):String {
        texture = GTextureManager.getTextureById(p_value);
        return p_value;
    }

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

    public function update(p_deltaTime:Float):Void {
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
            // If particles died during update remove it
            if (particle.die) deactivateParticle(particle);
            particle = next;
        }
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        // TODO add matrix transformations
        var particle:GParticle = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticle = particle.g2d_next;

            if (particle.overrideRender) {
                particle.render(p_camera, this);
            } else {
                var tx:Float = node.g2d_worldX + (particle.x-node.g2d_worldX)*1;//node.g2d_worldScaleX;
                var ty:Float = node.g2d_worldY + (particle.y-node.g2d_worldY)*1;//node.g2d_worldScaleY;

                if (particle.overrideUvs) {
                /*
                    var zu:Float = particle.texture.g2d_u;
                    particle.texture.uvX = particle.u;
                    var zv:Float = particle.texture.g2d_v;
                    particle.texture.uvY = particle.v;
                    var zuScale:Float = particle.texture.g2d_uScale;
                    particle.texture.uvScaleX = particle.uScale;
                    var zvScale:Float = particle.texture.g2d_vScale;
                    particle.texture.uvScaleY = particle.vScale;
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.g2d_worldScaleX, particle.scaleY*node.g2d_worldScaleY, particle.rotation, particle.red*node.g2d_worldRed, particle.green*node.g2d_worldGreen, particle.blue*node.g2d_worldBlue, particle.alpha*node.g2d_worldAlpha, blendMode);
                    particle.texture.g2d_u = zu;
                    particle.texture.g2d_v = zv;
                    particle.texture.g2d_uScale = zuScale;
                    particle.texture.g2d_vScale = zvScale;
                /**/
                } else {
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.g2d_worldScaleX, particle.scaleY*node.g2d_worldScaleY, particle.rotation, particle.red*node.g2d_worldRed, particle.green*node.g2d_worldGreen, particle.blue*node.g2d_worldBlue, particle.alpha*node.g2d_worldAlpha, blendMode);
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

    override public function dispose():Void {
        while (g2d_firstParticle != null) deactivateParticle(g2d_firstParticle);
        node.core.onUpdate.remove(update);

        super.dispose();
    }

    public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
        return false;
    }
}