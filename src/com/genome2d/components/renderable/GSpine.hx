/**
 * Created with IntelliJ IDEA.
 * User: Peter "sHTiF" Stefcek
 * Date: 17.5.2013
 * Time: 14:03
 * To change this template use File | Settings | File Templates.
 */
package com.genome2d.components.renderable;

import com.genome2d.Genome2D;
import com.genome2d.components.GComponent;
import com.genome2d.components.renderable.IGRenderable;
import com.genome2d.context.GCamera;
import com.genome2d.context.IGContext;
import com.genome2d.input.GMouseInput;
import com.genome2d.spine.GAtlasAttachmentLoader;
import com.genome2d.spine.GAtlasTextureLoader;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GRectangle;
import haxe.ds.Vector;

import spine.Bone;
import spine.Skeleton;
import spine.SkeletonData;
import spine.SkeletonJson;
import spine.Slot;
import spine.animation.AnimationState;
import spine.animation.AnimationStateData;
import spine.atlas.Atlas;
import spine.attachments.RegionAttachment;

class GSpine extends GComponent implements IGRenderable
{
    private var _attachmentLoader:GAtlasAttachmentLoader;
    private var _atlasLoader:GAtlasTextureLoader;

    private var _states:Map<String,AnimationState>;
    private var _activeState:AnimationState;

    private var _skeletons:Map<String,Skeleton>;
    private var _activeSkeleton:Skeleton;

    override public function init():Void {
        _skeletons = new Map<String,Skeleton>();
        _states = new Map<String,AnimationState>();

        node.core.onUpdate.add(update);
    }

    public function setup(p_atlas:String, p_texture:GTexture, p_defaultAnim:String = "stand"):Void {
        _atlasLoader = new GAtlasTextureLoader(p_texture);
        var atlas:Atlas = new Atlas(p_atlas, _atlasLoader);
        _attachmentLoader = new GAtlasAttachmentLoader(atlas);
    }

    public function setAttachment(p_slotName:String, p_attachmentName:String):Void {
        for (skeleton in _skeletons) {
            skeleton.setAttachment(p_slotName, p_attachmentName);
        }
    }

    public function setSkin(p_skinName:String):Void {
        for (skeleton in _skeletons) {
            skeleton.skinName = p_skinName;
        }
    }

    public function addSkeleton(p_id:String, p_json:String):Void {
        var json:SkeletonJson = new SkeletonJson(_attachmentLoader);
        var skeletonData:SkeletonData = json.readSkeletonData(p_json);
        var skeleton:Skeleton = new Skeleton(skeletonData);
        skeleton.updateWorldTransform();
        _skeletons.set(p_id, skeleton);

        var stateData:AnimationStateData = new AnimationStateData(skeletonData);
        var state:AnimationState = new AnimationState(stateData);
        _states.set(p_id, state);
    }

    public function setActiveSkeleton(p_skeletonId:String, p_anim:String):Void {
        if (_skeletons.get(p_skeletonId) != null && _activeSkeleton != _skeletons.get(p_skeletonId)) {
            _activeSkeleton = _skeletons.get(p_skeletonId);
            _activeState = _states.get(p_skeletonId);
            _activeState.setAnimationByName(0, p_anim, true);
            _activeState.update(Math.random());
        }
    }

    public function update(p_deltaTime:Float):Void {
        if (_activeState != null) {
            _activeState.update(p_deltaTime / 1000);
            _activeState.apply(_activeSkeleton);
            _activeSkeleton.updateWorldTransform();
        }
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        var rotate:Bool = (node.g2d_worldRotation != 0);
        var sx:Float = node.g2d_worldScaleX;
        var sy:Float = node.g2d_worldScaleY;
        var fx:Float = -sx*sy/Math.abs(sx*sy);
        var cos:Float = Math.cos(node.g2d_worldRotation);
        var sin:Float = Math.sin(node.g2d_worldRotation);

        var context:IGContext = Genome2D.getInstance().getContext();

        if (_activeSkeleton != null) {
            var drawOrder:Array<Slot> = _activeSkeleton.drawOrder;
            for (i in 0...drawOrder.length) {
                var slot:Slot = drawOrder[i];
//				trace(slot.attachment);
                var regionAttachment:RegionAttachment = cast slot.attachment;
                if (regionAttachment != null) {
                    var bone:Bone = slot.bone;

                    // CHECK NA VISIBILITY BONEU
                    //if (bone.hidden) continue;

                    var tx:Float = bone.worldX + regionAttachment.x * bone.m00 + regionAttachment.y * bone.m01;
                    var ty:Float = bone.worldY + regionAttachment.x * bone.m10 + regionAttachment.y * bone.m11;
                    //trace('drawing bone', bone.data.name, bone.worldX, bone.worldY, 'region Attachment', regionAttachment.x, regionAttachment.regionOffsetX, regionAttachment.y, regionAttachment.regionOffsetY);
                    var tr:Float = fx * (bone.worldRotation + regionAttachment.rotation) * Math.PI / 180;
                    var tsx:Float = bone.worldScaleX + regionAttachment.scaleX - 1;
                    var tsy:Float = bone.worldScaleY + regionAttachment.scaleY - 1;

                    if (rotate) {
                        var tx2:Float = tx;
                        tx = tx * cos - ty * sin;
                        ty = tx2 * sin + ty * cos;
                    }

                    var texture:GTexture = cast regionAttachment.rendererObject;
					if (texture.rotate) tr += Math.PI / 2;
                    context.draw(regionAttachment.rendererObject, tx * sx + node.g2d_worldX, ty * sy + node.g2d_worldY, tsx * sx, tsy * sy, (tr - fx * node.g2d_worldRotation), node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha);
                }
            }
        }
    }
	
    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        if (p_bounds != null) p_bounds.setTo(-60, -60, 100, 60);
        else p_bounds = new GRectangle(-60,-60,100,60);
        return p_bounds;
    }

    public function captureMouseInput(p_input:GMouseInput):Void {
        p_input.g2d_captured = p_input.g2d_captured || hitTest(p_input.localX, p_input.localY);
    }

    public function hitTest(p_x:Float,p_y:Float):Bool {
        var hit:Bool = false;
        var width:Int = 60;
        var height:Int = 70;

        p_x = p_x / width + .5;
        p_y = p_y / height + .95;

        hit = (p_x >= 0 && p_x <= 1 && p_y >= 0 && p_y <= 1);

        return hit;
    }

    override public function dispose():Void {
        node.core.onUpdate.remove(update);

        // pridal som if na _atlasLoader, lebo mi to tu padlo, ked som v tutorial bani talkol npc lindy a pocas miznutia
        // som sa prepol do campu
        if (_atlasLoader != null) {
            _atlasLoader.dispose();
        }
    }
}