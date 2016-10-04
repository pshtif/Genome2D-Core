/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.deprecated.components.renderable.particles;

import com.genome2d.input.GMouseInput;
import com.genome2d.textures.GTextureManager;
import com.genome2d.deprecated.particles.GSimpleParticleD;
import com.genome2d.debug.GDebug;
import com.genome2d.geom.GRectangle;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.components.renderable.IGRenderable;
import com.genome2d.context.GCamera;

/**
    Component handling simple particles systems used for best performance
 **/
class GSimpleParticleSystemD extends GComponent implements IGRenderable
{
	@category("rendering")
	@prototype
    public var blendMode:Int = 1;

	@prototype
	public var emit:Bool = false;

	@prototype
    public var useWorldSpace:Bool = false;

	@category("rendering")
	@range(0, 10)
	@prototype
	public var initialScale:Float = 1;
	@category("rendering")
	@prototype
	public var initialScaleVariance:Float = 0;
	@category("rendering")
	@prototype
	public var endScale:Float = 1;
	@category("rendering")
	@prototype
	public var endScaleVariance:Float = 0;

	@prototype
	public var energy:Float = 0;
	@prototype
	public var energyVariance:Float = 0;

	@prototype
	public var emission:Int = 1;
	@prototype
	public var emissionVariance:Int = 0;
	@prototype
	public var emissionTime:Float = 1;
	@prototype
	public var emissionDelay:Float = 0;

	@prototype
	public var initialVelocity:Float = 0;
	@prototype
	public var initialVelocityVariance:Float = 0;
	@prototype
	public var initialAcceleration:Float = 0;
	@prototype
	public var initialAccelerationVariance:Float = 0;

	@prototype
	public var initialAngularVelocity:Float = 0;
	@prototype
	public var initialAngularVelocityVariance:Float = 0;


	public var initialRed:Float = 1;
	@category("color")
	@prototype
	public var initialRedVariance:Float = 0;

	public var initialGreen:Float = 1;
	@category("color")
	@prototype
	public var initialGreenVariance:Float = 0;

	public var initialBlue:Float = 1;
	@category("color")
	@prototype
	public var initialBlueVariance:Float = 0;

	@category("color")
	@prototype
	public var initialAlpha:Float = 1;
	@category("color")
	@prototype
	public var initialAlphaVariance:Float = 0;

    #if swc @:extern #end
	@category("color")
	@prototype
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
	@category("color")
	@prototype
	public var endRedVariance:Float = 0;

	public var endGreen:Float = 1;
	@category("color")
	@prototype
	public var endGreenVariance:Float = 0;

	public var endBlue:Float = 1;
	@category("color")
	@prototype
	public var endBlueVariance:Float = 0;
	@category("color")
	@prototype
	public var endAlpha:Float = 1;
	@category("color")
	@prototype
	public var endAlphaVariance:Float = 0;
	
	#if swc @:extern #end
	@category("color")
	@prototype
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

	@prototype
	public var dispersionXVariance:Float = 0;
	@prototype
	public var dispersionYVariance:Float = 0;
	@prototype
	public var dispersionAngle:Float = 0;
	@prototype
	public var dispersionAngleVariance:Float = 0;

	@prototype
	public var initialAngle:Float = 0;
	@prototype
	public var initialAngleVariance:Float = 0;
	
	@prototype
	public var paused:Bool = false;

	@prototype
	public var burst:Bool = false;

	private var g2d_accumulatedTime:Float = 0;
	private var g2d_accumulatedEmission:Float = 0;

	private var g2d_firstParticle:GSimpleParticleD;
	private var g2d_lastParticle:GSimpleParticleD;

	private var g2d_activeParticles:Int = 0;

	private var g2d_lastUpdateTime:Float;

    #if swc @:extern #end
	//@prototype
    public var settings(get,set):String;
    #if swc @:getter(settings) #end
    inline private function get_settings():String {
        return blendMode+"|"+emit+"|"+useWorldSpace+"|"+initialScale+"|"+initialScaleVariance+"|"+endScale+"|"+endScaleVariance+"|"+energy+"|"+energyVariance+"|"+emission+"|"+emissionVariance+"|"+emissionTime+"|"+emissionDelay+"|"+initialVelocity+"|"+initialVelocityVariance+"|"+initialAcceleration+"|"+initialAccelerationVariance+"|"+initialAngularVelocity+"|"+initialAngularVelocityVariance+"|"+
        initialRed+"|"+initialRedVariance+"|"+initialGreen+"|"+initialGreenVariance+"|"+initialBlue+"|"+initialBlueVariance+"|"+initialAlpha+"|"+initialAlphaVariance+"|"+
        endRed+"|"+endRedVariance+"|"+endGreen+"|"+endGreenVariance+"|"+endBlue+"|"+endBlueVariance+"|"+endAlpha+"|"+endAlphaVariance+"|"+
        dispersionXVariance+"|"+dispersionYVariance+"|"+dispersionAngle+"|"+dispersionAngleVariance+"|"+initialAngle+"|"+initialAngleVariance+"|"+burst+"|"+texture.id;
    }
    #if swc @:setter(settings) #end
    inline private function set_settings(p_value:String):String {
        var split:Array<String> = p_value.split("|");

        blendMode = Std.parseInt(split[0]);
        emit = split[1]=="true" ? true : false;
        useWorldSpace = split[2]=="true" ? true : false;
        initialScale = Std.parseFloat(split[3]);
        initialScaleVariance = Std.parseFloat(split[4]);
        endScale = Std.parseFloat(split[5]);
        endScaleVariance = Std.parseFloat(split[6]);
        energy = Std.parseFloat(split[7]);
        energyVariance = Std.parseFloat(split[8]);
        emission = Std.parseInt(split[9]);
        emissionVariance = Std.parseInt(split[10]);
        emissionTime = Std.parseFloat(split[11]);
        emissionDelay = Std.parseFloat(split[12]);

        initialVelocity = Std.parseFloat(split[13]);
        initialVelocityVariance = Std.parseFloat(split[14]);
        initialAcceleration = Std.parseFloat(split[15]);
        initialAccelerationVariance = Std.parseFloat(split[16]);
        initialAngularVelocity = Std.parseFloat(split[17]);
        initialAngularVelocityVariance = Std.parseFloat(split[18]);

        initialRed = Std.parseFloat(split[19]);
        initialRedVariance = Std.parseFloat(split[20]);
        initialGreen = Std.parseFloat(split[21]);
        initialGreenVariance = Std.parseFloat(split[22]);
        initialBlue = Std.parseFloat(split[23]);
        initialBlueVariance = Std.parseFloat(split[24]);
        initialAlpha = Std.parseFloat(split[25]);
        initialAlphaVariance = Std.parseFloat(split[26]);

        endRed = Std.parseFloat(split[27]);
        endRedVariance = Std.parseFloat(split[28]);
        endGreen = Std.parseFloat(split[29]);
        endGreenVariance = Std.parseFloat(split[30]);
        endBlue = Std.parseFloat(split[31]);
        endBlueVariance = Std.parseFloat(split[32]);
        endAlpha = Std.parseFloat(split[33]);
        endAlphaVariance = Std.parseFloat(split[34]);

        dispersionXVariance = Std.parseFloat(split[35]);
        dispersionYVariance = Std.parseFloat(split[36]);
        dispersionAngle = Std.parseFloat(split[37]);
        dispersionAngleVariance = Std.parseFloat(split[38]);
        initialAngle = Std.parseFloat(split[39]);
        initialAngleVariance = Std.parseFloat(split[40]);
        burst = split[41]=="true" ? true : false;

        texture = GTextureManager.getTexture(split[42]);

        return p_value;
    }

