/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;

import com.genome2d.deprecated.components.renderable.particles.GParticleSystemD;
import com.genome2d.context.GCamera;
import com.genome2d.context.IGContext;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;

/**
    Particle class
**/
@:allow(com.genome2d.particles.GParticlePool)
@:allow(com.genome2d.particles.GParticleEmitter)
class GParticle
{
	// SPH Properties
	public var fx:Float = 0;
	public var fy:Float = 0;
	public var viscosity:Float = .1;
	public var gx:Int = 0;
	public var gy:Int = 0;
	public var density:Float = 0;
	public var densityNear:Float = 0;
	public var type:Int = 0;
	public var vx:Float = 0;
	public var vy:Float = 0;
	
	public var implementUpdate:Bool = false;
    public var implementRender:Bool = false;
    
	// Transform
    public var x:Float = 0;
    public var y:Float = 0;
	public var scaleX:Float;
    public var scaleY:Float;
    public var rotation:Float = 0;
	// Render
    public var red:Float = 1;
    public var green:Float = 1;
    public var blue:Float = 1;
    public var alpha:Float = 1;
	public var texture:GTexture;
	
	// Dynamics
    public var velocityX:Float = 0;
    public var velocityY:Float = 0;

    public var totalEnergy:Float = 0;
    public var accumulatedEnergy:Float = 0;

    public var accumulatedTime:Float;
    public var currentFrame:Float;

    public var die:Bool = false;

    private var g2d_next:GParticle;
    private var g2d_previous:GParticle;
    #if swc @:extern #end
    public var previous(get, never):GParticle;
    #if swc @:getter(previous) #end
    inline private function get_previous():GParticle {
        return g2d_previous;
    }

    private var g2d_nextAvailableInstance:GParticle;

    public var index:Int = 0;
    private var g2d_pool:GParticlePool;

	static public var g2d_instanceId:Int = 0;
	public var instanceId:Int;
    @:dox(hide)
    public function new(p_pool:GParticlePool):Void {
		instanceId = g2d_instanceId++;
        g2d_pool = p_pool;
        index = g2d_pool.g2d_count;
    }

    private function g2d_spawn(p_emitter:GParticleEmitter):Void {
		fx = fy = vx = vy = 0;
		
		
        texture = p_emitter.texture;
        x = p_emitter.x;
        y = p_emitter.y;
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
	
	private function g2d_update(p_emitter:GParticleEmitter, p_deltaTime:Float):Void {}

    private function g2d_render(p_context:IGContext, p_emitter:GParticleEmitter, p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Void { }

	private function g2d_dispose():Void {
        die = false;
        if (g2d_next != null) g2d_next.g2d_previous = g2d_previous;
        if (g2d_previous != null) g2d_previous.g2d_next = g2d_next;
        g2d_next = null;
        g2d_previous = null;
        g2d_nextAvailableInstance = g2d_pool.g2d_availableInstance;
        g2d_pool.g2d_availableInstance = this;
    }
}