package tween;
import tween.Delta.TweenAction;
import tween.easing.Linear;
import tween.tweens.FloatTween;
import tween.tweens.IndexTween;
import tween.tweens.FuncTween;

/**
 * ...
 * @author Andreas Rønning
 * @author Sven Bergström
 */

typedef TweenFunc = Float->Float->Float->Float;

interface Tweenable {

	public var tween:TweenAction;
	public var complete:Bool;
	public var name:String;
	public var tweenFunc:TweenFunc;
	public var from:Float;
	public var to:Float;

	public function step(delta:Float):Void;
	public function set(val:Float):Void;

	@:allow(TweenAction)
		function check():Void;
	@:allow(TweenAction)
		var hasUpdated:Bool;

} //Tweenable


//@:build(tween.actions.Inject.init())
class TweenAction {

	var prev:Null<TweenAction>;
	var next:Null<TweenAction>;
	var tweens:Null<Map<String, Tweenable>>;
	var time:Float;
	var totalDuration:Float;
	var prevCreated:Null<Tweenable>;
	var triggeringID:Null<String>;
	var triggerID:Null<String>;
	var triggerOnActionComplete:Bool;
	
	var onActionCompleteFunc:Null<Void->Void>;
	var onStepFunc:Null<Float->Void>;
	var channel:TweenChannel;

	public var target:Dynamic;
	public inline function new(target:Dynamic, channel:TweenChannel) {
		time = totalDuration = 0.0;
		this.channel = channel;
		this.target = target;
	}

	function createTween(property:String, duration:Float, tween:Tweenable) {
		if(tweens==null) tweens = new Map();
		totalDuration = Math.max(totalDuration, duration);
    tweens.set(property, prevCreated = tween);
    return this;
	}


	#if release inline #end
	function append(t:TweenAction):TweenAction {
		next = t;
		t.prev = this;
		return t;
	}

	#if release inline #end
	function remove() {
		if (prev != null) {
			prev.next = next;
		}
		if (next != null) {
			next.prev = prev;
		}
	}

	#if release inline #end
	public function onUpdate(func:Float->Void):TweenAction {
		onStepFunc = func;
		return this;
	}
	
	#if release inline #end
	public function onActionComplete(func:Void->Void):TweenAction {
		onActionCompleteFunc = func;
		return this;
  }

	#if release inline #end
	public function onComplete(func:Void->Void):TweenAction {
    trace("Deprecation warning: Please use 'onActionComplete' instead of 'onComplete'");
    return onActionComplete(func);
	}

	#if release inline #end
	public function ease(func:Float->Float->Float->Float, all:Bool = true):TweenAction {
		if (all) {
			if(tweens != null) for (p in tweens) p.tweenFunc = func;
		}else {
			if (prevCreated != null ) prevCreated.tweenFunc = func;
		}
		return this;
	}

	#if release inline #end
	public function wait(duration:Float):TweenAction {
		var step = createAction();
		step.totalDuration = duration;
		return step.createAction();
	}

	#if release inline #end
	public function waitForTrigger(id:String):TweenAction {
		var step = createAction();
		step.triggeringID = id;
		return step.createAction();
	}

	#if release inline #end
	public function trigger(id:String, triggerOnActionComplete:Bool = false):TweenAction {
		this.triggerOnActionComplete = triggerOnActionComplete;
		triggerID = id;
		return this;
	}

	#if release inline #end
	public function createAction():TweenAction {
		return append(new TweenAction(target, channel));
	}

	#if release inline #end
	public function tween(target:Dynamic):TweenAction {
		return append(new TweenAction(target, channel));
	}

	/**
	 * Complete this node's tweens and proceed to the next one
	 */
	public function skip() {
		for (p in tweens) {
			p.set(p.to);
		}
		time = totalDuration;
		finish();
	}

	#if release inline #end
	function finish()
	{
		if (onActionCompleteFunc != null) onActionCompleteFunc();
		if (triggerID != null && triggerOnActionComplete) {
			channel.runTrigger(triggerID);
			triggerID = null;
		}
		remove();
	}

	public function abort():Void {
		getSequence().abort();
	}

	public function getSequence():TweenSequence {
		var n = prev;
		while (n != null) {
			if (n.prev == null) return cast n;
			n = n.prev;
		}
		return null;
	}

