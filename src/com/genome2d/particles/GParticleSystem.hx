/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;

import com.genome2d.context.IGContext;
import com.genome2d.geom.GRectangle;

@:access(com.genome2d.particles.GParticle)
@:access(com.genome2d.particles.GParticleEmitter)
class GParticleSystem
{
    public var timeDilation:Float = 1;
	public var enableSph:Bool = false;
	
	private var g2d_emitters:Array<GParticleEmitter>;
	private var g2d_emitterCount:Int = 0;
	
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var red:Float = 1;
	public var green:Float = 1;
	public var blue:Float = 1;
	public var alpha:Float = 1;
	public var enabled:Bool = true;
	
	/**
	 * 	Smoothed Particle Hydrodynamics properties
	 */
	inline static public var PRESSURE:Float = 1;
    inline static public var NEAR_PRESSURE:Float = 1;	
    inline static public var RANGE:Float = 16;
    inline static public var RANGE2:Float = RANGE * RANGE;
	
	private var g2d_width:Float;
	private var g2d_height:Float;
	private var g2d_gridCellSize:Int;
	private var g2d_gridWidthCount:Int = 0;
	private var g2d_gridHeightCount:Int = 0;
	private var g2d_grids:Array<Array<GSPHGrid>>;
	private var g2d_invertedGridCellSize:Float;
	private var g2d_neighborCount:Int;
	private var g2d_neighbors:Array<GSPHNeighbor>;
	private var g2d_neighborPrecacheCount:Int;
	private var g2d_groups:Map<GParticleGroup,Bool>;
	private var g2d_defaultGroup:GParticleGroup;
	
    public function new() {
        g2d_emitters = new Array<GParticleEmitter>();
		g2d_groups = new Map<GParticleGroup,Bool>();
		g2d_defaultGroup = new GParticleGroup();
    }
	
	public function setupGrid(p_region:GRectangle, p_cellSize:Int, p_precacheNeighbors:Int = 0):Void {
		g2d_neighbors = new Array<GSPHNeighbor>();
		g2d_neighborPrecacheCount = p_precacheNeighbors;
		for (i in 0...g2d_neighborPrecacheCount) g2d_neighbors.push(new GSPHNeighbor());
        g2d_neighborCount = 0;
		
		g2d_width = p_region.width;
		g2d_height = p_region.height;
		g2d_gridCellSize = p_cellSize;
		g2d_gridWidthCount = Math.ceil(p_region.width / g2d_gridCellSize);
		g2d_gridHeightCount = Math.ceil(p_region.height / g2d_gridCellSize);
		
		g2d_invertedGridCellSize = 1 / g2d_gridCellSize;
		
		g2d_grids = new Array<Array<GSPHGrid>>();
        for (i in 0...g2d_gridWidthCount) {
            g2d_grids.push(new Array<GSPHGrid>());
            for (j in 0...g2d_gridHeightCount) {
                g2d_grids[i].push(new GSPHGrid());
			}
        }
	}
	
	public function addEmitter(p_emitter:GParticleEmitter):Void {
		p_emitter.g2d_particleSystem = this;
		g2d_emitterCount = g2d_emitters.push(p_emitter);
	}
	
	public function removeEmitter(p_emitter:GParticleEmitter):Void {
		if (g2d_emitters.remove(p_emitter)) {
			p_emitter.g2d_particleSystem = null;
			g2d_emitterCount--;
		}
	}
	
	public function getEmitter(p_emitterIndex:Int):GParticleEmitter {
		return (p_emitterIndex < g2d_emitterCount) ? g2d_emitters[p_emitterIndex] : null;
	}

    public function update(p_deltaTime:Float):Void {
		if (enabled) {
			p_deltaTime *= timeDilation;
			
			if (enableSph && g2d_neighbors != null) {
				g2d_updateGrids();
				g2d_findNeighbors();
				
				// Iterating only used neighbors the actual array can be precached for more neighbors
				for (i in 0...g2d_neighborCount) {
					g2d_neighbors[i].calculateForce();
				}
				/**/
				g2d_defaultGroup.calculateForce();
				for (group in g2d_groups.keys()) {
					group.calculateForce();
				}
			}
			
			for (emitter in g2d_emitters) {
				emitter.update(p_deltaTime);
			}
		}
    }
	
	public function render(p_context:IGContext):Void {
		for (emitter in g2d_emitters) {
			emitter.render(p_context);
		}
	}
    
    public function dispose():Void {
    }
	
	/**
	 * 	Smoothed Particle Hydrodynamics spatial grid lookup
	 */
	
	private function g2d_updateGrids():Void {
        for (i in 0...g2d_gridWidthCount) {
            for(j in 0...g2d_gridHeightCount) {
                g2d_grids[i][j].particleCount = 0;
			}
		}
		
		g2d_defaultGroup.particleCount = 0;
		g2d_defaultGroup.massX = 0;
		g2d_defaultGroup.massY = 0;
		for (group in g2d_groups.keys()) {
			group.particleCount = 0;
			group.massX = 0;
			group.massY = 0;
		}
		
        for (emitter in g2d_emitters) {
			if (emitter.enableSph) {
				var particle:GParticle = emitter.g2d_firstParticle;
				while (particle != null) {
					var next:GParticle = particle.g2d_next;
					if (particle.group != null) {
						particle.group.addParticle(particle);
						g2d_groups.set(particle.group, true);
					} else {
						g2d_defaultGroup.addParticle(particle);
					}
					
					particle.fluidX = particle.fluidY = particle.density = particle.densityNear = 0;
					particle.gridX = Std.int(particle.x * g2d_invertedGridCellSize);
					particle.gridY = Std.int(particle.y * g2d_invertedGridCellSize);
					if (particle.gridX < 0) {
						particle.gridX = 0;
					} else if (particle.gridX > g2d_gridWidthCount - 1) {
						particle.gridX = g2d_gridWidthCount - 1;
					}
					if (particle.gridY < 0) {
						particle.gridY = 0;
					} else if (particle.gridY > g2d_gridHeightCount - 1) {
						particle.gridY = g2d_gridHeightCount - 1;
					}
					particle = next;
				}
			}
        }
    }
	
