package models;

import schema.Attribute;
import schema.Element;


class Codes extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Code>("Code", 1, null)
        ];
    }
}