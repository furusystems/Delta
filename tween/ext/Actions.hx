package tween.ext;

import tween.tweens.IndexTween;
import tween.tweens.FuncTween;

@:build(tween.actions.Inject.apply())
class Actions {

    @:TweenAction
    public function index(index:Int, value:Float, duration:Float):TweenAction {
        return createTween(Std.string(index), duration, new IndexTween(this, index, value, duration));
    }

    @:TweenAction
    public function func(property:String, value:Float, duration:Float, g:FTGetFunc, s:FTSetFunc):TweenAction {
        return createTween( property, duration, new FuncTween(this, property, value, duration, g, s) );
    }


}
