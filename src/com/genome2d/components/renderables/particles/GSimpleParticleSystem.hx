package com.genome2d.components.renderables.particles;

import com.genome2d.geom.GRectangle;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.components.renderables.IRenderable;
import com.genome2d.context.GContextCamera;

/**
 * ...
 * @author 
 */
class GSimpleParticleSystem extends GComponent implements IRenderable
{
    public var blendMode:Int = 1;

	/**
	 * 	Emitting particles
	 */
	public var emit:Bool = false;

	public var initialScale:Float = 1;
	public var initialScaleVariance:Float = 0;
	public var endScale:Float = 1;
	public var endScaleVariance:Float = 0;

	public var energy:Float = 0;
	public var energyVariance:Float = 0;

	public var emission:Int = 1;
	public var emissionVariance:Int = 0;
	public var emissionTime:Float = 1;
	public var emissionDelay:Float = 0;

	public var initialVelocity:Float = 0;
	public var initialVelocityVariance:Float = 0;
	public var initialAcceleration:Float = 0;
	public var initialAccelerationVariance:Float = 0;

	public var initialAngularVelocity:Float = 0;
	public var initialAngularVelocityVariance:Float = 0;

	public var initialRed:Float = 1;
	public var initialRedVariance:Float = 0;
	public var initialGreen:Float = 1;
	public var initialGreenVariance:Float = 0;
	public var initialBlue:Float = 1;
	public var initialBlueVariance:Float = 0;
	public var initialAlpha:Float = 1;
	public var initialAlphaVariance:Float = 0;

    #if swc @:extern #end
	public var initialColor(get, set):Int;
    #if swc @:getter(initialColor) #end
	inline private function get_initialColor():Int {
		var red:Int = Std.int(initialRed * 0xFF) << 16;
		var green:Int = Std.int(initialGreen * 0xFF) << 8;
		var blue:Int = Std.int(initialBlue * 0xFF);
		return red+green+blue;
	}
    #if swc @:setter(initialColor) #end
	inline private function set_initialColor(p_value:Int):Int {
		initialRed = Std.int(p_value >> 16 & 0xFF) / 0xFF;
		initialGreen = Std.int(p_value >> 8 & 0xFF) / 0xFF;
		initialBlue = Std.int(p_value & 0xFF) / 0xFF;
		return p_value;
	}

	public var endRed:Float = 1;
	public var endRedVariance:Float = 0;
	public var endGreen:Float = 1;
	public var endGreenVariance:Float = 0;
	public var endBlue:Float = 1;
	public var endBlueVariance:Float = 0;
	public var endAlpha:Float = 1;
	public var endAlphaVariance:Float = 0;
	
	#if swc @:extern #end
	public var endColor(get, set):Int;
	#if swc @:getter(endColor) #end
	inline private function get_endColor():Int {
		var red:Int = Std.int(endRed * 0xFF) << 16;
		var green:Int = Std.int(endGreen * 0xFF) << 8;
		var blue:Int = Std.int(endBlue * 0xFF);
		return Std.int(red + green + blue);
	}
	#if swc @:setter(endColor) #end
	inline private function set_endColor(p_value:Int):Int {
		endRed = (p_value>>16&0xFF)/0xFF;
		endGreen = (p_value>>8&0xFF)/0xFF;
		endBlue = (p_value & 0xFF) / 0xFF;
		return p_value;
	}

	public var dispersionXVariance:Float = 0;
	public var dispersionYVariance:Float = 0;
	public var dispersionAngle:Float = 0;
	public var dispersionAngleVariance:Float = 0;

	public var initialAngle:Float = 0;
	public var initialAngleVariance:Float = 0;

	public var burst:Bool = false;

	public var special:Bool = false;

	private var g2d_accumulatedTime:Float = 0;
	private var g2d_accumulatedEmission:Float = 0;

	private var g2d_firstParticle:GSimpleParticle;
	private var g2d_lastParticle:GSimpleParticle;

	private var g2d_activeParticles:Int = 0;

	private var g2d_lastUpdateTime:Float;
	
	public var texture:GTexture;
	
	#if swc @:extern #end
	public var textureId(get, set):String;
	#if swc @:getter(textureId) #end
	inline private function get_textureId():String {
		return (texture != null) ? texture.getId() : "";
	}
	#if swc @:setter(textureId) #end
	inline private function set_textureId(p_value:String):String {
		texture = GTexture.getTextureById(p_value);
		return p_value;
	}

