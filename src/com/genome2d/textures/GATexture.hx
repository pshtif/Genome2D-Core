package com.genome2d.textures;

@:forward
abstract GATexture(GTexture) {
	public function new(p_texture:GTexture) {
		this = p_texture;
	}
	
	@:from
	static public function fromString(p_id:String) {
		return new GATexture(GTextureManager.getTextureById(p_id));
	}
}