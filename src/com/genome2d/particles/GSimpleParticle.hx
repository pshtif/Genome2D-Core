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
    Simple particles element used by `GSimpleParticleSystem`
**/
import com.genome2d.textures.GTexture;
import com.genome2d.components.renderable.particles.GSimpleParticleSystem;
@:allow(com.genome2d.components.renderable.particles.GSimpleParticleSystem)
class GSimpleParticle
{
	private var g2d_next:GSimpleParticle;
	private var g2d_previous:GSimpleParticle;

	private var g2d_x:Float;
	private var g2d_y:Float;
	private var g2d_rotation:Float;
	private var g2d_scaleX:Float;
	private var g2d_scaleY:Float;
	private var g2d_red:Float;
	private var g2d_green:Float;
	private var g2d_blue:Float;
	private var g2d_alpha:Float;

	private var g2d_velocityX:Float = 0;
	private var g2d_velocityY:Float = 0;
	
	private var g2d_accelerationX:Float;
	private var g2d_accelerationY:Float;
	
	private var g2d_energy:Float = 0;
	
	private var g2d_initialScale:Float = 1;
	private var g2d_endScale:Float = 1;
	
	private var g2d_initialVelocityX:Float;
	private var g2d_initialVelocityY:Float;
	private var g2d_initialVelocityAngular:Float;
	
	private var g2d_initialAccelerationX:Float;
	private var g2d_initialAccelerationY:Float;
	
	private var g2d_initialRed:Float;
	private var g2d_initialGreen:Float;
	private var g2d_initialBlue:Float;
	private var g2d_initialAlpha:Float;
	
	private var g2d_endRed:Float;
	private var g2d_endGreen:Float;
	private var g2d_endBlue:Float;
	private var g2d_endAlpha:Float;
	
	private var g2d_redDif:Float;
	private var g2d_greenDif:Float;
	private var g2d_blueDif:Float;
	private var g2d_alphaDif:Float;
	
	private var g2d_scaleDif:Float;
	
	private var g2d_accumulatedEnergy:Float = 0;
	
	private var g2d_nextInstance:GSimpleParticle;
	private var g2d_id:Int = 0;

    private var g2d_texture:GTexture;

    static private var g2d_availableInstance:GSimpleParticle;
    static private var g2d_instanceCount:Int = 0;

    @:dox(hide)
	public function new():Void {
		g2d_id = g2d_instanceCount++;
	}

    @:dox(hide)
	static public function precache(p_precacheCount:Int):Void {
		if (p_precacheCount < g2d_instanceCount) return;
		
		var precached:GSimpleParticle = g2d_get();
		while (g2d_instanceCount<p_precacheCount) {
			var n:GSimpleParticle = g2d_get();
			n.g2d_previous = precached;
			precached = n;
		}
		
		while (precached != null) {
			var d:GSimpleParticle = precached;
			precached = d.g2d_previous;
			d.g2d_dispose();
		}
	}

	static private function g2d_get():GSimpleParticle {
		var instance:GSimpleParticle = g2d_availableInstance;
		if (instance != null) {
			g2d_availableInstance = instance.g2d_nextInstance;
			instance.g2d_nextInstance = null;
		} else {
			instance = new GSimpleParticle();
		}

		return instance;
	}