	private function setInitialParticlePosition(p_particle:GSimpleParticle):Void {
		/*
		if (useWorldSpace) {
			p_particleNode.cTransform.x = cNode.cTransform.nWorldX + Math.random() * dispersionXVariance - dispersionXVariance * .5;
			p_particleNode.cTransform.y = cNode.cTransform.nWorldY + Math.random() * dispersionYVariance-  dispersionYVariance * .5;
		} else {
			p_particleNode.cTransform.x = Math.random() * dispersionXVariance - dispersionXVariance * .5;
			p_particleNode.cTransform.y = Math.random() * dispersionYVariance - dispersionYVariance * .5;
		}
		/**/
		p_particle.g2d_x = node.transform.g2d_worldX;
		if (dispersionXVariance>0) p_particle.g2d_x += dispersionXVariance*Math.random() - dispersionXVariance*.5; 
		p_particle.g2d_y = node.transform.g2d_worldY;
		if (dispersionYVariance>0) p_particle.g2d_y += dispersionYVariance*Math.random() - dispersionYVariance*.5; 
		p_particle.g2d_rotation = initialAngle;
		if (initialAngleVariance>0) p_particle.g2d_rotation += initialAngleVariance*Math.random();
		p_particle.g2d_scaleX = p_particle.g2d_scaleY = initialScale;
		if (initialScaleVariance>0) {
			var sd:Float = initialScaleVariance*Math.random();
			p_particle.g2d_scaleX += sd;
			p_particle.g2d_scaleY += sd;
		}
	}

	/**
	 * 	@private
	 */
	public function new(p_node:GNode) {
		super(p_node);

        node.core.onUpdate.add(update);
	}

	public function init(p_maxCount:Int = 0, p_precacheCount:Int = 0, p_disposeImmediately:Bool = true):Void {
		g2d_accumulatedTime = 0;
		g2d_accumulatedEmission = 0;
	}

	private function createParticle():GSimpleParticle {
		var particle:GSimpleParticle = GSimpleParticle.get();
		if (g2d_firstParticle != null) {
			particle.g2d_next = g2d_firstParticle;
			g2d_firstParticle.g2d_previous = particle;
			g2d_firstParticle = particle;
		} else {
			g2d_firstParticle = particle;
			g2d_lastParticle = particle;
		}

		return particle;
	}

	public function forceBurst():Void {
		var currentEmission:Int = Std.int(emission + emissionVariance * Math.random());

		for (i in 0...currentEmission) {
			activateParticle();
		}
		emit = false;
	}

	public function update(p_deltaTime:Float):Void {
		g2d_lastUpdateTime = p_deltaTime;

		if (emit) {
			if (burst) {
				forceBurst();
			} else {
				g2d_accumulatedTime += p_deltaTime * .001;
				var time:Float = g2d_accumulatedTime%(emissionTime+emissionDelay);

				if (time <= emissionTime) {
					var updateEmission:Float = emission;
					if (emissionVariance>0) updateEmission += emissionVariance * Math.random(); 
					g2d_accumulatedEmission += updateEmission * p_deltaTime * .001;

					while (g2d_accumulatedEmission > 0) {
						activateParticle();
						g2d_accumulatedEmission--;
					}
				}
			}
		}
		
		var particle:GSimpleParticle = g2d_firstParticle;
		while (particle != null) {
			var next:GSimpleParticle = particle.g2d_next;

			particle.update(this, g2d_lastUpdateTime);
			particle = next;
		}	
	}

    // TODO add matrix transformations
	public function render(p_camera:GContextCamera, p_useMatrix:Bool):Void {
		if (texture == null) return;
		
		var particle:GSimpleParticle = g2d_firstParticle;

		while (particle != null) {
			var next:GSimpleParticle = particle.g2d_next;

			var tx:Float = node.transform.g2d_worldX + (particle.g2d_x - node.transform.g2d_worldX) * 1;
			var ty:Float = node.transform.g2d_worldY + (particle.g2d_y - node.transform.g2d_worldY) * 1;
		
			node.core.getContext().draw(texture, tx, ty, particle.g2d_scaleX*node.transform.g2d_worldScaleX, particle.g2d_scaleY*node.transform.g2d_worldScaleY, particle.g2d_rotation, particle.g2d_red, particle.g2d_green, particle.g2d_blue, particle.g2d_alpha, blendMode);

			particle = next;
		}
	}

	private function activateParticle():Void {
		var particle:GSimpleParticle = createParticle();
		setInitialParticlePosition(particle);
		
		particle.init(this);
	}

	public function deactivateParticle(p_particle:GSimpleParticle):Void {
		if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
		if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
		p_particle.dispose();
	}

	override public function dispose():Void {
		// TODO
		
		super.dispose();
	}

	public function clear(p_disposeCachedParticles:Bool = false):Void {
		// TODO
	}

    public function getBounds(p_target:GRectangle = null):GRectangle {
        // TODO
        return null;
    }
}