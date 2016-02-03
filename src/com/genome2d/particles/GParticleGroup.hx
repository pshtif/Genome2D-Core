package com.genome2d.particles;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GParticleGroup
{
	public var particles:Array<GParticle>;
	public var particleCount:UInt = 0;
	public var massX:Float = 0;
	public var massY:Float = 0;
	public var vx:Float = 0;
	public var vy:Float = 0;
	public var torque:Float = 0;
	public var rigid:Bool = false;
	public var rigidAllowTranslation:Bool = true;
	public var rigidAllowRotation:Bool = true;
	
	public function new() {
        particles = new Array<GParticle>();
    }
	
	inline public function addParticle(p_particle:GParticle):Void {
        particles[particleCount++] = p_particle;
		massX += p_particle.x;
		massY += p_particle.y;
	}
	
	inline public function calculateForce():Void {		
		massX /= particleCount;
		massY /= particleCount;
		
		if (rigid) {
			var t:Float = 0;
			var ax:Float = 0;
			var ay:Float = 0;
			for (particle in particles) {
				var fx:Float = particle.fluidX / (particle.density * 0.9 + 0.1);
				var fy:Float = particle.fluidY / (particle.density * 0.9 + 0.1);
				if (rigidAllowRotation) t += crossProduct(massX - particle.x, massY - particle.y, fx, fy);
				if (rigidAllowTranslation) {
					ax += fx;
					ay += fy;
				}
			}
			torque += t / particleCount;
			vx += ax / (particleCount);
			vy += ay / (particleCount);
			var sin:Float = Math.sin(-torque/1000);
			var cos:Float = Math.cos(-torque/1000);
			for (particle in particles) {
				if (rigidAllowRotation) {
					var tx:Float = particle.x - massX;
					var ty:Float = particle.y - massY;
					var nx = tx * cos - ty * sin;
					var ny = tx * sin + ty * cos;
					particle.x = massX + nx;
					particle.y = massY + ny;
				}
				if (rigidAllowTranslation) {
					particle.velocityX = vx;
					particle.velocityY = vy;
				}
			}
		} else {
			for (particle in particles) {
				if (particle.density > 0 && !particle.fixed) {
					particle.velocityY += .1;
					particle.velocityX += particle.fluidX / (particle.density * 0.9 + 0.1);
					particle.velocityY += particle.fluidY / (particle.density * 0.9 + 0.1);
				}
			}
		}
	}
	
	inline private function crossProduct(p_v1x:Float, p_v1y:Float, p_v2x:Float, p_v2y:Float):Float {
		return (p_v1x*p_v2y) - (p_v1y*p_v2x);
	}
}