package com.genome2d.node;

/**
 * ...
 * @author 
 */
import com.genome2d.node.factory.GNodeFactory;
class GNodePool
{
	private var _cFirst:GNode;
	private var _cLast:GNode;
	
	private var _xPrototype:Xml;
	
	private var _iMaxCount:Int;
	
	private var _iCachedCount:Int = 0;
    public function getCachedCount():Int {
        return _iCachedCount;
    }

	public function new(p_prototype:Xml, p_maxCount:Int = 0, p_precacheCount:Int = 0) {
		_xPrototype = p_prototype;
		_iMaxCount = p_maxCount;
		
		for (i in 0...p_precacheCount) {
			createNew(true);
		}
	}
	
	public function getNext():GNode {
		var node:GNode;

		if (_cFirst == null || _cFirst.isActive()) {
			node = createNew();
		} else {
			node = _cFirst;		
			//node.active = true;
		}

		return node;
	}
	
	/**
	 *	@private
	 */
	public function putToFront(p_node:GNode):Void {
		if (p_node == _cFirst) return;
		
		if (p_node.g2d_poolNext != null) p_node.g2d_poolNext.g2d_poolPrevious = p_node.g2d_poolPrevious;
		if (p_node.g2d_poolPrevious != null) p_node.g2d_poolPrevious.g2d_poolNext = p_node.g2d_poolNext;
		if (p_node == _cLast) _cLast = _cLast.g2d_poolPrevious;
		
		if (_cFirst != null) _cFirst.g2d_poolPrevious = p_node;
		p_node.g2d_poolPrevious = null;
		p_node.g2d_poolNext = _cFirst;
		_cFirst = p_node;
	}
	
	/**
	 *  @private
	 */	
	public function putToBack(p_node:GNode):Void {
		if (p_node == _cLast) return;
		
		if (p_node.g2d_poolNext != null) p_node.g2d_poolNext.g2d_poolPrevious = p_node.g2d_poolPrevious;
		if (p_node.g2d_poolPrevious != null) p_node.g2d_poolPrevious.g2d_poolNext = p_node.g2d_poolNext;
		if (p_node == _cFirst) _cFirst = _cFirst.g2d_poolNext;
			
		if (_cLast != null) _cLast.g2d_poolNext = p_node;
		p_node.g2d_poolPrevious = _cLast;
		p_node.g2d_poolNext = null;
		_cLast = p_node;
	}
	
	private function createNew(p_precache:Bool = false):GNode {
		var node:GNode = null;
		if (_iMaxCount == 0 || _iCachedCount < _iMaxCount) {
			_iCachedCount++;
			node = GNodeFactory.createFromPrototype(_xPrototype);
			//node.setActive(!p_precache);
			node.g2d_pool = this;
			
			if (_cFirst == null) {
				_cFirst = node;
				_cLast = node;
			} else {
				node.g2d_poolPrevious = _cLast;
				_cLast.g2d_poolNext = node;
				_cLast = node;
			}
		}
		
		return node;
	}
	
	public function dispose():Void {
		while (_cFirst != null) {
			var next:GNode = _cFirst.g2d_poolNext;
			_cFirst.dispose();
			_cFirst = next;
		}
	}
}