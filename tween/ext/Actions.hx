package tween.ext;

import tween.tweens.IndexTween;
import tween.tweens.FuncTween;

@:build(tween.actions.Inject.apply())
class Actions {

    @:TweenAction
    public function index(index:Int, value:Float, duration:Float):TweenAction {
        if(tweens==null) tweens = new Map();
        totalDuration = Math.max(totalDuration, duration);
        tweens.set(Std.string(index), prevCreated = new IndexTween(this, index, value, duration));
        return this;
    }

    @:TweenAction
    public function func(property:String, value:Float, duration:Float, g:FTGetFunc, s:FTSetFunc):TweenAction {
        if(tweens==null) tweens = new Map();
        totalDuration = Math.max(totalDuration, duration);
        tweens.set(property, prevCreated = new FuncTween(this, property, value, duration, g, s));
        return this;
    }


}
