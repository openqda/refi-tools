package types;

import haxe.ValueException;

/**
 * Base class for simple types with value restrictions.
 */
abstract class SimpleType {
    private var val(default, null):String;

    public function new(?value:String) {
        this.setValue(value);
    }

    abstract private function restrict(value:String):String;

    abstract public function name():String;

    public function getValue():String {
        return this.val;
    }
    public function setValue(?value:String):Void {
        if (value == null) {
            this.val = null;
            return;
        }
        this.val = this.restrict(value);
    }

    public function toString():String {
        if (this.val == null) {
            return "";
        }
        return this.val;
    }
}

class RGBType extends SimpleType {
    private static var pattern:EReg = ~/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;
    public static final TYPE = "RGBType";

    private function restrict(value:String):String {
        if (!RGBType.pattern.match(value)) {
            throw new ValueException('Invalid pattern: ' + value);
        }
        return value;
    }

    public function name():String {
        return "RGBType";
    }
}

class GUIDType extends SimpleType {
    private static var pattern:EReg = ~/^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})|(\{[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$/;
    public static final TYPE = "GUIDType";

    private function restrict(value:String):String {
        if (!GUIDType.pattern.match(value)) {
            throw new ValueException('Invalid pattern: ' + value);
        }
        return value;
    }

    public function name():String {
        return "GUIDType";
    }
}

class DirectionType extends SimpleType {
    private static var allowedValues = ['Associative', 'OneWay', 'Bidirectional'];
    public static final TYPE = "directionType";

    private function restrict(value:String):String {
        if (DirectionType.allowedValues.indexOf(value) == -1) {
            throw new ValueException('Value must be one of: ' + DirectionType.allowedValues.join(', '));
        }
        return value;
    }

    public function name():String {
        return "directionType";
    }
}

class TypeOfVariableType extends SimpleType {
    private static var allowedValues = ['Text', 'Boolean', 'Integer', 'Float', 'Date', 'DateTime'];
    public static final TYPE = "typeOfVariableType";

    private function restrict(value:String):String {
        if (TypeOfVariableType.allowedValues.indexOf(value) == -1) {
            throw new ValueException('Value must be one of: ' + TypeOfVariableType.allowedValues.join(', '));
        }
        return value;
    }

    public function name():String {
        return "typeOfVariableType";
    }
}

class ShapeType extends SimpleType {
    private static var allowedValues = ['Person', 'Oval', 'Rectangle', 'RoundedRectangle', 'Star', 'LeftTriangle', 'RightTriangle', 'UpTriangle', 'DownTriangle', 'Note'];
    public static final TYPE = "ShapeType";

    private function restrict(value:String):String {
        if (ShapeType.allowedValues.indexOf(value) == -1) {
            throw new ValueException('Value must be one of: ' + ShapeType.allowedValues.join(', '));
        }
        return value;
    }

    public function name():String {
        return "ShapeType";
    }
}

class LineStyleType extends SimpleType {
    private static var allowedValues = ['dotted', 'dashed', 'solid'];
    public static final TYPE = "LineStyleType";

    private function restrict(value:String):String {
        if (LineStyleType.allowedValues.indexOf(value) == -1) {
            throw new ValueException('Value must be one of: ' + LineStyleType.allowedValues.join(', '));
        }
        return value;
    }

    public function name():String {
        return "LineStyleType";
    }
}

/**
 * date represents top-open intervals of exactly one day in length on the timelines of dateTime, beginning on the beginning moment of each day, up to but not including the beginning moment of the next day).  For non-timezoned values, the top-open intervals disjointly cover the non-timezoned timeline, one per day.  For timezoned values, the intervals begin at every minute and therefore overlap.
 * https://www.w3.org/TR/xmlschema11-2/#date
 **/
class DateType extends SimpleType {
    public static final TYPE = "xsd:date";

    private function restrict(value:String):String {
        // TODO validate according to xsd:dateTime format
        return value;
    }

    public function name():String {
        return "xsd:date";
    }
}

/**
 * dateTime represents instants of time, optionally marked with a particular time zone offset.  Values representing the same instant but having different time zone offsets are equal but not identical.
 * https://www.w3.org/TR/xmlschema11-2/#dateTime
 **/
class DateTimeType extends SimpleType {
    public static final TYPE = "xsd:dateTime";

    private function restrict(value:String):String {
        // TODO validate according to xsd:dateTime format
        return value;
    }

    public function name():String {
        return "xsd:dateTime";
    }
}

/**
 * [Definition:]  The string datatype represents character strings in XML
 * https://www.w3.org/TR/xmlschema11-2/#string
 **/
class StringType extends SimpleType {
    public static final TYPE = "xsd:string";

    private function restrict(value:String):String {
        // TODO validate according to xsd:string format
        return value;
    }

    public function name():String {
        return "xsd:string";
    }
}

/**
 * [Definition:]  boolean represents the values of two-valued logic.
 * https://www.w3.org/TR/xmlschema11-2/#boolean
 * booleanRep ::= 'true' | 'false' | '1' | '0'
 **/
class BooleanType extends SimpleType {
    public static final TYPE = "xsd:boolean";

    private function restrict(value:String):String {
        if (value != "true" && value != "false" && value != "1" && value != "0") {
            throw new ValueException('Value must be one of: "true", "false", "1", "0"');
        }
        return value;
    }

    public function name():String {
        return "xsd:boolean";
    }
}

/**
 * https://www.w3.org/TR/xmlschema11-2/#decimal
 * [Definition:]  decimal represents a subset of the real numbers, which can be represented by decimal numerals. The ·value space· of decimal is the set of numbers that can be obtained by dividing an integer by a non-negative power of ten, i.e., expressible as i / 10n where i and n are integers and n ≥ 0. Precision is not reflected in this value space; the number 2.0 is not distinct from the number 2.00. The order relation on decimal is the order relation on real numbers, restricted to this subset.
 **/
class DecimalType extends SimpleType {
    private static var pattern:EReg = ~/^(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)$/;
    public static final TYPE = "xsd:decimal";

    private function restrict(value:String):String {
        if (!DecimalType.pattern.match(value)) {
            throw new ValueException('Invalid pattern: ${value}');
        }
        return value;
    }

    public function name():String {
        return "xsd:decimal";
    }
}

/**
 * https://www.w3.org/TR/xmlschema11-2/#integer
 * [Definition:]   integer is ·derived· from decimal by fixing the value of ·fractionDigits· to be 0 and disallowing the trailing decimal point.  This results in the standard mathematical concept of the integer numbers.  The ·value space· of integer is the infinite set {...,-2,-1,0,1,2,...}.  The ·base type· of integer is decimal.
 **/
class IntegerType extends SimpleType {
    private static var pattern:EReg = ~/[\-+]?[0-9]+/;
    public static final TYPE = "xsd:integer";

    private function restrict(value:String):String {
        if (!IntegerType.pattern.match(value)) {
            throw new ValueException('Invalid pattern: ${value}');
        }
        return value;
    }

    public function name():String {
        return "xsd:integer";
    }
}

interface SimpleTypeFactory {
    function create(value:String):SimpleType;
}

class SimpleTypeFactoryImpl implements SimpleTypeFactory {
    private var typeName:String;
    public function new(typeName:String) {
        this.typeName = typeName;
    }

    public function create(value:String):SimpleType {
        switch (this.typeName) {
            case "RGBType":
                return new RGBType(value);
            case "GUIDType":
                return new GUIDType(value);
            case "directionType":
                return new DirectionType(value);
            case "typeOfVariableType":
                return new TypeOfVariableType(value);
            case "shapeType":
                return new ShapeType(value);
            case "lineStyleType":
                return new LineStyleType(value);
            case "xsd:date":
                return new DateType(value);
            case "xsd:dateTime":
                return new DateTimeType(value);
            case "xsd:string":
                return new StringType(value);
            case "xsd:boolean":
                return new BooleanType(value);
            case "xsd:decimal":
                return new DecimalType(value);
            case "xsd:integer":
                return new IntegerType(value);
            default:
                throw new ValueException('Unknown type: ' + typeName);
        }
    }
}

class AbstractTypeFactory {
    public static function createFactory(typeName:String):SimpleTypeFactory {
        return new SimpleTypeFactoryImpl(typeName);
    }
}