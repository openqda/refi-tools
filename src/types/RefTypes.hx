import types.SimpleTypes.*;

abstract class RefType {
    private var targetGUID(default, null):String;

    public function new(targetGUID:GUIDType) {
        this.targetGUID = targetGUID;
    }

    abstract public function name():String;

    public function toString():String {
        if (this.targetGUID == null) {
            return "";
        }
        return this.targetGUID.toString();
    }
}