package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.DateTimeType;

class Coding extends Model {
    private function defineAttributes():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("creatingUser", false, new GUIDType()),
            new Attribute("creationDateTime", false, new DateTimeType()),
        ];
    }

    private function defineElements():Array<Element<Dynamic>> {
        return [
            new Element<Ref>("CodeRef", 1, 1), // exactly one CodeRef
            new Element<Ref>("NoteRef", 0, null),
        ];
    }
}
