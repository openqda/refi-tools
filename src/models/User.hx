package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.StringType;
import types.SimpleTypes.GUIDType;

class User extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [
            new Attribute("guid", true, new GUIDType()),
            new Attribute("name", false, new StringType()),
            new Attribute("id", false, new StringType()),
        ];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [];
    }
}