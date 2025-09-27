package schema;

import haxe.ValueException;

class AttributeValidator {
    public static function validate(?attribute:Attribute):Void {
        if (attribute == null) {
            throw new ValueException('Attribute is null');
        }
        if (attribute.getValue() == null && attribute.required == true) {
            throw new ValueException('Attribute ${attribute.name} is required');
        }
    }
}