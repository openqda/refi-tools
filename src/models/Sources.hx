package models;

import schema.Attribute;
import schema.Element;
import schema.Elements;
import models.Source.TextSource;

class Sources extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            // sources can have infinite number of different source types
            // where each source type must be exactly one of the following types.
            // there is no sequence defined so they can appear in arbitrary order
            new Element<TextSource>("TextSource", 0, -1)
        ];
    }

    // validation note: Sources must contain at least one Source (of any type)
    // but can contain infinite number of Sources
    // there must be no element with same GUID of multiple Types
}