	public function step(delta:Float):TweenAction {
		if (totalDuration == -1 || triggeringID != null) return this;
		if (!triggerOnActionComplete && triggerID != null) {
			channel.runTrigger(triggerID);
			triggerID = null;
		}
		var allComplete:Bool = true;
		if (tweens != null) {
			for (p in tweens) {
				if(!p.hasUpdated) p.check();
				p.step(delta);
				if (!p.complete) allComplete = false;
			}
		}
		time += delta;
		if (onStepFunc != null) {
			onStepFunc(time / totalDuration);
		}
		if (time >= totalDuration) {
			finish();
		}
		return this;
	}

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
}

@:allow(tween.Delta)
private class TweenSequence extends TweenAction {
	public var complete:Bool;
	public function new(target:Dynamic, channel:TweenChannel) {
		super(target, channel);
	}
	override public function step(delta:Float):TweenAction {
		if (complete) return this;
		if (next == null) {
			complete = true;
		}else {
			next.step(delta);
		}
		return this;
	}

	public function removeTweensOf(target:Dynamic) {
		var removeList:Array<TweenAction> = [];
		var c = next;
		while (c != null) {
			if (c.target == target) {
				removeList.push(c);
			}
			c = c.next;
		}
		for (t in removeList) {
			t.remove();
		}
	}

	public function runTrigger(t:String) {
		var n = next;
		while (n != null) {
			if (n.triggeringID == t) {
				n.triggeringID = null;
				return;
			}
			n = n.next;
		}
	}

	override public function abort():Void {
		complete = true;
	}

	public function skipCurrent() {
		if (next != null) next.skip();
	}
	public function length():Int {
		var i = 0;
		var n = next;
		while (n != null) {
			i++;
			n = n.next;
		}
		return i;
	}
}

class TweenChannel{
	public var time:Float = 0.0;
	public var timeScale:Float = 1.0;
	public var sequences:Array<TweenSequence> = [];
	var count:Int = 0;
	public inline function new(){ }
	function createSequence(target:Dynamic):TweenSequence {
		var s = new TweenSequence(target, this);
		sequences.push(s);
		return s;
	}

	public function runTrigger(t:String) {
		for (s in sequences) {
			s.runTrigger(t);
		}
	}

	public function tween(target:Dynamic):TweenAction {
		return createSequence(target).createAction();
	}

	public function delayCall(func:Void->Void, interval:Float):TweenAction {
		return createSequence(null).wait(interval).onActionComplete(func);
	}

	public function removeTweensOf(target:Dynamic) {
		for (s in sequences) {
			s.removeTweensOf(target);
		}
	}
	
	public function reset() {
		sequences = [];
		time = 0;
		timeScale = 1.0;
		count = 0;
	}

	public function step(delta:Float) {
		delta *= timeScale;
		time += delta;
		var n = sequences.length;
		while (n-->0) {
			var s = sequences[n];
			s.step(delta);
		}
		count++;
		//Clean up every 60 frames
		if (count > 60) {
			count = 0;
			n = sequences.length;
			while (n-->0) {
				var s = sequences[n];
				if (s.complete) {
					sequences.splice(n, 1);
				}
			}
		}
	}
}

@:allow(tween.TweenAction)
class Delta
{
	static var defaultChannel:TweenChannel = new TweenChannel();
	static var channels:Array<TweenChannel> = [defaultChannel];
	public static var defaultTweenFunc:TweenFunc = Linear.none;
	
	public static function channel(index:Int):TweenChannel {
		if(index > channels.length-1 || channels[index] == null)
			channels[index] = new TweenChannel();
		return channels[index];
	}

	public static inline function runTrigger(t:String) {
		defaultChannel.runTrigger(t);
	}

	public static inline function tween(target:Dynamic):TweenAction {
		return defaultChannel.tween(target);
	}

	public static inline function delayCall(func:Void->Void, interval:Float):TweenAction {
		return defaultChannel.delayCall(func, interval);
	}

	public static inline function removeTweensOf(target:Dynamic) {
		defaultChannel.removeTweensOf(target);
	}
	
	public static inline function reset() {
		defaultChannel.reset();
	}

	public static inline function step(delta:Float) {
		defaultChannel.step(delta);
	}
}