import { Controller } from "@hotwired/stimulus"
import { utils } from "./utils"

export default class extends Controller {
  static values = {
    moveSteps: Array,
    reflectX: Boolean,
    reflectY: Boolean,
    boardSize: Number,
  }

  connect() {
    const stepWaitTime = 1000 / 3;

    this.moveStepsValue.forEach((moveStep, idx) => {
      new Promise((resolve) => setTimeout(resolve, idx * stepWaitTime)).then(() => {
        for (let [targetSquare, moves] of Object.entries(moveStep)) {
          if (moves.captured) {
            const piece = this.idxToXY(targetSquare);

            new Promise((resolve) => setTimeout(resolve, stepWaitTime / 2)).then(() => {
              document.$(`.square-${piece.x}-${piece.y} img`)?.remove();
            });
          }

          let movingPieces = (moves.moving || []).concat(moves.bumped || []);
          movingPieces.forEach((pieceId) => {
            this.movePieceTo(pieceId, parseInt(targetSquare));
          });
        }
      });
      [...document.$$('.pending-move')].forEach((node) => node.remove());
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
    const srcXY = this.idxToXY(src);
    const destXY = this.idxToXY(dest);

    const xMult = this.reflectXValue ? -1 : 1;
    const yMult = this.reflectYValue ? -1 : 1;

    return {
      x: xMult * utils.squareRem * (destXY.x - srcXY.x),
      y: yMult * utils.squareRem * (destXY.y - srcXY.y),
    };
  }
}
