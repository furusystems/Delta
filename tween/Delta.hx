package tween;
import tween.easing.Linear;

/**
 * ...
 * @author Andreas Rønning
 */

private typedef TweenFunc = Float->Float->Float->Float;

	//value = get(name)
private typedef FTGetFunc = String->Float;
	//set(name, value, t_for_convenience)
private typedef FTSetFunc = String->Float->Float->Void;

interface Tweenable {

	public var tween:TweenAction;
	public var complete:Bool;
	public var name:String;
	public var tweenFunc:TweenFunc;
	public var from:Float;
	public var to:Float;

	@:noCompletion
	public var hasUpdated:Bool;

	public function check():Void;
	public function step(delta:Float):Void;

} //Tweenable

private class PropertyTween implements Tweenable {

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
	public function check()
	{
		init( Reflect.getProperty(tween.target, name) );
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
		refresh(c);
	}

	#if release inline #end
	function apply(val:Float)
	{
		Reflect.setProperty(tween.target, name, val);
	}

	#if release inline #end
	function refresh(val:Float)
	{
		if (val != current) {
			apply(current = val);
		}
	}
}


private class FuncTween extends PropertyTween {

	public var getFunc:FTGetFunc;
	public var setFunc:FTSetFunc;

	#if release inline #end
	public function new(tween:TweenAction, name:String, to:Float, duration:Float, getFunc:FTGetFunc, setFunc:FTSetFunc) {

		super(tween, name, to, duration);

		this.getFunc = getFunc;
		this.setFunc = setFunc;
	}

	#if release inline #end
	override public function check()
	{
		init(getFunc(name));
	}

	#if release inline #end
	override function apply(val:Float)
	{
		setFunc(name, val, time/duration);
	}

} //FuncTween

private class IndexTween extends PropertyTween {

	public var index:Int;

	#if release inline #end
	public function new(tween:TweenAction, index:Int, to:Float, duration:Float) {
		super(tween, Std.string(index), to, duration);
		this.index = index;
	}

	#if release inline #end
	override public function check()
	{
		init(tween.target[index]);
	}

	#if release inline #end
	override function apply(val:Float)
	{
		tween.target[index] = val;
	}

} //IndexTween


private class TweenAction {
	var prev:Null<TweenAction>;
	var next:Null<TweenAction>;
	var properties:Null<Map<String, Tweenable>>;
	var time:Float;
	var totalDuration:Float;
	var prevPropCreated:Null<Tweenable>;
	var onCompleteFunc:Null < Void->Void > ;
	var triggeringID:Null<String>;
	var triggerID:Null<String>;
	var triggerOnComplete:Bool;
	public var target:Dynamic;
	public function new(target:Dynamic) {
		time = totalDuration = 0.0;
		this.target = target;
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

	public inline function onComplete(func:Void->Void):TweenAction {
		onCompleteFunc = func;
		return this;
	}

	public inline function ease(func:Float->Float->Float->Float, all:Bool = true):TweenAction {
		if (all) {
			for (p in properties) p.tweenFunc = func;
		}else {
			if (prevPropCreated != null ) prevPropCreated.tweenFunc = func;
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
	public function trigger(id:String, onComplete:Bool = false):TweenAction {
		triggerOnComplete = onComplete;
		triggerID = id;
		return this;
	}

	#if release inline #end
	public function createAction():TweenAction {
		return append(new TweenAction(target));
	}

	#if release inline #end
	public function tween(target:Dynamic):TweenAction {
		return append(new TweenAction(target));
	}

	#if release inline #end
	public function func(property:String, value:Float, duration:Float, g:FTGetFunc, s:FTSetFunc):TweenAction {
		if(properties==null) properties = new Map();
		totalDuration = Math.max(totalDuration, duration);
		properties.set(property, prevPropCreated = new FuncTween(this, property, value, duration, g, s));
		return this;
	}

	#if release inline #end
	public function index(index:Int, value:Float, duration:Float):TweenAction {
		if(properties==null) properties = new Map();
		totalDuration = Math.max(totalDuration, duration);
		properties.set(Std.string(index), prevPropCreated = new IndexTween(this, index, value, duration));
		return this;
	}

	#if release inline #end
	public function prop(property:String, value:Float, duration:Float):TweenAction {

		if(properties==null) properties = new Map();
		#if debug
			if (!Reflect.hasField(target, property)) throw 'No property "$property" on object';
			//TODO: Check if the field is a property or not and if so, warn
		#end
		totalDuration = Math.max(totalDuration, duration);
		properties.set(property, prevPropCreated = new PropertyTween(this, property, value, duration));
		return this;
	}

	#if release inline #end
	public function propMultiple(properties:Dynamic, duration:Float):TweenAction {
		for (p in Reflect.fields(properties)) {
			prop(p, Reflect.getProperty(properties, p), duration);
		}
		return this;
	}

	/**
	 * Complete this node's properties and proceed to the next one
	 * @param	ffwd
	 */
	public function skip(ffwd:Bool) {
		for (p in properties) {
			Reflect.setProperty(target, p.name, p.to);
		}
		time = totalDuration;
		finish();
	}

	inline function finish()
	{
		if (onCompleteFunc != null) onCompleteFunc();
		if (triggerID != null && triggerOnComplete) {
			Delta.runTrigger(triggerID);
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
		if (!triggerOnComplete && triggerID != null) {
			Delta.runTrigger(triggerID);
			triggerID = null;
		}
		var allComplete:Bool = true;
		if (properties != null) {
			for (p in properties) {
				if(!p.hasUpdated) p.check();
				p.step(delta);
				if (!p.complete) allComplete = false;
			}
		}
		time += delta;
		if (time >= totalDuration) {
			finish();
		}
		return this;
	}
}

@:allow(tween.Delta)
private class TweenSequence extends TweenAction {
	public var complete:Bool;
	public function new(target:Dynamic) {
		super(target);
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

	function runTrigger(t:String) {
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
		if (next != null) next.skip(true);
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

@:allow(tween.TweenAction)
class Delta
{
	function new() { }

	static var sequences:Array<TweenSequence> = [];
	public static var time:Float = 0.0;
	public static var timeScale:Float = 1.0;
	public static var defaultTweenFunc:TweenFunc = Linear.none;
	static var count:Int = 0;

	#if release inline #end
	static function createSequence(target:Dynamic):TweenSequence {
		var s = new TweenSequence(target);
		sequences.push(s);
		return s;
	}

	public static function runTrigger(t:String) {
		for (s in sequences) {
			s.runTrigger(t);
		}
	}

	public static function tween(target:Dynamic):TweenAction {
		return createSequence(target).createAction();
	}

	public static function delayCall(func:Void->Void, interval:Float):TweenAction {
		return createSequence(null).wait(interval).onComplete(func);
	}

	public static function removeTweensOf(target:Dynamic) {
		for (s in sequences) {
			s.removeTweensOf(target);
		}
	}

	public static function step(delta:Float) {
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