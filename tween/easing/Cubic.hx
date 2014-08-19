/**
 * @author Joshua Granick
 * @author Andreas Rønning
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package tween.easing;
	
	
class Cubic {
	
	
	static public inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return delta * t * t * t + start;
	}
	static public inline function easeOut(start:Float, delta:Float, t:Float):Float {
		return delta * ((t -= 1) * t * t + 1) + start;
	}
	static public inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		if ((t *= 2) < 1) {
			return delta * 0.5 * t * t * t + start;
		}else {
			return delta * 0.5 * ((t -= 2) * t * t + 2) + start;
		}
	}
	
}