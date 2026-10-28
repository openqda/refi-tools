"""Sort a codes export CSV in REFI-QDA codebook order (Python 3.12)."""

import argparse
import csv
from pathlib import Path
import xml.etree.ElementTree as ET


def code_order(codebook: Path) -> dict[str, int]:
    """Return name ranks in depth-first XML order, including parent codes."""
    root = ET.parse(codebook).getroot()
    namespace = "{urn:QDA-XML:codebook:1.0}"
    if root.tag == "CodeBook":
        namespace = ""
    elif root.tag != f"{namespace}CodeBook":
        raise ValueError("Expected a REFI-QDA CodeBook root element")
    codes = root.find(f"{namespace}Codes")
    if codes is None:
        raise ValueError("Codebook is missing its Codes element")

    order = {}
    for code in codes.iter(f"{namespace}Code"):
        name = code.get("name")
        if not name or not name.strip():
            raise ValueError("Every code must have a non-empty name")
        if name in order:
            raise ValueError(f"Ambiguous duplicate code name: {name!r}")
        order[name] = len(order)
    return order


def sort_csv(codebook: Path, input_csv: Path, output_csv: Path,
             code_column: str = "code category", *,
             sort_by: str = "hierarchy", keep_duplicates: bool = False) -> int:
    """Validate, remove exact duplicates and stably sort; return rows written."""
    if sort_by not in ("hierarchy", "source"):
        raise ValueError("sort_by must be 'hierarchy' or 'source'")
    order = code_order(codebook)
    with input_csv.open(encoding="utf-8-sig", newline="") as source:
        reader = csv.reader(source, strict=True)
        header = next(reader, None)
        if not header or header.count(code_column) != 1:
            raise ValueError(f"CSV must contain exactly one {code_column!r} column")
        code_index = header.index(code_column)
        if sort_by == "source":
            if header.count("source") != 1:
                raise ValueError("CSV must contain exactly one 'source' column")
            source_index = header.index("source")
        rows = []
        seen = set()
        for row in reader:
            if len(row) != len(header):
                raise ValueError(f"CSV record ending at line {reader.line_num} has "
                                 f"{len(row)} fields; expected {len(header)}")
            name = row[code_index]
            if name not in order:
                raise ValueError(f"Unknown code {name!r} at CSV line {reader.line_num}")
            if not keep_duplicates:
                record = tuple(row)
                if record in seen:
                    continue
                seen.add(record)
            rows.append(row)

    if sort_by == "source":
        rows.sort(key=lambda row: (row[source_index], order[row[code_index]]))
    else:
        rows.sort(key=lambda row: order[row[code_index]])
    with output_csv.open("w", encoding="utf-8", newline="") as destination:
        writer = csv.writer(destination)
        writer.writerow(header)
        writer.writerows(rows)
    return len(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--codebook", required=True, type=Path, help="Input .qdc codebook")
    parser.add_argument("--input", required=True, type=Path, help="Input CSV export")
    parser.add_argument("--output", required=True, type=Path, help="Destination CSV")
    parser.add_argument("--code-column", default="code category", help="CSV code-name column")
    parser.add_argument("--sort-by", choices=("hierarchy", "source"), default="hierarchy",
                        help="Sort globally by hierarchy (default), or by source then hierarchy")
    parser.add_argument("--keep-duplicates", action="store_true",
                        help="Keep exact duplicate rows (removed by default)")
    args = parser.parse_args()
    try:
        # Protect both inputs from accidental replacement, including hard links.
        for source in (args.codebook, args.input):
            if (args.output.resolve() == source.resolve()
                    or (args.output.exists() and args.output.samefile(source))):
                raise ValueError("Output must be a different file from both inputs")
        count = sort_csv(args.codebook, args.input, args.output, args.code_column,
                         sort_by=args.sort_by, keep_duplicates=args.keep_duplicates)
    except (OSError, ValueError, csv.Error, ET.ParseError) as error:
        parser.exit(1, f"Error: {error}\n")
    print(f"Wrote {count} rows to {args.output}")


if __name__ == "__main__":
    main()
