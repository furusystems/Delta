package tween.tweens;
import tween.Delta;

/**
 * ...
 * @author Andreas Rønning
 * @author Sven Bergström
 */

class FloatTween implements Tweenable {

    public var tween:TweenAction;
    public var duration:Float;
    public var durationR:Float;
    public var time:Float;
    public var isProperty:Bool;
    public var from:Float;
    public var to:Float;
    public var difference:Float;
    public var current:Float;
    public var tweenFunc:TweenFunc;
    public var complete:Bool;
    public var name:String;

    @:noCompletion
    public var hasUpdated:Bool;

    #if release inline #end
    public function new(tween:TweenAction, name:String, to:Float, duration:Float) {
        tweenFunc = Delta.defaultTweenFunc;
        this.duration = duration;
        this.durationR = 1 / duration;
        this.tween = tween;
        this.to = to;
        this.name = name;
        time = 0.0;
    }

    #if release inline #end
    function init(from:Float) {
        if(!hasUpdated){
            this.from = from;
            difference = to - from;
            hasUpdated = true;
        }
    }

    #if release inline #end
    public function step(delta:Float)
    {
        time += delta;
        var c = current;
        if (time > duration) {
            time = duration;
            c = from + difference;
            complete = true;
        }else {
            var rt = Math.max(0, time);
            c = tweenFunc(from, difference, time * durationR);
        }
        set(c);
    }

    #if release inline #end
    public function set(val:Float)
    {
        if (val != current) {
            apply(current = val);
        }
    }

    #if release inline #end
    public function check()
    {
        init( Reflect.getProperty(tween.target, name) );
    }

    #if release inline #end
    function apply(val:Float)
    {
        Reflect.setProperty(tween.target, name, val);
    }

}