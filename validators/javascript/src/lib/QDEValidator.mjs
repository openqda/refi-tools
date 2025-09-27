import { XmlDocument, XsdValidator } from "libxml2-wasm";
import { DataLoader } from './DataLoader.mjs'

/**
 * A REFI project validator using libxml2-wasm under the hood.
 * The validator uses XSD schemas to validate REFI XML documents (disguised as .qde files).
 * The validator is isomorphic and can thus be used in various JavaScript environments.
 * Create a new instance for each validation and call `dispose()` afterward to free resources,
 * or you will risk memory leaks.
 *
 * @example
 * ```js
 * import { REFIValidator } from "refi-tools/validators/node/REFIValidator.mjs";
 * await REFIValidator.init();
 * const validator = new REFIValidator();
 * try {
 *  await validator.validate({ document: xmlString });
 *  console.log("Valid REFI XML");
 * } catch (error) {
 *   // error.details will contain an array of validation errors
 *   console.error("Invalid REFI XML", error.details);
 * }
 * ```
 */
export class QDEValidator {
  // public static methods
  
  /**
   * Allows to override the loader if needed-
   * @param DataLoaderClass
   */
  static useLoader (DataLoaderClass) {
    internal.loader = DataLoaderClass;
  }

  /**
   * Overrides default schema from a given XML Schema document.
   * @param {DataLoaderOptions} options
   * @return {Promise<void>}
   */
  static async useSchema ({ data, encoding = "utf8", url, fetchOptions }) {
    const document = await loader({ data, encoding, url, fetchOptions }).load();
    internal.schema = XmlDocument.fromBuffer(document);
  }

  /**
   * Override this method to lazy load the defaults.
   * @abstract
   * @return {Promise<void>}
   */
  static async useDefaults() {}

  // members

  #doc = null;
  #sources = [];
  #validator = null;
  #schema = null;

  // methods

  async validate ({ document, strict = false }) {
    if (!internal.schema) {
      throw new Error("No default schema initialized. Call REFIValidator.init() or REFIValidator.schema() first.");
    }

    if (this.#doc || this.#validator || this.#schema) {
      throw new Error(
        "Instance already used. Dispose and create a new instance for each validation."
      );
    }
    const buffer = await loader({ data: document }).load();
    this.#doc = XmlDocument.fromBuffer(buffer);
    this.#schema = await getSchema(
      this.#doc.root.attr("schemaLocation", "xsi")?.content,
      strict
    );
    this.#validator = XsdValidator.fromDoc(this.#schema);
    this.#validator.validate(this.#doc);

    // if sources are referenced, collect them
    if (this.#doc
  }

  sources () {
    return this.#sources;
  }

  /**
   * Dispose the resources used by this instance.
   */
  dispose () {
    this.#doc.dispose();
    this.#doc = null;
    this.#validator.dispose();
    this.#validator = null;
    if (this.#schema !== internal.schema) {
      this.#schema.dispose();
    }
    this.#schema = null;
  }
}

/**
 * @private
 * @type {{schema: null, loader: DataLoader, knownURIs: string[]}}
 */
const internal = {
  loader: DataLoader,
  schema: null,
  knownURIs: [
    "https://openqda.github.io/refi-tools/docs/schemas/project/v1.0/Project.xsd",
    "http://schema.qdasoftware.org/versions/Project/v1.0/Project.xsd"
  ]
};


/**
 * Load an XSD schema from a given location, or return the internal schema if the location is unknown.
 * There are three states to decide for a schema:
 * - A: the doc schema and internal schema are the same → use default schema
 * - B: the doc does not define a schema → use default schema
 * - C: the doc defines a different schema → load and use it
 * If not strict, any error in loading the schema will fall back to the default schema.
 * @param location {string?} - the schemaLocation attribute value from the XML document
 * @param strict {boolean} - if true, throw errors when the schema cannot be loaded
 * @return {Promise<XmlDocument|null>}
 */
const getSchema = async (location, strict = false) => {
  if (!location || internal.knownURIs.includes(location)) {
    return internal.schema;
  }

  const parts = location.split(/\s+/);
  const url = parts.find((p) => p.endsWith(".xsd"));
  if (!url) {
    if (strict) {
      throw new Error("No .xsd URL found in schemaLocation");
    }
    else {
      return internal.schema;
    }
  }

  try {
    const loaderInstance = loader({ url });
    const buffer = await loaderInstance.load();
    return toDoc(buffer);
  } catch (err) {
    if (strict) {
      throw err;
    }
  }

  return internal.schema;
};

const toDoc = (buffer) => XmlDocument.fromBuffer(buffer);
const loader = (options) => new internal.loader(options);