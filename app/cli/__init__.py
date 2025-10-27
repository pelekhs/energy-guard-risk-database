import typer

from app.cli.seed import seed_app
from app.cli.review import review_app

cli = typer.Typer(help="EnergyGuard Risk DB management commands")
cli.add_typer(seed_app, name="ingest")
cli.add_typer(review_app, name="review")


def main() -> None:
    cli()


if __name__ == "__main__":
    main()
