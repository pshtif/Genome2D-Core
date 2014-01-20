package com.genome2d.components.renderables.particles;

interface IGInitializer {
    function initialize(p_system:GParticleSystem, p_particle:GParticle):Void;
}