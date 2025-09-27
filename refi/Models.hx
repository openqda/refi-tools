package;
import Types.StringType;
import Types.GUIDType;
import Types.DateTimeType;
import Types.BooleanType;
import Types.RGBType;

class Project {
    // attributes
    public var name:StringType;
    public var origin:StringType;
    public var creatingUserGUID:GUIDType;
    public var creationDateTime:DateTimeType;
    public var modifyingUserGUID:GUIDType;
    public var modifiedDateTime:DateTimeType;
    public var basePath:StringType;

    // children
    public var users:List<User>;
    public var codebook:CodeBook; // REFI allows only one :-(
    // variables
    // cases
    // sources
    public var notes:List<Note>;
    // links
    public var sets:List<Set>;
    // graphs
    public var description:StringType;
    // noteRefs (that apply to the project as a whole)
    public var noteRefs:List<Ref>;

    public function new () {}
}

class User {
    public var guid:GUIDType;
    public var name:StringType;
    public var id:StringType;
}

/**
 * The codebook is defined by two schemas, project.xsd and codebook.xsd.
 * The respective builder needs to be aware of this.
 */
class CodeBook {
    public var origin:StringType;
    public var codes:List<Code>;
    public var sets:List<Set>;
}

class Set {
    public var description:StringType;
    public var memberCodes:List<MemberCode>;
    public var memberSources:List<Ref>;
    public var memberNotes:List<Ref>;
    public var guid:GUIDType;
    public var name:StringType;
}

class Case {
    public var guid:GUIDType;
    public var name:StringType;
    public var description:StringType;

    public var codeRefs:List<Ref>;
    public var variableValues:List<VariableValue>;
    public var notes:List<Ref>;
    public var sourceRefs:List<Ref>;
    public var selectionRefs:List<Ref>;
}

class Code {
    // attributes
    public var guid:GUIDType;
    public var name:StringType;
    public var isCodable:BooleanType;
    public var color:RGBType;
    public var description:StringType;

    // children
    public var notes:List<Ref>;
    public var codes:List<Code>;
}

class Ref {
    public var targetGUID:GUIDType;
}

class MemberCode {
    public var guid:GUIDType;
}

class Note {}

class VariableValue {}