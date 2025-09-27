import fs from 'node:fs/promises';
import path from 'node:path';
import { QDEValidator } from './src/index.mjs'

// Initialize with default schemas
await QDEValidator.useDefaults();

const targetPath = process.argv[2];
if (!targetPath) {
  console.error("Usage: node validate.mjs <path-to-xml-file>");
  process.exit(1);
}

const file = await fs.readFile(path.resolve(targetPath), 'utf-8');
  console.error(file.toString());
const validator = new QDEValidator();
try {
  await validator.validate({ document: file });
  console.log("Valid REFI XML");
} catch (error) {
  // error.details will contain an array of validation errors
  console.error("Invalid REFI XML", error.details);
  process.exit(1);
}