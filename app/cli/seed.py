from __future__ import annotations

from pathlib import Path
from typing import Optional

import typer

from app.core.config import settings
from app.db.session import get_session
from app.services.ingest_pipeline import CsvIngestor, format_lint_issues

seed_app = typer.Typer(help="Seed and ingestion commands")


@seed_app.command("canonical-seed")
def canonical_seed(
    file_path: Path = typer.Option(
        ...,
        "--file",
        "-f",
        exists=True,
        readable=True,
        resolve_path=True,
        path_type=Path,
        metavar="FILE",
        help="CSV file containing canonical risks to ingest",
    ),
    provenance_editor: Optional[str] = typer.Option(None, help="Override provenance editor name"),
) -> None:
    editor = provenance_editor or settings.provenance_editor
    ingestor = CsvIngestor(editor=editor)
    entries, issues = ingestor.load(file_path)
    if issues:
        typer.echo(format_lint_issues(issues))
        raise typer.Exit(code=1)
    with get_session() as session:
        ingestor.upsert(session, entries)
    typer.echo("Canonical seed ingestion completed")
