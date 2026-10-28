"""Standard-library tests for the hierarchy sorter."""

from collections import Counter
import csv
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET

from coding_hierarchy import code_order, sort_csv


HERE = Path(__file__).resolve().parent


class HierarchyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.book = self.directory / "book.qdc"
        self.source = self.directory / "input.csv"
        self.output = self.directory / "output.csv"
        self.write_book('<Code name="Z"><Code name="B"><Code name="C"/>'
                        '</Code><Code name="A"/></Code><Code name="D"/>')

    def write_book(self, codes, namespace="urn:QDA-XML:codebook:1.0"):
        self.book.write_text(f'<CodeBook xmlns="{namespace}"><Codes>{codes}'
                             '</Codes></CodeBook>', encoding="utf-8")

    def write_csv(self, rows, header=("code category", "selection")):
        with self.source.open("w", encoding="utf-8-sig", newline="") as stream:
            csv.writer(stream).writerows([header, *rows])

    def read_csv(self, path):
        with path.open(encoding="utf-8-sig", newline="") as stream:
            return list(csv.reader(stream))

    def test_nested_order_and_stability_preserve_values(self):
        rows = [["A", "first"], ["D", "last"], ["C", "nested"],
                ["B", 'Küster, says "hello"\nnext line'], ["Z", "parent"],
                ["A", "second"], ["A", "first"]]
        self.write_csv(rows)
        self.assertEqual(sort_csv(self.book, self.source, self.output, keep_duplicates=True), 7)
        self.assertEqual(self.read_csv(self.output),
                         [["code category", "selection"], rows[4], rows[3],
                          rows[2], rows[0], rows[5], rows[6], rows[1]])

    def test_without_namespace(self):
        self.write_book('<Code name="Z"/><Code name="A"/>', namespace="")
        self.assertEqual(code_order(self.book), {"Z": 0, "A": 1})

    def test_cleaning_only_removes_exact_duplicates_in_both_modes(self):
        header = ["source", "code category", "created by", "created at",
                  "last update", "start pos", "end pos", "selection"]
        base = ["a.txt", "A", "Author", "today", "", "0", "5", "hello"]
        distinct = [base]
        for index, value in enumerate(["b.txt", "B", "Other", "yesterday",
                                       "today", "1", "6", "hello\n"]):
            row = base.copy()
            row[index] = value
            distinct.append(row)
        self.write_csv([base, *distinct, base], header=header)
        for mode in ("source", "hierarchy"):
            with self.subTest(mode=mode):
                self.assertEqual(sort_csv(self.book, self.source, self.output,
                                          sort_by=mode), len(distinct))
                result = self.read_csv(self.output)
                self.assertEqual(Counter(map(tuple, result[1:])),
                                 Counter(map(tuple, distinct)))
                # Remaining rows with the same sort key keep their input order.
                self.assertEqual([row for row in result[1:]
                                  if row[0] == "a.txt" and row[1] == "A"],
                                 [row for row in distinct
                                  if row[0] == "a.txt" and row[1] == "A"])

    def test_cli_duplicate_option(self):
        self.write_csv([["A", "same"], ["A", "same"]])
        command = [sys.executable, str(HERE / "coding_hierarchy.py"),
                   "--codebook", str(self.book), "--input", str(self.source),
                   "--output", str(self.output)]
        for options, count in (([], 1), (["--keep-duplicates"], 2)):
            with self.subTest(options=options):
                result = subprocess.run(command + options, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(len(self.read_csv(self.output)) - 1, count)
                self.assertIn(f"Wrote {count} rows", result.stdout)

    def test_sorting_modes_across_sources(self):
        header = ["selection", "source", "code category"]
        rows = [["first", "b.txt", "A"], ["child", "a.txt", "A"],
                ["parent", "b.txt", "Z"], ["parent", "a.txt", "Z"],
                ["second", "b.txt", "A"], ["first", "b.txt", "A"]]
        self.write_csv(rows, header=header)
        for mode, indices in (("source", [3, 1, 2, 0, 4, 5]),
                              ("hierarchy", [2, 3, 0, 1, 4, 5])):
            with self.subTest(mode=mode):
                count = sort_csv(self.book, self.source, self.output, sort_by=mode,
                                 keep_duplicates=True)
                self.assertEqual(count, len(rows))
                self.assertEqual(self.read_csv(self.output),
                                 [header, *(rows[index] for index in indices)])

    def test_source_mode_validates_header(self):
        for header in (["code category"], ["source", "code category", "source"]):
            with self.subTest(header=header):
                self.write_csv([], header=header)
                self.output.write_text("keep me")
                with self.assertRaisesRegex(ValueError, "exactly one 'source'"):
                    sort_csv(self.book, self.source, self.output, sort_by="source")
                self.assertEqual(self.output.read_text(), "keep me")
        self.write_csv([], header=["source", "code category"])
        self.assertEqual(sort_csv(self.book, self.source, self.output, sort_by="source"), 0)

    def test_invalid_sort_mode(self):
        with self.assertRaisesRegex(ValueError, "sort_by"):
            sort_csv(self.book, self.source, self.output, sort_by="invalid")

    def test_cli_source_mode(self):
        rows = [["b.txt", "Z"], ["a.txt", "A"], ["a.txt", "Z"]]
        header = ["source", "category"]
        self.write_csv(rows, header=header)
        result = subprocess.run(
            [sys.executable, str(HERE / "coding_hierarchy.py"),
             "--codebook", str(self.book), "--input", str(self.source),
             "--output", str(self.output), "--sort-by", "source",
             "--code-column", "category"], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.read_csv(self.output), [header, rows[2], rows[1], rows[0]])

    def test_custom_column_and_header_only(self):
        self.write_csv([], header=["code", "text"])
        self.assertEqual(sort_csv(self.book, self.source, self.output, "code"), 0)
        self.assertEqual(self.read_csv(self.output), [["code", "text"]])

    def test_invalid_csv_leaves_existing_output_untouched(self):
        for content in ("", "selection\ntext\n", "code category,code category\n",
                        "code category,selection\nMissing,text\n",
                        "code category,selection\nA\n",
                        "code category,selection\nA,text,extra\n",
                        'code category,selection\nA,"unterminated'):
            with self.subTest(content=content):
                self.source.write_text(content, encoding="utf-8")
                self.output.write_text("keep me", encoding="utf-8")
                with self.assertRaises((ValueError, csv.Error)):
                    sort_csv(self.book, self.source, self.output)
                self.assertEqual(self.output.read_text(), "keep me")

    def test_invalid_codebooks(self):
        for codes in ('<Code name="A"/><Code name="A"/>', '<Code/>',
                      '<Code name=" "/>'):
            with self.subTest(codes=codes):
                self.write_book(codes)
                with self.assertRaises(ValueError):
                    code_order(self.book)
        for xml in ('<Other/>', '<CodeBook/>', '<CodeBook'):
            with self.subTest(xml=xml):
                self.book.write_text(xml)
                with self.assertRaises((ValueError, ET.ParseError)):
                    code_order(self.book)

    def test_supplied_examples(self):
        book = HERE / "example_codebook.qdc"
        source = HERE / "exmaple_selections.csv"
        original = self.read_csv(source)
        count = sort_csv(book, source, self.output)
        result = self.read_csv(self.output)
        self.assertEqual(count, 28)
        self.assertEqual(result[0], original[0])
        self.assertEqual(Counter(map(tuple, result[1:])),
                         Counter({tuple(row): 1 for row in original[1:]}))
        expected = ["Rage", "Anger", "Frustration", "Annoyance", "Shame", "Envy",
                    "Negativ/Ruhig", "Powerlessness", "Sadness", "Disappointment",
                    "Cynicism / Resignation", "Boredom", "Positiv/Aufgeregt", "Awe",
                    "Optimism", "Inspiration", "Interest (cognitive-emotional)",
                    "Curiosity", "Positiv/Ruhig", "Gratitude", "Trust", "Safety",
                    "Contentment"]
        self.assertEqual(list(dict.fromkeys(row[1] for row in result[1:])), expected)

    def test_cli_success_and_input_protection(self):
        self.write_csv([["A", "child"], ["Z", "parent"]])
        command = [sys.executable, str(HERE / "coding_hierarchy.py"),
                   "--codebook", str(self.book), "--input", str(self.source)]
        result = subprocess.run(command + ["--output", str(self.output)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Wrote 2 rows", result.stdout)
        for path in (self.source, self.book):
            before = path.read_bytes()
            result = subprocess.run(command + ["--output", str(path)],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 1)
            self.assertIn("Output must be a different file", result.stderr)
            self.assertEqual(path.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
