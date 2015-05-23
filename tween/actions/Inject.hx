package tween.actions;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class Inject {

    static var inject_list : Array<Field> = [];

        //This function triggers builds on tween.ext.* Types,
        //stores their @:tweenAction functions into inject_list,
        //and injects them into TweenAction (or whichever this macro is applied),
        //allowing code from external library to be injected as a tween feature
        //directly without having to modify the core code. for example:
        // Delta.tween( pos ).vec({ x:Float, y:Float, z:Float }, time:Float)
        // - where vec is the custom, strongly typed, third party specific tween
        //   code that seamlessly ties into the other tween actions
    macro function init() : Array<Field> {

        var fields = Context.getBuildFields();
        var paths = Context.getClassPath();

            for(cp in paths) {
                cp = Path.normalize(cp);

                if( !sys.FileSystem.exists(cp) || !sys.FileSystem.isDirectory(cp) )
                    continue;

                var ext = Path.join([cp, 'tween','actions']);
                if(sys.FileSystem.exists(ext) && sys.FileSystem.isDirectory(ext)) {
                    for( file in sys.FileSystem.readDirectory(ext) ) {
                        if( StringTools.endsWith(file, ".hx") ) {
                            var cl = file.substr(0, file.length - 3);
                                cl = Path.join([ext, cl]);
                                cl = cl.substr( cp.length, cl.length );
                                cl = cl.split('/').join('.');
								if (cl.charAt(0) == ".") 
									cl = cl.substring(1); 
                            var type = Context.getType(cl);
                        } //haxe file
                    } //each file
                } //is directory
            } //each class path

        fields = fields.concat(inject_list);

        return fields;

    } //apply

    macro function apply() : Array<Field> {

        var fields = Context.getBuildFields();
        var final = [];

        for( field in fields ) {
            var skip = false;
            for(meta in field.meta) {
                if(meta.name == ':tweenAction') {
                    inject_list.push(field);
                } else {
                    final.push(field);
                }
            }
        }

        return final;

    } //strip

}