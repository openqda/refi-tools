package models;

import schema.Attribute;
import schema.Element;
import schema.Elements;
import models.Source.TextSource;

class Variables extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<Variable>("Variable", 1, -1)
        ];
    }
}