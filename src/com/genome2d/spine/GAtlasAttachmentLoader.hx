/**
 * Created with IntelliJ IDEA.
 * User: sHTiF
 * Date: 17.5.2013
 * Time: 12:37
 * To change this template use File | Settings | File Templates.
 */
package com.genome2d.spine;

import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;

import spine.Bone;
import spine.Skin;
import spine.atlas.Atlas;
import spine.attachments.AtlasAttachmentLoader;
import spine.attachments.Attachment;

import spine.attachments.AttachmentLoader;
import spine.attachments.AttachmentType;
import spine.attachments.BoundingBoxAttachment;
import spine.attachments.MeshAttachment;
import spine.attachments.RegionAttachment;
import spine.attachments.SkinnedMeshAttachment;

class GAtlasAttachmentLoader implements AttachmentLoader {
    private var g2d_atlas:Atlas;
    public function new(p_atlas:Atlas) {
        g2d_atlas = p_atlas;

        Bone.yDown = true;
    }

    public function newRegionAttachment(p_skin:Skin, p_name:String, p_path:String) : RegionAttachment {
        var regionAttachment:RegionAttachment = new RegionAttachment(p_name);

        //var texture:GTexture = GTextureManager.getTexture(g2d_atlasPrefix+"_"+p_name);
        var texture:GTexture = cast g2d_atlas.findRegion(p_name).rendererObject;
        regionAttachment.rendererObject = texture;
        regionAttachment.regionOffsetX = texture.pivotX * texture.width;
        regionAttachment.regionOffsetY = texture.pivotY * texture.height;
        regionAttachment.regionWidth = texture.width;
        regionAttachment.regionHeight = texture.height;
        regionAttachment.regionOriginalWidth = texture.width;
        regionAttachment.regionOriginalHeight = texture.height;
        return regionAttachment;
    }

    /** @return May be null to not load an attachment. */
    public function newMeshAttachment(skin:Skin, name:String, path:String) : MeshAttachment {
        return null;
    }

    /** @return May be null to not load an attachment. */
    public function newSkinnedMeshAttachment (skin:Skin, name:String, path:String) : SkinnedMeshAttachment {
        return null;
    }

    /** @return May be null to not load an attachment. */
    public function newBoundingBoxAttachment (skin:Skin, name:String) : BoundingBoxAttachment {
        return null;
    }
}
