package schema;

class Element <T>{
    public var name(default, null):String;
    public var minOccurs(default, null):Int;
    public var maxOccurs(default, null):Int;
    private var values(default, null):List<T>;

    public function new(name:String, ?minOccurs:Int = 0, ?maxOccurs:Int = 1) {
        this.name = name;
        this.minOccurs = minOccurs;
        this.maxOccurs = maxOccurs;
        this.values = new List<T>();
    }

    public function addValue(value:T):Void {
        if (this.maxOccurs != null && this.maxOccurs > -1 && this.values.length >= this.maxOccurs) {
            throw 'Forbidden: attempted to add value to ${this.name} which exceeds maxOccurs of ${this.maxOccurs}';
        }
        this.values.push(value);
    }

    public function getValues():List<T> {
        return this.values;
    }
}
