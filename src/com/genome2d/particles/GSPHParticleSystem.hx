/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;
import com.genome2d.geom.GRectangle;

/**
 * Smooth particle hydrodynamics particle system using spatial grid neighbor lookup
 * 
 * Needs SPHModule for simulation
 */
@:access(com.genome2d.particles.GParticle)
@:access(com.genome2d.particles.GParticleEmitter)
class GSPHParticleSystem extends GParticleSystem
{
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
	
	
	public function new(p_region:GRectangle, p_cellSize:Int, p_precacheNeighbors:Int = 0) {
		super();

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
	
	override public function update(p_deltaTime:Float):Void {
		g2d_updateGrids();
		g2d_findNeighbors();
		
		// Iterating only used neighbors the actual array can be precached for more neighbors
		for (i in 0...g2d_neighborCount) {
			g2d_neighbors[i].calculateForce();
        }
		
		super.update(p_deltaTime);
	}
	
	private function g2d_updateGrids():Void {
        for(i in 0...g2d_gridWidthCount) {
            for(j in 0...g2d_gridHeightCount) {
                g2d_grids[i][j].particleCount = 0;
			}
		}
		
        for (emitter in g2d_emitters) {
			var particle:GParticle = emitter.g2d_firstParticle;
			while (particle != null) {
				var next:GParticle = particle.g2d_next;
				particle.fx = particle.fy = particle.density = particle.densityNear = 0;
				particle.gx = Std.int(particle.x * g2d_invertedGridCellSize);
				particle.gy = Std.int(particle.y * g2d_invertedGridCellSize);
				if (particle.gx < 0) {
					particle.gx = 0;
				} else if (particle.gx > g2d_gridWidthCount - 1) {
					particle.gx = g2d_gridWidthCount - 1;
				}
				if (particle.gy < 0) {
					particle.gy = 0;
				} else if (particle.gy > g2d_gridHeightCount - 1) {
					particle.gy = g2d_gridHeightCount - 1;
				}
				particle = next;
			}
        }
		/**/
    }
	
	private function g2d_findNeighbors():Void {
		g2d_neighborCount = 0;
		for (emitter in g2d_emitters) {
			var particle:GParticle = emitter.g2d_firstParticle;
			while (particle != null) {
				// Ignore dead particles
				if (!particle.die) {
					var minX:Bool = particle.gx != 0;
					var maxX:Bool = particle.gx != g2d_gridWidthCount - 1;
					var minY:Bool = particle.gy != 0;
					var maxY:Bool = particle.gy != g2d_gridHeightCount - 1;
					g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx][particle.gy]);
					if (minX) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx - 1][particle.gy]);
					if (maxX) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx + 1][particle.gy]);
					if (minY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx][particle.gy - 1]);
					if (maxY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx][particle.gy + 1]);
					if (minX && minY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx - 1][particle.gy - 1]);
					if (minX && maxY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx - 1][particle.gy + 1]);
					if (maxX && minY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx + 1][particle.gy - 1]);
					if (maxX && maxY) g2d_findNeighborsInGrid(particle, g2d_grids[particle.gx + 1][particle.gy + 1]);
					// Add particle to the grid, we avoid two way neighboring
					g2d_grids[particle.gx][particle.gy].addParticle(particle);
				}
				particle = particle.g2d_next;
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
	public var RANGE:Float = GSPHParticleSystem.RANGE;
    public var PRESSURE:Float = GSPHParticleSystem.PRESSURE;
    public var NEAR_PRESSURE:Float = GSPHParticleSystem.NEAR_PRESSURE;
	
	public var particle1:GParticle;
    public var particle2:GParticle;
    public var nx:Float;
    public var ny:Float;
    public var weight:Float;
    public var density:Float = 2;
	
    inline public function new() {
    }

    inline public function setParticles(p_particle1:GParticle, p_particle2:GParticle):Void {
        particle1 = p_particle1;
        particle2 = p_particle2;
		
        nx = particle1.x - particle2.x;
        ny = particle1.y - particle2.y;
        var distance:Float = Math.sqrt(nx * nx + ny * ny);
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

        if(particle1.type != particle2.type || particle1.fixed != particle2.fixed) {
            p = (particle1.density + particle2.density - density * 1.5) * PRESSURE;
        } else {
            p = (particle1.density + particle2.density - density * 2) * PRESSURE;
        }
		
        var np:Float = (particle1.densityNear + particle2.densityNear) * NEAR_PRESSURE;
        var pressureWeight:Float = weight * (p + weight * np);
        var fx:Float = nx * pressureWeight;
        var fy:Float = ny * pressureWeight;
		var fax:Float = (particle2.vx - particle1.vx) * weight;
        var fay:Float = (particle2.vy - particle1.vy) * weight;
        particle1.fx += fx + fax * particle2.viscosity;
        particle1.fy += fy + fay * particle2.viscosity;
        particle2.fx -= fx + fax * particle1.viscosity;
        particle2.fy -= fy + fay * particle1.viscosity;
    }
}

class GSPHGrid
{
    public var particles:Array<GParticle>;
    public var particleCount:UInt = 0;
	
    public function new() {
        particles = new Array<GParticle>();
    }

    inline public function addParticle(p_particle:GParticle):Void {
        particles[particleCount++] = p_particle;
    }
}