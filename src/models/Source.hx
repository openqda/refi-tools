package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.DateTimeType;

class Source extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("name", false, new StringType()),
            new Attribute("creatingUser", false, new GUIDType()),
            new Attribute("creationDateTime", false, new DateTimeType()),
            new Attribute("modifyingUser", false, new GUIDType()),
            new Attribute("modifiedDateTime", false, new DateTimeType()),
        ];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Text>("Description", 0, -1),
            new Element<Ref>("NoteRef", 0, -1),
            new Element<Coding>("Coding", 0, -1),
            new Element<VariableValue>("VariableValue", 0, -1),
        ];
    }
}

class TextSource extends Source {
    private override function defineAttributes ():Array<Attribute> {
        var attrs = super.defineAttributes();
        attrs.push(new Attribute("richTextPath", false, new StringType()));
        attrs.push(new Attribute("plainTextPath", false, new StringType()));
        return attrs;
    }

    private override function defineElements ():Array<Element<Dynamic>> {
        var elements = super.defineElements();
        // PlainTextContent, 0, 1
        // PlainTextSelection, 0, -1
        return elements;
    }

    // validation note: Either PlainTextContent or plainTextPath MUST be filled, not both
}

class PictureSource extends Source {
    private override function defineAttributes ():Array<Attribute> {
        var attrs = super.defineAttributes();
        attrs.push(new Attribute("currentPath", false, new StringType()));
        return attrs;
    }

    private override function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Text>("Description", 0, 1),
            new Element<Coding>("Coding", 0, -1),
            new Element<Ref>("NoteRef", 0, -1),
        ];
    }
}