	private function g2d_findNeighbors():Void {
		g2d_neighborCount = 0;
		for (emitter in g2d_emitters) {
			if (emitter.enableSph) {
				var particle:GParticle = emitter.g2d_firstParticle;
				while (particle != null) {
					// Ignore dead particles
					if (!particle.die) {
						var minX:Bool = particle.gridX != 0;
						var maxX:Bool = particle.gridX != g2d_gridWidthCount - 1;
						var minY:Bool = particle.gridY != 0;
						var maxY:Bool = particle.gridY != g2d_gridHeightCount - 1;
						g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX][particle.gridY]);
						if (minX) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX - 1][particle.gridY]);
						if (maxX) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX + 1][particle.gridY]);
						if (minY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX][particle.gridY - 1]);
						if (maxY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX][particle.gridY + 1]);
						if (minX && minY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX - 1][particle.gridY - 1]);
						if (minX && maxY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX - 1][particle.gridY + 1]);
						if (maxX && minY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX + 1][particle.gridY - 1]);
						if (maxX && maxY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gridX + 1][particle.gridY + 1]);
						// Add particle to the grid, we avoid two way neighboring
						g2d_grids[particle.gridX][particle.gridY].addParticle(particle);
					}
					particle = particle.g2d_next;
				}
			}
        }
	}

    inline private function g2d_findNeighborsInGrid(p_particle1:GParticle, p_grid:GSPHGrid):Void {
        for (i in 0...p_grid.particleCount) {
			var particle:GParticle = p_grid.particles[i];
			var distance:Float = (p_particle1.x - particle.x) * (p_particle1.x - particle.x) + (p_particle1.y - particle.y) * (p_particle1.y - particle.y);
			if (distance < RANGE2) {
				// If we are outside of neighbor cache
				if(g2d_neighborPrecacheCount == g2d_neighborCount) {
					g2d_neighbors[g2d_neighborCount] = new GSPHNeighbor();
					g2d_neighborPrecacheCount++;
				} 

				g2d_neighbors[g2d_neighborCount++].setParticles(p_particle1, particle);				
			}
        }
    }
}

class GSPHNeighbor
{
	public var RANGE:Float = GParticleSystem.RANGE;
    public var PRESSURE:Float = GParticleSystem.PRESSURE;
    public var NEAR_PRESSURE:Float = GParticleSystem.NEAR_PRESSURE;
	
	public var particle1:GParticle;
    public var particle2:GParticle;
    public var nx:Float;
    public var ny:Float;
    public var weight:Float;
    public var density:Float = 2;
	public var distance:Float;
	
    inline public function new() {
    }

    inline public function setParticles(p_particle1:GParticle, p_particle2:GParticle):Void {
        particle1 = p_particle1;
        particle2 = p_particle2;

        nx = particle1.x - particle2.x;
        ny = particle1.y - particle2.y;
        distance = Math.sqrt(nx * nx + ny * ny);
        nx /= distance;
        ny /= distance;
		
        weight = 1 - distance / RANGE;
        var density:Float = weight * weight;
        particle1.density += density;
        particle2.density += density;
        density *= weight * NEAR_PRESSURE;
        particle1.densityNear += density;
        particle2.densityNear += density;
    }

    inline public function calculateForce():Void {
        var p:Float;
		if (particle1.group != particle2.group || particle1.group == null) {
			if (particle1.type != particle2.type || particle1.fixed != particle2.fixed || particle1.group != particle2.group) {
				p = (particle1.density + particle2.density - density * 1.5) * PRESSURE;
			} else {
				p = (particle1.density + particle2.density - density * 2) * PRESSURE;
			}

			var np:Float = (particle1.densityNear + particle2.densityNear) * NEAR_PRESSURE;
			var pressureWeight:Float = weight * (p + weight * np);
			var fx:Float = nx * pressureWeight;
			var fy:Float = ny * pressureWeight;
			var fax:Float = (particle2.velocityX - particle1.velocityX) * weight;
			var fay:Float = (particle2.velocityY - particle1.velocityY) * weight;
			// Add some delta to avoid possible unnatural direct axis simulation
			if (fx == 0) fx += .0000001;
			if (fy == 0) fy += .0000001;
			
			particle1.fluidX += fx + fax * particle2.viscosity;
			particle1.fluidY += fy + fay * particle2.viscosity;
			particle2.fluidX -= fx + fax * particle1.viscosity;
			particle2.fluidY -= fy + fay * particle1.viscosity;
			/**/
		}
    }
}

class GSPHGrid {
    public var particles:Array<GParticle>;
    public var particleCount:UInt = 0;
	
    public function new() {
        particles = new Array<GParticle>();
    }

    inline public function addParticle(p_particle:GParticle):Void {
        particles[particleCount++] = p_particle;
    }
}