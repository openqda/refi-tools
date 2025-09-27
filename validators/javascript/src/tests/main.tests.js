import fs from "node:fs/promises";
import path from 'node:path';
import { expect } from 'chai';
import { QDEValidator } from '../index.mjs';

describe("node tests", () => {
  before(async () => {
    await QDEValidator.useDefaults()
  })
  it('passes without errors on a valid document', async () => {
    const document = await fs.readFile(path.resolve('src/tests/data/valid-document.xml'), 'utf-8');
    const validator = new QDEValidator();
    await validator.validate({ document });
  });
  it('throws on an invalid document', async () => {
    const document = await fs.readFile(path.resolve('src/tests/data/invalid-document.xml'), 'utf-8');
    const validator = new QDEValidator();
    let error = null;
    try {
      await validator.validate({ document });
      expect.fail('expected error to be thrown');
    } catch (err) {
      error = err;
      expect(error.details).to.deep.equal([
        {
          message: "Element '{urn:QDA-XML:project:1.0}Project', attribute 'description': The attribute 'description' is not allowed.\n",
          line: 6,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}Project', attribute 'creatingUserId': The attribute 'creatingUserId' is not allowed.\n",
          line: 6,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}User', attribute 'email': The attribute 'email' is not allowed.\n",
          line: 8,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}TextSource', attribute 'creatingUserId': The attribute 'creatingUserId' is not allowed.\n",
          line: 14,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}TextSource', attribute 'creatingUserId': The attribute 'creatingUserId' is not allowed.\n",
          line: 82,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}TextSource', attribute 'creatingUserId': The attribute 'creatingUserId' is not allowed.\n",
          line: 86,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}TextSource', attribute 'creatingUserId': The attribute 'creatingUserId' is not allowed.\n",
          line: 208,
          col: 0
        },
        {
          message: "Element '{urn:QDA-XML:project:1.0}Codebook': This element is not expected. Expected is one of ( {urn:QDA-XML:project:1.0}Notes, {urn:QDA-XML:project:1.0}Links, {urn:QDA-XML:project:1.0}Sets, {urn:QDA-XML:project:1.0}Graphs, {urn:QDA-XML:project:1.0}Description, {urn:QDA-XML:project:1.0}NoteRef ).\n",
          line: 211,
          col: 0
        }
      ])
    }
  });
});
