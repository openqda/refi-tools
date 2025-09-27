package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.BooleanType;
import types.SimpleTypes.RGBType;

class Code extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("name", true, new StringType()),
            new Attribute("isCodable", true, new BooleanType()),
            new Attribute("color", false, new RGBType()),
        ];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Text>("Description", 1, 1),
            new Element<Ref>("NoteRef", 1, -1),
            new Element<Code>("Code", 1, -1),
        ];
    }
}
