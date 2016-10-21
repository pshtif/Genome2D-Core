package com.genome2d.globals;

class GParameters {
    private var g2d_parameters:Map<String,Dynamic>;

    public function new() {
        g2d_parameters = new Map<String,Dynamic>();
    }

    public function hasParameter(p_name:String):Bool {
        return g2d_parameters.exists(p_name);
    }

    public function setParameter(p_name:String, p_value:Dynamic):Void {
        g2d_parameters.set(p_name, p_value);
    }

    public function getParameter<T:Dynamic>(p_name:String):T {
        return cast g2d_parameters.get(p_name);
    }

    public function parseParametersString(p_data:String):Void {
        var e:EReg = ~/[\s\r\n]+/gim;

        var lines:Array<String> = p_data.split("\n");
        for (line in lines) {
            line = e.replace(line,"");
            if (line.indexOf("[") != 0) {
                var split:Array<String> = line.split("=");
                if (split.length == 2) {
                    if (split[1].toLowerCase() == "true") {
                        g2d_parameters.set(split[0], true);
                    } else if (split[1].toLowerCase() == "false") {
                        g2d_parameters.set(split[0], false);
                    } else if (!Math.isNaN(Std.parseFloat(split[1]))) {
                        g2d_parameters.set(split[0], Std.parseFloat(split[1]));
                    } else {
                        g2d_parameters.set(split[0], split[1]);
                    }
                }
            }
        }
    }
}
