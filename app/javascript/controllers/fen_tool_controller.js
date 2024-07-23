import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    color: String,
    pieceKind: String,
  };

  selectSquare(event) {
    this.postJson("/fen_tool_update", {
      square: event.target.dataset.square,
      color: this.colorValue,
      piece_kind: this.pieceKindValue,
      fen: document.$("#fen").innerText,
    });
  }

  selectPiece(event) {
    this.colorValue = event.target.dataset.color;
    this.pieceKindValue = event.target.dataset.pieceKind;
  }

  postJson(url, body) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    return fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify(body),
    });
  }
}
