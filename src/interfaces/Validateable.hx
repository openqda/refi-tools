package interfaces;

interface Validateable {
    /**
     * Validates the object's state.
     * Throws an exception if the object is in an invalid state,
     * otherwise passes silently.
     */
    public function validate():Void;
}
