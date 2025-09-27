package schema;
import models.Model;

class ModelValidator {
    public static function validate(model:Model) {
      // validate attributes
      for (attr in model.attributes) {
          AttributeValidator.validate(attr);
      }
    }
}