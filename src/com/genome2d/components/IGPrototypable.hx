package com.genome2d.components;

interface IGPrototypable {
    function getPrototype():Xml;
    function initPrototype(p_xml:Xml):Void;
}