	@category("rendering")
	@prototype("getReference")
	public var texture:GTexture;

	private function setInitialParticlePosition(p_particle:GSimpleParticleD):Void {
        p_particle.g2d_x = (useWorldSpace) ? node.g2d_worldX : 0;
        if (dispersionXVariance>0) p_particle.g2d_x += dispersionXVariance*Math.random() - dispersionXVariance*.5;
        p_particle.g2d_y = (useWorldSpace) ? node.g2d_worldY : 0;
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

	override public function init():Void {
        node.core.onUpdate.add(update);
	}

	public function setup(p_maxCount:Int = 0, p_precacheCount:Int = 0, p_disposeImmediately:Bool = true):Void {
		g2d_accumulatedTime = 0;
		g2d_accumulatedEmission = 0;
	}

	public function forceBurst():Void {
		var currentEmission:Int = Std.int(emission + emissionVariance * Math.random());

		for (i in 0...currentEmission) {
			g2d_activateParticle();
		}
		emit = false;
	}

	public function update(p_deltaTime:Float):Void {
		g2d_lastUpdateTime = p_deltaTime;
		if (!paused) {
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
							g2d_activateParticle();
							g2d_accumulatedEmission--;
						}
					}
				}
			}
			
			var particle:GSimpleParticleD = g2d_firstParticle;
			while (particle != null) {
				var next:GSimpleParticleD = particle.g2d_next;

				particle.g2d_update(this, g2d_lastUpdateTime);
				particle = next;
			}	
		}
	}

	public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        // TODO add matrix transformations
		if (texture == null) return;
		
		var particle:GSimpleParticleD = g2d_firstParticle;

		while (particle != null) {
			var next:GSimpleParticleD = particle.g2d_next;

            var tx:Float;
            var ty:Float;
            if (useWorldSpace) {
                tx = particle.g2d_x;
                ty = particle.g2d_y;
            } else {
                tx = node.g2d_worldX + particle.g2d_x;
                ty = node.g2d_worldY + particle.g2d_y;
            }
		
			node.core.getContext().draw(particle.g2d_texture, tx, ty, particle.g2d_scaleX*node.g2d_worldScaleX, particle.g2d_scaleY*node.g2d_worldScaleY, particle.g2d_rotation, particle.g2d_red, particle.g2d_green, particle.g2d_blue, particle.g2d_alpha, blendMode);

			particle = next;
		}
	}

	private function g2d_activateParticle():Void {
		var particle:GSimpleParticleD = g2d_createParticle();
		setInitialParticlePosition(particle);
		
		particle.g2d_init(this);
	}
	
	private function g2d_createParticle():GSimpleParticleD {
		var particle:GSimpleParticleD = GSimpleParticleD.g2d_get();
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

	public function deactivateParticle(p_particle:GSimpleParticleD):Void {
		if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
		if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
		p_particle.g2d_dispose();
	}

	override public function dispose():Void {
        while (g2d_firstParticle != null) deactivateParticle(g2d_firstParticle);
        node.core.onUpdate.remove(update);
		
		super.dispose();
	}

	public function clear():Void {
		while (g2d_firstParticle != null) {
			deactivateParticle(g2d_firstParticle);
		}
	}

    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (p_bounds != null) p_bounds.setTo( -8, -8, 16, 16);
        else p_bounds = new GRectangle( -8, -8, 16, 16);
			
		return p_bounds;
    }

    public function captureMouseInput(p_input:GMouseInput):Void {
		p_input.g2d_captured = p_input.g2d_captured || hitTest(p_input.localX, p_input.localY);
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
		var hit:Bool = false;
		p_x = p_x / 16 + .5;
		p_y = p_y / 16 + .5;

		hit = (p_x >= 0 && p_x <= 1 && p_y >= 0 && p_y <= 1);
		
		return hit;
    }
}