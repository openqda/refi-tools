# JavaScript REFI Validator

## Node

You need at least Node.js 18 installed on your machine. You can download it from [nodejs.org](https://nodejs.org/).

### Usage

```js
import { REFIValidator } from '@openqda/refi-validator';
import fs from 'node:fs/promises';

// ... lazy load the defaults
await REFIValidator.useDefaults();

const qdeFile = await fs.readFile('path/to/qde/file.qde', 'utf-8');
const validator = new REFIValidator();

try {
  await validator.validate(qdeFile);
  // Valid REFI file
} catch (e) {
  // Invalid REFI file
  console.error(e.message); // Full validation message
  console.log(e.details);   // Array of validation errors
}
```