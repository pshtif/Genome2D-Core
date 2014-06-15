/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.components.renderables.particles;

/**
    Interface providing method for `GParticleSystem` particle update
**/
interface IGAffector {

    /**
        Update `p_particle` inside `p_system` by `p_deltaTime`
    **/
    function update(p_system:GParticleSystem, p_particle:GParticle, p_deltaTime:Float):Void;
}