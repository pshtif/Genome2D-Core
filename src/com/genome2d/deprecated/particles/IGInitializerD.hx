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
import com.genome2d.deprecated.particles.GParticleD;

/**
    Interface providing method for `GParticleSystem` particles initialization
**/
interface IGInitializerD {

    /**
        Initialize `p_particle` inside `p_system`
     **/
    function initialize(p_system:GParticleSystemD, p_particle:GParticleD):Void;
}