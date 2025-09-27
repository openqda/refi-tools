package models;

import schema.Attribute;
import schema.Element;
import types.SimpleTypes.GUIDType;

/**
 * A reference to another model element by its GUID.
 * All ref types are represented by this class.
 **/
class Ref extends Model {
    public var type(default, null):String;

    public function new(type:String) {
        super();
        this.type = type;
        // TODO validate type against known model types
    }

    private function defineAttributes():Array<Attribute> {
        return [
            new Attribute("targetGUID", true, new GUIDType()),
        ];
    }

    private function defineElements():Array<Element<Dynamic>> {
        return [];
    }
}
