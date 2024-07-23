import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    color: String,
    pieceKind: String,
  };

  selectSquare(event) {
    let params = {
      square: event.target.dataset.square,
      fen: document.$("#fen").innerText,
    };

    if (this.colorValue) {
      Object.assign(params, {
        color: this.colorValue,
        piece_kind: this.pieceKindValue,
      });
    }

    this.postJson("/fen_tool_update", params);
  }

  selectPiece(event) {
    [...document.$$(".selected-piece-control")].forEach((node) => {
      node.classList.remove("selected-piece-control");
    });

    if (event.target.dataset.color == this.colorValue && event.target.dataset.pieceKind == this.pieceKindValue) {
      this.colorValue = "";
      this.pieceKindValue = "";
    } else {
      event.target.parentNode.classList.add("selected-piece-control");
      this.colorValue = event.target.dataset.color;
      this.pieceKindValue = event.target.dataset.pieceKind;
    }
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
