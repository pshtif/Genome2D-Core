/**
 * Created by pstefcek on 15. 5. 2015.
 */
package com.genome2d.spine;

import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;

import com.spine.atlas.AtlasPage;
import com.spine.atlas.AtlasRegion;

import com.spine.atlas.TextureLoader;

class GAtlasTextureLoader implements TextureLoader {
    private var _texture:GTexture;

    public function new(p_texture:GTexture) {
		_texture = p_texture;
    }

    public function loadPage(page:AtlasPage, path:String) : Void {
        page.rendererObject = _texture;
        page.width = Std.int(_texture.width);
        page.height = Std.int(_texture.height);
    }
	
    public function loadRegion(region:AtlasRegion) : Void {
        //var id:String = (region.page.name == region.name) ? region.name : region.page.name+"_" + region.name;
		var atlas:GTexture = cast region.page.rendererObject;
        var texture:GTexture = GTextureManager.getTexture(atlas.id+"_"+region.name);
        if (texture == null) {
			texture = GTextureManager.createSubTexture(region.name, atlas, new GRectangle(region.x, region.y, region.rotate?region.height:region.width, region.rotate?region.width:region.height), new GRectangle(region.offsetX, region.offsetY, region.rotate?region.originalHeight:region.originalWidth, region.rotate?region.originalWidth:region.originalHeight));
			texture.rotate = region.rotate;
		}

        region.rendererObject = texture;
    }

    public function unloadPage (page:AtlasPage) : Void {
        (page.rendererObject).dispose();
    }

    public function dispose():Void {
    }
}
