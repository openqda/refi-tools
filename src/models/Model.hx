package models;

import schema.Attribute;
import schema.Elements;
import schema.Element;
import haxe.ds.StringMap;

/**
 * The Model class is the base class for all models in the system.
 * It reprsents the xsd:complexType and contains the following properties:
 *
 * - attributes: A map of attribute names to Attribute objects.
 * - children: An Elements object representing the child elements of the model.
 */
abstract class Model {
    public var attributes:StringMap<Attribute>;
    public var children:Elements;
    public var value:String;

    public function new() {
        this.attributes = new StringMap<Attribute>();
        this.children = new Elements();

        var attributes = this.defineAttributes();
        for (attr in attributes) {
            if (this.attributes.exists(attr.name)) {
                throw 'Duplicate attribute name ${attr.name} in model ${this.toString()}';
            }
            this.attributes.set(attr.name, attr);
        }

        this.children = Elements.from(this.defineElements());
    }

    private abstract function defineAttributes ():Array<Attribute>;
    private abstract function defineElements ():Array<Element<Dynamic>>;

    public function setAttributeValue (name:String, value:String):Void {
        var attr = this.attributes.get(name);
        if (attr != null) {
            attr.setValue(value);
        } else {
            throw 'Attribute ${name} not found in model';
        }
    }

    public function toString ():String {
        return "Model";
    }
}
