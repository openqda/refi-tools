package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.TypeOfVariableType;

class Variable extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("name", true, new StringType()),
            new Attribute("creatingUser", true, new TypeOfVariableType()),
        ];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Text>("Description", 0),
        ];
    }
}
