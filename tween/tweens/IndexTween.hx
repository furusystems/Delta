package tween.tweens;
import tween.Delta;
import tween.tweens.FloatTween;

/**
 * ...
 * @author Sven Bergström
 */

class IndexTween extends FloatTween {

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
