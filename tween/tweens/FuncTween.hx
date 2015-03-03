package tween.tweens;
import tween.Delta;
import tween.tweens.FloatTween;

/**
 * ...
 * @author Sven Bergström
 */

    //value = get(name)
typedef FTGetFunc = String->Float;
    //set(name, value, t_for_convenience)
typedef FTSetFunc = String->Float->Float->Void;

class FuncTween extends FloatTween {

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
