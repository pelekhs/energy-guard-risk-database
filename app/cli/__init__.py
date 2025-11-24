from __future__ import annotations

from pathlib import Path

import typer

from app.cli.review import review_app
from app.cli.seed import seed_app
from app.core.config import settings
from app.services.ingest_pipeline import CsvIngestor, format_lint_issues

cli = typer.Typer(help="EnergyGuard Risk DB management commands")
cli.add_typer(seed_app, name="ingest")
cli.add_typer(review_app, name="review")


@cli.command("lint")
def lint_command(
    file_path: Path = typer.Option(
        ...,
        "--file",
        "-f",
        exists=True,
        readable=True,
        resolve_path=True,
        path_type=Path,
        metavar="FILE",
        help="CSV file to validate without ingesting",
    )
) -> None:
    ingestor = CsvIngestor(editor=settings.provenance_editor)
    _entries, issues = ingestor.load(file_path)
    output = format_lint_issues(issues)
    typer.echo(output.rstrip())
    if issues:
        raise typer.Exit(code=1)


def main() -> None:
    cli()


if __name__ == "__main__":
    main()