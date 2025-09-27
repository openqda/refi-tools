import { QDPXLoader } from './lib/QDPXLoader.mjs'
import { NodeDataLoader } from './NodeDataLoader.mjs'
import { QDEValidator } from "./lib/QDEValidator.mjs";
import fpath from 'node:path';

// by default we inject the node data loader
// which can handle file:// and http(s):// URLs
QDEValidator.useLoader(NodeDataLoader);

/**
 * Use this method to lazy load the defaults
 * @return {Promise<void>}
 */
QDEValidator.useDefaults = async () => {
  const url = `file://${fpath.resolve('schema.xsd')}`;
  return QDEValidator.useSchema({ url });
}

const validateQdpxArchive = async (path, { tmpDir } = {}) => {
  if (tmpDir) {
    QDPXLoader.setBase(tmpDir);
  }
  const archiveLoader = new QDPXLoader(path);
  await archiveLoader.load();

  // validate project
  const projectFile = await archiveLoader.project();
  const sources = await archiveLoader.sources();
  await validateQdeFile(projectFile, sources);

  // validate sources, referenced by project
}

const validateQdeFile = async (project) => {
  const validator = new QDEValidator();
  await validator.validate({ document: project, strict: true });

}


/**
 *
 */
export {
  validateQdpxArchive,
  validateQdeFile,
  QDEValidator
}

export const DataLoader = NodeDataLoader;
