package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.DateTimeType;

class Selection extends Model {
    private function defineAttributes():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("name", false, new StringType()),
            new Attribute("creatingUser", false, new GUIDType()),
            new Attribute("creationDateTime", false, new DateTimeType()),
            new Attribute("modifyingUser", false, new GUIDType()),
            new Attribute("modifiedDateTime", false, new DateTimeType()),
        ];
    }

    private function defineElements():Array<Element<Dynamic>> {
        return [
            new Element<Text>("Description", 0, 1),
            new Element<Coding>("Coding", 0, -1),
            new Element<Ref>("NoteRef", 0, -1),
        ];
    }
}

class  PlainTextSelection extends Selection {
    private override function defineAttributes():Array<Attribute> {
        var attrs = super.defineAttributes();
        attrs.push(new Attribute("startPosition", true, new IntegerType()));
        attrs.push(new Attribute("endPosition", true, new IntegerType()));
        return attrs;
    }
}