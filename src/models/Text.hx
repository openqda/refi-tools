package models;
import schema.Attribute;
import schema.Element;
import schema.Elements;

interface TextContent {
    public function set_text(text:String):Void;

    public function get_text():String;
}

class Text extends Model implements TextContent {
    public static final TYPES = ["Description", "PlainTextContent"];
    private var text:String;
    public var type(default, null):String;


    public function new(type:String) {
        super();
        this.text = "";
        if (type == null || TYPES.indexOf(type) == -1) {
            throw 'Type must be one of ${TYPES}';
        }
        this.type = type;
    }

    public function set_text(text:String):Void {
        this.text = text;
    }

    public function get_text():String {
        return this.text;
    }

    private function defineAttributes():Array<Attribute> {
        return [];
    }

    private function defineElements():Array<Element<Dynamic>> {
        return [];
    }
}