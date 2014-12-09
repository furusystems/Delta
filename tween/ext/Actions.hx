package tween.ext;

import tween.tweens.IndexTween;
import tween.tweens.PropertyTween;
import tween.tweens.FuncTween;

@:build(tween.actions.Inject.apply())
class Actions {

    @:TweenAction
    public function index(index:Int, value:Float, duration:Float):TweenAction {
        if(properties==null) properties = new Map();
        totalDuration = Math.max(totalDuration, duration);
        properties.set(Std.string(index), prevPropCreated = new IndexTween(this, index, value, duration));
        return this;
    }

    @:TweenAction
    public function func(property:String, value:Float, duration:Float, g:FTGetFunc, s:FTSetFunc):TweenAction {
        if(properties==null) properties = new Map();
        totalDuration = Math.max(totalDuration, duration);
        properties.set(property, prevPropCreated = new FuncTween(this, property, value, duration, g, s));
        return this;
    }


}
