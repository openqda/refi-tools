# Sort selections by code hierarchy

Requires Python 3; no dependencies or installation needed. From this directory:

```bash
python3 coding_hierarchy.py --codebook example_codebook.qdc --input example_selections.csv --output example_restul.csv
```

Choose the sorting mode with `--sort-by`:

- `hierarchy` (default): sort the entire CSV by code hierarchy, across sources.
- `source`: sort by the `source` column first (ascending, case-sensitive text
  order), then by hierarchy within each source. Requires exactly one `source`
  column.

For source-first sorting:

```bash
python3 coding_hierarchy.py --codebook example_codebook.qdc --input example_selections.csv --output example_restul.csv --sort-by source
```sorted_selections

Hierarchy order is depth-first: parents before children, siblings in XML order.
Rows sharing a code (and source in source mode) keep their original relative
order. Codes without selections do not add rows.

Before sorting, exact duplicate rows are removed, keeping the first occurrence.
All fields must match: selections with different sources, codes, positions,
authors or timestamps remain separate. Use `--keep-duplicates` to retain every
input row. The supplied example export contains 41 rows, including 13 extra
copies; the cleaned output contains 28 rows.

The CSV must be comma-separated UTF-8 (an input BOM is accepted) with a header.
Code names match exactly against `code category`; use `--code-column NAME` for
another header. All columns and field values are preserved, including quoted
commas, line breaks and Unicode. CSV quoting is normalized on output.

Unknown names, duplicate names in the codebook, malformed XML/CSV and missing
columns cause an error before output is written. Names must be unique because
the export identifies codes by name rather than GUID. Standard REFI-QDA 1.0
codebooks and equivalent XML without a namespace are supported.

The output must differ from both inputs. An existing output file is overwritten
after input validation. Rows are held in memory while sorting.

Run tests:

```bash
python3 -m unittest discover -s . -p 'test_*.py' -v
```
