package models;

import schema.Attribute;
import schema.Element;
import models.Source.TextSource;

class Notes extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<TextSource>("Note", 1, -1) // at least one up to infinite
        ];
    }
}
