package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.BooleanType;
import types.SimpleTypes.IntegerType;
import types.SimpleTypes.DateType;
import types.SimpleTypes.DateTimeType;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.TypeOfVariableType;

class VariableValue extends Model {
    public function new () {
        super();
    }
    private function defineAttributes ():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("name", true, new StringType()),
            new Attribute("creatingUser", true, new TypeOfVariableType()),
        ];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Ref>("VariableRef", 1, 1),
            new Element<StringType>("StringValue", 0, 1),
            new Element<BooleanType>("BooleanValue", 0, 1),
            new Element<IntegerType>("IntegerValue", 0, 1),
            new Element<DateType>("DateValue", 0, 1),
            new Element<DateTimeType>("DateTimeValue", 0, 1),
        ];
    }

    // validation note: VariableValue must contain exactly one VariableRef, followed by exactly
    // one of the value elements (StringValue, BooleanValue, IntegerValue, DateValue, DateTimeValue)
}
