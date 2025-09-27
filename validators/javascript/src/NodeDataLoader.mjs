import fs from 'node:fs/promises';
import path from 'node:path'
import { Buffer } from 'node:buffer';
import { DataLoader } from './lib/DataLoader.mjs'

export class NodeDataLoader extends DataLoader {
  async fromUrl () {
    const { url, fetchOptions } = this;

    // support for file URI schema
    // related: https://datatracker.ietf.org/doc/rfc8089/
    const twoSlash = url.startsWith("file://");
    const threeSlash = url.startsWith("file:///");
    if (twoSlash || threeSlash) {
      const relPath = url.slice( threeSlash ? 7 : 6 );
      return fs.readFile(path.resolve(relPath));
    }

    // fetch api provides support for http(s) URLs
    // related: https://fetch.spec.whatwg.org/
    else if (url.startsWith("http://") || url.startsWith("https://")) {
      const res = await fetch(url, fetchOptions);
      if (!res.ok) {
        throw new Error(`Failed to fetch schema from URL: ${url}`);
      }

      return res.arrayBuffer();
    }
    // other protocols are not supported
    else {
      throw new Error(`Unknown or unsupported URL protocol in ${url}`);
    }
  }

  async fromData () {
    const { data, encoding } = this;

    if (Buffer.isBuffer(data)) {
      return data;
    }
    if (data instanceof ArrayBuffer) {
      return data;
    }
    if (ArrayBuffer.isView(data)) {
      return data.buffer;
    }
    if (typeof data === "string") {
      return Buffer.from(data, encoding);
    }
    throw new TypeError(
      `Expected data to be compatible with ArrayBuffer, got ${data}`
    );
  }
}
