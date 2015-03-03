package tween.actions;

@:build(tween.actions.Inject.apply())
class Actions {

    @:tweenAction
    #if release inline #end
    public function prop(property:String, value:Float, duration:Float):TweenAction {

        #if debug
            // if (!Reflect.hasField(target, property)) throw 'No property "$property" on object';
            //TODO: Check if the field is a property or not and if so, warn
        #end

        return createTween(property, duration, new FloatTween(this, property, value, duration));
    }

    @:tweenAction
    #if release inline #end
    public function propMultiple(tweens:Dynamic, duration:Float):TweenAction {
        for (p in Reflect.fields(tweens)) {
            prop(p, Reflect.getProperty(tweens, p), duration);
        }
        return this;
    }

    @:tweenAction
    public function index(index:Int, value:Float, duration:Float):TweenAction {
        return createTween(Std.string(index), duration, new IndexTween(this, index, value, duration));
    }

    @:tweenAction
    public function func(property:String, value:Float, duration:Float, g:FTGetFunc, s:FTSetFunc):TweenAction {
        return createTween( property, duration, new FuncTween(this, property, value, duration, g, s) );
    }

} //Actions
