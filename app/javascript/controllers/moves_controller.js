import { Controller } from "@hotwired/stimulus"
import { utils } from "./utils"

export default class extends Controller {
  static values = {
    moveSteps: Array,
    unmovingPieces: Array,
    reflectX: Boolean,
    reflectY: Boolean,
    boardSize: Number,
  }

  connect() {
    this.unmovingPieces = new Set(this.unmovingPieces);

    const stepWaitTime = 1000 / 3;

    this.moveStepsValue.forEach((moveStep, idx) => {
      new Promise((resolve) => setTimeout(resolve, idx * stepWaitTime)).then(() => {
        console.log(moveStep);
        for (let [targetSquare, moves] of Object.entries(moveStep)) {
          if (moves.captured) {
            const piece = this.idxToXY(targetSquare);
            document.$(`.square-${piece.x}-${piece.y} img`)?.remove();
          }

          let movedPieces = (moves.moving || []).concat(moves.bumped || []);
          movedPieces.forEach((pieceId) => {
            this.movePieceTo(pieceId, parseInt(targetSquare));
          });
        }
      });
    });

  }

  idxToXY(idx) {
    const x = idx % this.boardSizeValue;
    const y = Math.floor(idx / this.boardSizeValue);

    return { x, y };
  }

  movePieceTo(src, dest) {
    const srcXY = this.idxToXY(src);
    const pieceImg = document.$(`.square-${srcXY.x}-${srcXY.y} img`);
    const translate = this.getTranslate(src, dest);
    pieceImg.style.transform = translate;
  }

  getTranslate(src, dest) {
    const coords = this.getTranslateCoords(src, dest);
    return this.getTranslateStyle(coords);
  }

  getTranslateStyle(coords) {
    return `translate(${coords.x}rem, ${coords.y}rem)`;
  }

  getTranslateCoords(src, dest) {
    const relativeDest = this.idxToXY(dest - src);

    const xMult = this.reflectXValue ? -1 : 1;
    const yMult = this.reflectYValue ? -1 : 1;

    return {
      x: xMult * utils.squareRem * relativeDest.x,
      y: yMult * utils.squareRem * relativeDest.y,
    };
  }
}
