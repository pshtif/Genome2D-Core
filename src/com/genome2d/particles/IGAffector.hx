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
    Interface providing method for `GParticleSystem` particle update
**/
interface IGAffector {

    /**
        Update `p_particle` inside `p_system` by `p_deltaTime`
    **/
    function update(p_system:GParticleSystem, p_particle:GParticle, p_deltaTime:Float):Void;
}