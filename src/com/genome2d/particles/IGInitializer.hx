/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.particles;

import com.genome2d.components.renderables.particles.GParticleSystem;

/**
    Interface providing method for `GParticleSystem` particle initialization
**/
interface IGInitializer {

    /**
        Initialize `p_particle` inside `p_system`
     **/
    function initialize(p_system:GParticleSystem, p_particle:GParticle):Void;
}