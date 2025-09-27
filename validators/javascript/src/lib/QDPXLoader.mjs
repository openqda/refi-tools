import { promisify } from 'node:util';
import { unzip } from 'node:zlib';
import { pipeline } from 'node:stream';
import fs from 'node:fs/promises';
import fpath from 'node:path';

/**
 * Loads a .qdpx project file from the filesystem, unzips it to a temp folder,
 * and provides access to the project file and its sources.
 *
 * Every instance needs to be disposed, independently of which steps were completed.
 * If any step fails, call dispose() to clean up temp files and create a new instance.
 *
 * @example
 * ```js
 * const loader = new ProjectLoader('/path/to/project.qdpx');
 * await loader.load();
 * const projectFile = await loader.project(); // ArrayBuffer of project file
 * const sourceFile = await loader.source('relative/path/to/source'); // ArrayBuffer of source file
 * await loader.dispose(); // Clean up temp files
 * ```
 */
export class QDPXLoader {
  static setBase (path) {
    internal.base = path;
  }

  #project = null;
  #sources = new Map();

  /**
   * Original path to the .qdpx file to load and unzip
   * @type {string}
   */
  #source = '';

  /**
   * Root folder where the .qdpx file was unzipped
   * @type {string}
   */
  #root = '';

  /**
   * Name of the project (derived from the .qdpx file name)
   * @type {string}
   */
  #name = '';

  /**
   * Creates a new ProjectLoader instance for the given .qdpx file path.
   * @param path {string} - Path to the .qdpx file
   */
  constructor (path) {
    if (!path || !path.endsWith(internal.EXTENSION)) {
      throw new Error(`Invalid .qdpx file path: ${path}`);
    }

    this.#source = path;
    this.#name = fpath.basename(path, internal.EXTENSION);

    // generate a simple unique folder name for unzipping
    const unique = `${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    this.#root = fpath.join(internal.base, `${this.#name}-${unique}`);
  }

  async load () {
    // attempt to unzip the .qdpx file to the temp folder
    const buffer = await fs.readFile(this.#source, 'utf-8');
    await fs.mkdir(this.#root, { recursive: true });
    await internal.unzip(buffer, { to: this.#root });

    // check if project file exists
    const files = await fs.readdir();
    if (!files.includes(internal.PROJECT)) {
      await this.dispose();
      throw new Error(`No ${internal.PROJECT} file found in ${this.#source}`);
    }
    this.#project = fpath.join(this.#root, internal.PROJECT);
    if (files.includes(internal.SOURCES)) {
      const sourcesPath = fpath.join(this.#root, internal.SOURCES);
      const sourceFiles = await fs.readdir(sourcesPath);
      for (const fileName of sourceFiles) {
        const fullPath = fpath.join(sourcesPath, fileName);
        this.#sources.set(fileName, fullPath);
      }
    }
  }

  /**
   * Returns the project (.qde) file loaded from fs
   * @return {Promise<ArrayBuffer>}
   */
  async project () {
    if (!this.#project) {
      throw new Error('Project not loaded. Call load() first.');
    }
    return fs.readFile(this.#project);
  }

  sources () {
    return Array.from(this.#sources.keys());
  }

  /**
   * Loads a source file by its relative path within the sources folder.
   * @param path {string}
   * @return {Promise<ArrayBuffer>}
   */
  async source (path) {
    if (path.startsWith('internal://')) {
      path = path.replace('internal://', '');
    }
    if (!this.#sources.has(path)) {
      throw new Error(`Source file not found: ${path}`);
    }
    const fullPath = this.#sources.get(path);
    return fs.readFile(this.#project);
  }

  /**
   * Removes all unzipped files from the temp folder,
   * the folder itself, and clears all internal references.
   * @return {Promise<void>}
   */
  async dispose (strict = false) {
    this.#project = null;
    this.#sources.clear();
    try {
      await fs.rm(this.#root, { recursive: true, force: true });
    } catch (err) {
      // ignore errors during cleanup
      if (strict) {
        throw err;
      }
    }
    this.#root = '';
    this.#source = '';
    this.#name = '';
  }
}

/**
 * @private
 * @type {object}
 */
const internal = {
  base: '/tmp',
  unzip: promisify(unzip),
  EXTENSION: '.qdpx',
  PROJECT: 'project.qde',
  SOURCES: 'sources'
}