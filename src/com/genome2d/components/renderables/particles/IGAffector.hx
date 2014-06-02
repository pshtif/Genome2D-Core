package com.genome2d.components.renderables.particles;

/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
interface IGAffector {
    function update(p_system:GParticleSystem, p_particle:GParticle, p_deltaTime:Float):Void;
}