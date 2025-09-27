package models;

import schema.Attribute;
import schema.Element;


class Users extends Model {
    private function defineAttributes ():Array<Attribute> {
        return [];
    }

    private function defineElements ():Array<Element<Dynamic>> {
        return [
            new Element<User>("User", 0, null)
        ];
    }
}