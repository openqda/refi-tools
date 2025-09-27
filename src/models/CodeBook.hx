package models;

import schema.Attribute;
import schema.Element;

class CodeBook extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Codes>("Codes", 0, null)
        ];
    }
}