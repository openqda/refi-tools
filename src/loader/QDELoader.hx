package loader;
import models.Model;
import models.Project;
import models.CodeBook;
import haxe.Exception;
import schema.ModelValidator;
import haxe.ValueException;
import haxe.macro.Type.Ref;
import models.ModelFactory;


class QDELoader {
    /**
     * Load a QDE project from a string containing the XML content.
     * Returns the Project model if successful, or null if there were errors.
     * Errors are printed to the console.
     **/
    public static function load(content:String):Project {
        var projectNode:Xml = Xml.parse(content).firstElement();
        if (projectNode == null || projectNode.nodeName != "Project") {
            trace("Invalid QDE file: Missing Project node");
        }
        var error:Array<String> = [];
        var project:Project = new Project();

        QDELoader.addAttributes(projectNode, project, error);
        QDELoader.addChildElements(projectNode, project, error);

        try {
            ModelValidator.validate(project);
        } catch (e) {
            error.push(e.message);
        }

        for (issue in error) {
            Sys.println("Error: " + issue);
        }

        return project;
    }

    private static function addAttributes(node:Xml, model:Model, error:Array<String>):Void {
        var iter = node.attributes();
        while (iter.hasNext()) {
            var name:String = iter.next().toString();
            var value:String = node.get(name);
            try {
                model.setAttributeValue(name, value);
            } catch (e) {
                error.push('${node.nodeName}: ${e.message}');
            }
        }
    }

    private static function addChildElements(node:Xml, model:Model, error:Array<String>):Void {
        for (child in node.elements()) {
            try {
                var childModel = ModelFactory.createModel(child.nodeName);
                model.children.add(child.nodeName, childModel);

                QDELoader.addAttributes(child, childModel, error);
                QDELoader.addChildElements(child, childModel, error);
            } catch (e) {
                error.push('${node.nodeName}: ${e.message}');
            }
        }
    }
}