	private function g2d_init(p_emitter:GSimpleParticleSystem, p_invalidate:Bool = true):Void {
		g2d_accumulatedEnergy = 0;

        g2d_texture = p_emitter.texture;
		
		g2d_energy = p_emitter.energy * 1000;
		if (p_emitter.energyVariance>0) g2d_energy += (p_emitter.energyVariance * 1000) * Math.random();
		
		g2d_initialScale = p_emitter.initialScale;
		if (p_emitter.initialScaleVariance>0) g2d_initialScale += p_emitter.initialScaleVariance*Math.random();
		g2d_endScale = p_emitter.endScale;
		if (p_emitter.endScaleVariance>0) g2d_endScale += p_emitter.endScaleVariance*Math.random();
		
		var particleVelocityX:Float;
		var particleVelocityY:Float;
		var v:Float = p_emitter.initialVelocity;
		if (p_emitter.initialVelocityVariance>0) v += p_emitter.initialVelocityVariance * Math.random();
		
		var particleAccelerationX:Float;
		var particleAccelerationY:Float;
		var a:Float = p_emitter.initialAcceleration;
		if (p_emitter.initialAccelerationVariance>0) a += p_emitter.initialAccelerationVariance * Math.random();
		
		var vX:Float = particleVelocityX = v;
		var vY:Float = particleVelocityY = 0;
		var aX:Float = particleAccelerationX = a;
		var aY:Float = particleAccelerationY = 0;
		
		var rot:Float = p_emitter.node.transform.g2d_worldRotation;
		if (rot!=0) {
			var sin:Float = Math.sin(rot);
			var cos:Float = Math.cos(rot);
			
			vX = particleVelocityX = v*cos;
			vY = particleVelocityY = v*sin;
			aX = particleAccelerationX = a*cos;
			aY = particleAccelerationY = a*sin;
		}
		
		if (p_emitter.dispersionAngle!=0 || p_emitter.dispersionAngleVariance!=0) {
			var rangle:Float = p_emitter.dispersionAngle;
			if (p_emitter.dispersionAngleVariance>0) rangle += p_emitter.dispersionAngleVariance * Math.random();
			var sin:Float = Math.sin(rangle);
			var cos:Float = Math.cos(rangle);
			
			particleVelocityX = (vX*cos - vY*sin);
			particleVelocityY = (vY*cos + vX*sin);
			particleAccelerationX = (aX*cos - aY*sin);
			particleAccelerationY = (aY*cos + aX*sin);
		}
		
		g2d_initialVelocityX = g2d_velocityX = particleVelocityX * .001;
		g2d_initialVelocityY = g2d_velocityY = particleVelocityY * .001;
		g2d_initialAccelerationX = g2d_accelerationX = particleAccelerationX * .001;
		g2d_initialAccelerationY = g2d_accelerationY = particleAccelerationY * .001;
		
		g2d_initialVelocityAngular = p_emitter.initialAngularVelocity;
		if (p_emitter.initialAngularVelocityVariance>0) g2d_initialVelocityAngular += p_emitter.initialAngularVelocityVariance * Math.random();
		
		g2d_initialRed = p_emitter.initialRed;
		if (p_emitter.initialRedVariance>0) g2d_initialRed += p_emitter.initialRedVariance * Math.random(); 
		g2d_initialGreen = p_emitter.initialGreen;
		if (p_emitter.initialGreenVariance>0) g2d_initialGreen += p_emitter.initialGreenVariance * Math.random();
		g2d_initialBlue = p_emitter.initialBlue;
		if (p_emitter.initialBlueVariance>0) g2d_initialBlue += p_emitter.initialBlueVariance * Math.random();
		g2d_initialAlpha = p_emitter.initialAlpha;
		if (p_emitter.initialAlphaVariance>0) g2d_initialAlpha += p_emitter.initialAlphaVariance * Math.random();
		
		g2d_endRed = p_emitter.endRed;
		if (p_emitter.endRedVariance>0) g2d_endRed += p_emitter.endRedVariance * Math.random(); 
		g2d_endGreen = p_emitter.endGreen;
		if (p_emitter.endGreenVariance>0) g2d_endGreen += p_emitter.endGreenVariance * Math.random();
		g2d_endBlue = p_emitter.endBlue;
		if (p_emitter.endBlueVariance>0) g2d_endBlue += p_emitter.endBlueVariance * Math.random();
		g2d_endAlpha = p_emitter.endAlpha;
		if (p_emitter.endAlphaVariance>0) g2d_endAlpha += p_emitter.endAlphaVariance * Math.random();
		
		g2d_redDif = g2d_endRed - g2d_initialRed;
		g2d_greenDif = g2d_endGreen - g2d_initialGreen;
		g2d_blueDif = g2d_endBlue - g2d_initialBlue;
		g2d_alphaDif = g2d_endAlpha - g2d_initialAlpha;
		
		g2d_scaleDif = g2d_endScale - g2d_initialScale;
	}

	private function g2d_update(p_emitter:GSimpleParticleSystem, p_deltaTime:Float):Void {
		g2d_accumulatedEnergy += p_deltaTime;
	
		if (g2d_accumulatedEnergy >= g2d_energy) {
			p_emitter.deactivateParticle(this);
			return;
		}
		/*
		for (i in 0...p_emitter.g2d_fieldsCount) {
			p_emitter.aFields[i].updateSimpleParticle(this, p_deltaTime);
		}
		/**/
		var p:Float = g2d_accumulatedEnergy/g2d_energy;
		g2d_velocityX += g2d_accelerationX*p_deltaTime;
		g2d_velocityY += g2d_accelerationY*p_deltaTime;
		
		g2d_red = g2d_redDif*p + g2d_initialRed;
		g2d_green = g2d_greenDif*p + g2d_initialGreen;
		g2d_blue = g2d_blueDif*p + g2d_initialBlue;
		g2d_alpha = g2d_alphaDif*p + g2d_initialAlpha;			
		
		g2d_x += g2d_velocityX * p_deltaTime;
		g2d_y += g2d_velocityY * p_deltaTime;
		
		g2d_rotation += g2d_initialVelocityAngular * p_deltaTime;
		g2d_scaleX = g2d_scaleY = g2d_scaleDif*p + g2d_initialScale;
		/*
		if (nX<=0 || nX>=800) nVelocityX = -nVelocityX;
		if (nY<=0 || nY>=600) nVelocityY = -nVelocityY;
		/*
		
		if (p_emitter.special) {
			var n:Float = Math.sqrt(g2d_velocityX*g2d_velocityX+g2d_velocityY*g2d_velocityY);
			g2d_scaleY = n*10;
			g2d_rotation = -Math.atan2(g2d_velocityX, g2d_velocityY);
		}
		/**/
	}

	private function g2d_dispose():Void {
		if (g2d_next != null) g2d_next.g2d_previous = g2d_previous;
		if (g2d_previous != null) g2d_previous.g2d_next = g2d_next;
		g2d_next = null;
		g2d_previous = null;
		g2d_nextInstance = g2d_availableInstance;
		g2d_availableInstance = this;
	}
}