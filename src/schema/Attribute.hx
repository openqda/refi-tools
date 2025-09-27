package schema;
import types.SimpleTypes.SimpleType;

class Attribute {
    public var name(default, null):String;
    public var required(default, null):Bool;
    public var value(default, null):SimpleType;

    public function new(name:String, required:Bool, defaultValue:SimpleType) {
        this.name = name;
        this.required = required;
        this.value = defaultValue;
    }

    public function getValue():SimpleType {
        return this.value;
    }

    public function setValue(value:String):SimpleType {
        this.value.setValue(value);
        return this.getValue();
    }
}
