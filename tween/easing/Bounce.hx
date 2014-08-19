
/**
 * @author Andreas Rønning
 * @author Erik Escoffier
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package tween.easing;

	
class Bounce {

	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return delta - easeOut(0, delta, 1 - t) + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		if (t < (1/2.75)) {
			return delta * (7.5625 * t * t) + start;
		} else if (t < (2/2.75)) {
			return delta * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + start;
		} else if (t < (2.5/2.75)) {
			return delta * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + start;
		} else {
			return delta * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + start;
		}
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		if (t < 0.5) {
			return easeIn(0, delta, t*2) * .5 + start;
		} else {
			return easeOut(0, delta, t*2-1) * .5 + delta *.5 + start; 
		}
	}
		
}