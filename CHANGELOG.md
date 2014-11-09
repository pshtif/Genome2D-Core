Genome2D Changelog
===================

WIP
--------------------------
- CHECK hierarchical AABB masking for nonconsecutively masked hierarchy

- CHANGED GTileMap setTiles p_tiles argument is now optional and it will generate null map for you
- CHANGED GTileMap setTile will now set multi tile size tiles to all their indices automatically
- CHANGED IContext begin call now returns boolean which indicates that context was able to start rendering (no context loss)
- CHANGED GContextCamera renamed to GCamera
- CHANGED moved GScreenManager functionality to GCamera as viewport, can be also set through GCameraController setViewport.
- CHANGED some of the util classes moved to the common repository
- ADDED prototypable support for inheritance chain variables and properties
- ADDED support for mouse signal in GTileMap
- ADDED contextSignal property to GNodeMouseSignal to reference the original context mouse signal
- ADDED onPlaybackEnd signal for GMovieClip to dispatch when nonrepeatable movieclip animation ends
- FIXED incorrect calculation of UV coordinates using different scalefactors
- FIXED setting a camera will set scissoring even for fullscreen as there seem to be Stage3D bug when using null
- FIXED crash when trying to calculate animated frame for GTile reentering viewport from outside while having reversed playback
- FIXED minor changes to context loss handling and pipeline propagation fixing problems with context loss in some cases (GShape, drawPoly etc.)

version 1.0.279 - 2014-10-19
--------------------------

- ADDED support for content scale factor, now all texture factory methods contain scale factor parameter
- ADDED GScreenManager component for easy management of virtual screens
- ADDED GSimpleParticle now contains texture information which enables GSimpleParticleSystem to force burst particles with different textures
- CHANGED moved all classes that are not components out of the com.genome2d.components package to their own packages
- CHANGED GTextureText was now divided to GTextureTextRenderer which handles the actual rendering and GText which is a component managing it, this way you can render such text even without using node/component system (further changes still coming)

version 1.0.277 - 2014-09-15
--------------------------

- ADDED support for pivots in drawSource calls
- ADDED support for rendering specific camera in Genome2D render call, used for multilayering 3rd party frameworks
- ADDED support for nested render to texture calls
- ADDED post processes can now be used hierarchically and nested within each other
- ADDED GTiledSprite, GSlice3Sprite, GSlice9Sprite renderable components

- FIXED problem with camera invalidation in some cases, for example with usage of 3rd party frameworks
- FIXED GTexture gpuWidth/Height now correctly invalidates when changing region
- FIXED batching now correctly works with consequent drawSource call on same texture with different source rectangle

version 1.0.274 - 2014-08-16
--------------------------

- FIXED stats no longer move with camera if you are using custom camera
- FIXED GMouseSignal buttonDown and ctrlKey now contain correct information
- FIXED getTextureById/getTextureAtlasById/getTextureFontAtlas now no longer throw error when called before any texture was created inside Genome2D
- CHANGED textureId setter will now throw error if the texture doesn't exist
- CHANGED GFontTextureAtlas renamed to GTextureFontAtlas
- CHANGED getTextureFontAtlas is now correctly static method of GTextureFontAtlas instead of GTextureAtlas
- ADDED reversed property to GMovieClip for reversed playback
- ADDED texture property to GTile
- ADDED roration property to GTile
- ADDED vertical/horizontal margin to GTileMap visibility culling
- ADDED GTile support for animations with all the methods similar to GMovieClip
- ADDED GTile now supports multitile graphics
- ADDED Genome2D getRunTime to return time elapsed from start of Genome2D
- REMOVED setTileSize method as its redundant
- REMOVED GTextureAtlas createFromFont method
- UPDATED AGALMiniAssembler to the latest version

- KNOWN ISSUE tiles with multitile graphics will not render to multiple cameras

version 1.0.271 - 2014-07-31
--------------------------

- CHANGED approach to setting scissors due to a bug in Stage3D which I will investigate and report to Adobe hopefully. This bug resolves in unexpectedly masked output to render textures in previous Genome2D builds in some cases.
- FIXED texture repeatable property now correctly changes batchable state for all draw methods

version 1.0.268 - 2014-07-28
--------------------------

- FIXED prototype macro to exclude String from IPrototypable chain
- FIXED GNode dispose now correctly disposes and removes all signals
- ADDED GNode isDisposed method
- ADDED prototype creation now checks if you are sending correct node XML
- ADDED GTextureText is now prototypable
- ADDED GSimpleParticleSystem is now prototypable
- ADDED GParticleSystem dispose method
- CHANGED GParticleSystem update method is now public

version 1.0.263 - 2014-06-30
--------------------------

- ADDED setBackgroundColor method to Genome2D context
- ADDED GFontTextureAtlas and GCharTexture texture types to support correct font rendering with additional texture information
- ADDED GTextureTextHAlign and GTextureTextVAlign instead of GTextureTextAlign to support both vertical and horizontal alignments for GTextureText
- CHANGED GTextureText to use completely different implementation for font rendering it no longer generates glyphs as nodes but uses internal structures for better performance additionally to supporting all the new features as aligns, offseting and kerning.
- CHANGED GTextureAtlasFactory methods createFromBitmapDataAndFontXml and createFontFromAssets to use the new font specific texture atlases
- CHANGED component dispose method is now internal g2d_dispose which calls abstract public dispose that can be overriden by user 
- FIXED renderable component no longer renders after removeComponent call

version 1.0.262 - 2014-06-22
--------------------------

