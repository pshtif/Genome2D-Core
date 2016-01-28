/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.deprecated.particles;

import com.genome2d.deprecated.components.renderable.particles.GParticleSystemD;
import com.genome2d.context.GCamera;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

/**
    Particle element class used by `GParticlePool` and `GParticleSystem`
 **/
@:allow(com.genome2d.deprecated.particles.GParticlePoolD)
@:allow(Genome2D-Core.src.com.genome2d.deprecated.components.renderable.particles.GParticleSystem)
class GParticleD
{
    public var texture:GTexture;

    public var overrideRender:Bool = false;

    public var scaleX:Float;
    public var scaleY:Float;

    public var x:Float = 0;
    public var y:Float = 0;
    public var rotation:Float = 0;
    public var red:Float = 1;
    public var green:Float = 1;
    public var blue:Float = 1;
    public var alpha:Float = 1;

    public var velocityX:Float = 0;
    public var velocityY:Float = 0;

    public var totalEnergy:Float = 0;
    public var accumulatedEnergy:Float = 0;

    public var accumulatedTime:Float;
    public var currentFrame:Float;

    public var overrideUvs:Bool = false;
    public var uvX:Float;
    public var uvY:Float;
    public var uvScaleX:Float;
    public var uvScaleY:Float;

    public var die:Bool = false;

    private var g2d_next:GParticleD;
    private var g2d_previous:GParticleD;
    #if swc @:extern #end
    public var previous(get, never):GParticleD;
    #if swc @:getter(previous) #end
    inline private function get_previous():GParticleD {
        return g2d_previous;
    }

    private var g2d_nextAvailableInstance:GParticleD;

    public var index:Int = 0;
    private var g2d_pool:GParticlePoolD;

    @:dox(hide)
    public function new(p_pool:GParticlePoolD):Void {
        g2d_pool = p_pool;
        index = g2d_pool.g2d_count;
    }

    @:dox(hide)
    public function spawn(p_particleSystem:GParticleSystemD):Void {
        texture = p_particleSystem.texture;
        x = p_particleSystem.node.g2d_worldX;
        y = p_particleSystem.node.g2d_worldY;
        scaleX = scaleY = 1;
        rotation = 0;
        velocityX = 0;
        velocityY = 0;
        totalEnergy = 0;
        accumulatedEnergy = 0;
        red = 1;
        green = 1;
        blue = 1;
        alpha = 1;

        accumulatedTime = 0;
        currentFrame = 0;
    }

    @:dox(hide)
    public function dispose():Void {
        die = false;
        if (g2d_next != null) g2d_next.g2d_previous = g2d_previous;
        if (g2d_previous != null) g2d_previous.g2d_next = g2d_next;
        g2d_next = null;
        g2d_previous = null;
        g2d_nextAvailableInstance = g2d_pool.g2d_availableInstance;
        g2d_pool.g2d_availableInstance = this;
    }

    public function render(p_camera:GCamera, p_particleSystem:GParticleSystemD):Void {}
}