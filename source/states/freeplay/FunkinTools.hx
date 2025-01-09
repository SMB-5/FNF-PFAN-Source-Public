package states.freeplay;

import states.freeplay.*;
import flixel.graphics.FlxGraphic;

//? P-Slice utility class (I think)
class FunkinTools
{
	public static function mergeWithJson<T>(target:T,source:Dynamic,?ignoreFields:Array<String>):T{
		if(ignoreFields == null) ignoreFields = [];
		var fillInFields = Type.getInstanceFields(Type.getClass(target)).filter(s -> !ignoreFields.contains(s));

		if(source == null) return target;
		for (field in Reflect.fields(source)){
			if(fillInFields.contains(field)) Reflect.setField(target,field,Reflect.field(source,field));
			#if debug
			else if (!ignoreFields.contains(field)) throw 'Class ${Type.getClassName(Type.getClass(target))} doesn\'t contain field field $field';
			#else
			else if (!ignoreFields.contains(field)) trace('Class ${Type.getClassName(Type.getClass(target))} doesn\'t contain field field $field');
			#end
		}
		return target;
	}
}