- CHANGED simplified node factory, removed optional arguments such as name
- CHANGED GComponent constructor no longer expects node argument
- CHANGED each component after initialization now calls init method
- CHANGED prototype methods now getPrototype,initPrototype
- CHANGED internals of handling prototype reflection
- CHANGED GContextConfig no longer requires viewRect argument to be set, when null it will initialize to stage size
- CHANGED filters bind/clear argument is now Genome2D context instance instead of native context instance for more modularity
- ADDED correct mouse processing for GTextureText
- ADDED getBounds for GTextureText
- ADDED getSubTextures method to GTextureAtlas taking regular expression as parameter for ID lookup, if not specified it will return all sub textures.

version 1.0.256 - 2014-06-02
--------------------------

- FIX AS3 texture classes and factories to work with repeatable
- FIX GFlashObject now correctly disposes update callback
- CHANGED refactored all low level materials to renderers, cleaned up IGRenderer
- CHANGED GSimpleShape is now GShape, further changes coming for shape rendering caching
- ADDED useSeparateAlphaPipeline in GContextConfig to enable/disable using of separate batching of alpha/tinted sprites
- ADDED useFastMem to GContextConfig to enable/disable using fast memory access and bytearray uploads to GPU instead of vectors
- ADDED bindRenderer method to bind custom renderer into Genome2D pipeline viz DevCast #2 https://www.youtube.com/watch?v=XvH6g6h6JRQ
- ADDED renderTarget property for GCameraController now enables you to render custom cameras into a texture instead of screen
- ADDED filters such as GBloomPassFilter, GBlurPassFilter, GBrightPassFilter, GColorMatrixFilter, GHDRPassFilter (they will be removed from core swc later and added as sources in extension to not bloat the library)
- ADDED postprocesses such as GBloomPP, GBlurPP, GFilterPP, GHDRPP (some of them will be removed from core and added as extensions)

version 1.0.255 - 2014-05-19
--------------------------

- FIX GContextTexture dispose now works correctly and disposes GPU native texture this bug affected all textures in Genome2D

version 1.0.253 - 2014-05-15
--------------------------

- GNode getBounds now fixed to work with linked lists (Thanks for the spot vaukalak)
- GFilter fix removed constant binding if there are no custom constants
- GNode added firstChild/nextNode getters
- Always use RectangleTextures where possible if we are not in constrained profile.
- GNode add/removeComponent fix, now adding a component after removing one should no longer end in exception
- When using the new Standard profile all shaders will be initialized and compiled using AGAL2
- New low level context method setRenderTargets
- New low level context method setDepthTest which will correctly flush batching compared to usage of native context directly

version 1.0.250 - 2014-04-26
--------------------------

- FIXED drawPoly (GSimpleShape) now supports alpha and color transformations
- FIXED GNode mask now has correct setter

version 1.0.249 - 2014-03-22
--------------------------

- FIXED context resize now doesn't invalidate in middle of context loss
- FIXED context drawPoly (GSimpleShape) batching increased to 1200
- FIXED GSimpleParticleSystem dispose
- FIXED GNodeMouseSignal localX/Y now really report dispatcher node local coordinates instead of texture coordinates
- ADDED child manipulation methods
- ADDED GTextureQuad hitTestPoint
- ADDED GSimpleParticleSystem useWorldSpace

version 1.0.247 - 2014-03-14
--------------------------

- ADDED GContextFeature enum
- ADDED renderToColor, renderToStencil, clearStencil context methods
- ADDED stencil masking GNode mask
- ADDED GNode setActive
- ADDED error when textures have 0 size region
- ADDED contextCamera getter to the GCameraController
- FIXED unknown copy method for flash target in texture packing

version 1.0.244 - 2014-03-07
--------------------------

- FIXED incorrect bitmap invalidation when used GStage3DContext
- FIXED dxt1/dxt5 shader mapping for bitmapdata/bytearray uploaded with custom compressed format
- CHANGED reduced memory allocations/deallocations on low level context shaders and materials
- ADDED onInvalidated signal that is dispatched each time backbuffer is invalidated (context restore, antialias, backbuffer size change...)
- ADDED onFailed signal now dispatches with a reason string
- ADDED dispose check during context texture reinitialization to skip invalidation during context loss
- ADDED error descriptions in various places
- ADDED GNode removeChildAt, setChildIndex, swapChildrenAt

version 1.0.239 - 2014-03-02
--------------------------

- DLL used for children
- added methods putChildToFront, putChildToBack
- added sortOnUserData
- fixed ATF in creation in GTextureFactory
- fixed enableDepthAndStecil config
- added support for externalStage3D
- Genome2D.enabled renamed to autoUpdateAndRender
- added support for enableNativeContentMouseCapture
- GContextTexture premultipled,nativeTexture and atfType now public to offer an option to change however Genome2D should set this for you depending on the source
- new parameter format for all texture factories, will be ignored for ATF textures
- GStats customStats fixed, now String array and always in a single line

version 1.0.238 - 2014-02-21
--------------------------

- ATF support, GTextureFactory/GTextureAtlasFactory AFT create methods
- first version of GBitmapContext software fallback, limitations
- IStats for an option to use custom stats config.statsClass
- default GStats changes controlled purely through static properties, GStats.visible for example
- stats now render using GPU in Stage3D context
- fixed the missing AGALMiniAssember SWC linkage, you no longer need to have the class
- further refactor, cleanup of unused or misplaced API, first documentation draft

version 1.0.237 - 2014-02-14
--------------------------

- GMovieClip setTextureFrames method refactored to frameTextures setter to corelate more with existing other APIs
- GMovieClip frameTextures setter to allow directly setting textures without the ID lookup
- New context low level draw method drawMatrixSource similar to drawSource which enables you to override texture source rectangle when drawing using matrix
- more cleanup and refactoring of internal methods

VERSIONS BEFORE 2014-02-14
--------------------------

Genome2D is already over 4 years in development and past this date it went from AS3 to Haxe so I am no longer listing it.  