package schema;
import haxe.ds.StringMap;
import models.Model;

class Elements {
    private var elements:StringMap<Element<Dynamic>>;

    public static function from(elements:Array<Element<Dynamic>>):Elements {
        var elems = new Elements();
        for (elem in elements) {
            if (elems.elements.exists(elem.name)) {
                throw 'Duplicate element definitions ${elem.name} in Elements';
            }
            elems.elements.set(elem.name, elem);
        }
        return elems;
    }

    public function new() {
        this.elements = new StringMap<Element<Dynamic>>();
    }

    public function has (name:String):Bool {
        return this.elements.exists(name);
    }

    public function add (name:String, value:Model):Void {
        if (!this.elements.exists(name)) {
            throw 'Forbidden: attempted to add ${name} which is not a defined Element';
        }
        var element = this.elements.get(name);
        element.addValue(value);
    }

    public function get (name:String):List<Dynamic> {
        if (!this.elements.exists(name)) {
            throw 'Forbidden: attempted to get ${name} which is not a defined Element';
        }
        var element = this.elements.get(name);
        return element.getValues();
    }
}
