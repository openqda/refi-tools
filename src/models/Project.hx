package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.GUIDType;
import types.SimpleTypes.DateTimeType;

class Project extends Model {

    private function defineAttributes ():Array<Attribute> {
        return [
            new Attribute("name", true, new StringType()),
            new Attribute("origin", false, new StringType()),
            new Attribute("guid", false, new GUIDType()),
            new Attribute("creatingUserGUID", false, new GUIDType()),
            new Attribute("creationDateTime", false, new DateTimeType()),
            new Attribute("modifyingUserGUID", false, new GUIDType()),
            new Attribute("modifiedDateTime", false, new DateTimeType()),
            new Attribute("basePath", false, new StringType()),
        ];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Text>("Description", 0, null),
            new Element<CodeBook>("CodeBook", 0, null),
            new Element<Sources>("Sources", 0, null),
            new Element<Notes>("Notes", 0, null),
        ];
    }
}
