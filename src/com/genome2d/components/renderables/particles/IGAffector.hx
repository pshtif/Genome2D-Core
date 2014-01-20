package com.genome2d.components.renderables.particles;

interface IGAffector {
    function update(p_system:GParticleSystem, p_particle:GParticle, p_deltaTime:Float):Void;
}