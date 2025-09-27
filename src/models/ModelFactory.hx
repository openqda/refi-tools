package models;
import haxe.ValueException;


class ModelFactory {
    public static function createModel(nodeName:String):Model {
        switch (nodeName) {
            case "Project":
                return new Project();
            case "CodeBook":
                return new CodeBook();
            case "Codes":
                return new models.Codes();
            case "Code":
                return new models.Code();
            case "Sources":
                return new models.Sources();
            case "Notes":
                return new models.Notes();
            case "Description", "PlainTextContent":
                return new models.Text(nodeName);
            case "Note", "TextSource":
                return new models.Source.TextSource();
            case "NoteRef", "CodeRef", "SourceRef", "SelectionRef", "VariableRef":
                return new models.Ref(nodeName);
            default:
                throw new ValueException("Unknown model type: " + nodeName);
        }
    }
}