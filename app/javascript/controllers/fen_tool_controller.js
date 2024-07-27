import { Controller } from "@hotwired/stimulus"
import { utils } from "./utils"

export default class extends Controller {
  static values = {
    color: String,
    team: String,
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
        team: this.teamValue,
        piece_kind: this.pieceKindValue,
      });
    }

    utils.postJson("/fen_tool_update", params);
  }

  selectPiece(event) {
    [...document.$$(".selected-piece-control")].forEach((node) => {
      node.classList.remove("selected-piece-control");
    });

    const deselecting = event.target.dataset.color == this.colorValue &&
                        event.target.dataset.pieceKind == this.pieceKindValue &&
                        event.target.dataset.team == this.teamValue;

    if (deselecting) {
      this.colorValue = "";
      this.teamValue = "";
      this.pieceKindValue = "";
    } else {
      event.target.parentNode.classList.add("selected-piece-control");
      this.colorValue = event.target.dataset.color;
      this.teamValue = event.target.dataset.team;
      this.pieceKindValue = event.target.dataset.pieceKind;
    }
  }
}
