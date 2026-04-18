"""
lancer_verification.py — Lance la vérification des catalogues puis envoie
le rapport par mail via Claude Code (MCP thunderbird-mail, sendMail skipReview).

Appelé automatiquement par le Planificateur de tâches Windows chaque mercredi.
"""

import subprocess
import sys
import json
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).parent
EXPEDITEUR = "jbil.kebir@pm.me"
DESTINATAIRE = "jbil.kebir@protonmail.com"
TOKEN_FILE = Path(r"D:\Developpement\Token pour Claude.txt")


def lire_token() -> str:
    if TOKEN_FILE.exists():
        return TOKEN_FILE.read_text(encoding="utf-8").strip()
    return ""


def main():
    token = lire_token()

    # Lancement de la vérification
    args = [sys.executable, str(SCRIPT_DIR / "check_catalogues.py")]
    if token:
        args += ["--token", token]
    subprocess.run(args, check=True)

    # Récupération du rapport le plus récent
    rapports = sorted((SCRIPT_DIR / "rapports").glob("rapport_*.txt"))
    if not rapports:
        print("Aucun rapport trouvé après vérification.", file=sys.stderr)
        sys.exit(1)
    latest = rapports[-1]
    rapport_text = latest.read_text(encoding="utf-8")

    date_str = datetime.now().strftime("%d/%m/%Y")
    subject = f"Rapport Sesame -- {date_str}"

    # Envoi via Claude Code (MCP thunderbird-mail sendMail skipReview)
    prompt = (
        f"Utilise l'outil MCP thunderbird-mail sendMail pour envoyer ce mail sans review "
        f"(skipReview: true) :\n"
        f"- from: {EXPEDITEUR}\n"
        f"- to: {DESTINATAIRE}\n"
        f"- subject: {subject}\n"
        f"- body (texte brut) :\n{rapport_text}\n"
        f"- attachments: [\"{latest}\"]\n"
        f"Ne fais rien d'autre."
    )

    subprocess.run(
        ["claude", "--dangerously-skip-permissions", "-p", prompt],
        check=True,
    )


if __name__ == "__main__":
    main()
