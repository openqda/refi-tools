/**
 * @typedef {Object} DataLoaderOptions
 * @type {Object}
 * @property url {string}
 * @param data {any}
 * @param encoding {string?}
 * @param fetchOptions {object?}
 */

/**
 * @abstract
 * @class DataLoader
 */
export class DataLoader {
  data = null;
  url = null;
  encoding = null;
  fetchOptions = null;

  /**
   * @param {DataLoaderOptions} options
   */
  constructor ({ url, data, encoding, fetchOptions }) {
    this.data = data;
    this.url = url;
    this.encoding = encoding;
    this.fetchOptions = fetchOptions;
  }

  /**
   * Load data from url or data property, depending on given options
   * @return {Promise<ArrayBuffer>}
   */
  async load () {
    const { data, url } = this;
    if (url) {
      return this.fromUrl();
    }
    if (data) {
      return this.fromData();
    }
    throw new Error(`Must provide url or data to load, got ${url} / ${data}`);
  }

  /**
   * Load data from the given URL.
   * @abstract
   * @return {Promise<ArrayBuffer>}
   */
  async fromUrl () {
    throw new Error('must extend abstract class')
  }

  /**
   * Load data from the given data property.
   * @return {Promise<ArrayBuffer>}
   */
  async fromData () {
    throw new Error('must extend abstract class')
  }
}
