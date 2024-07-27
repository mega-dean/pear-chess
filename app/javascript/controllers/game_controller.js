import { Controller } from "@hotwired/stimulus"
import { utils } from "./utils"

export default class extends Controller {
  static values = {
    selectedPieceX: Number,
    selectedPieceY: Number,
    selectedPieceColor: String,
    currentColor: String,
    boardSize: Number,
    gameId: Number,
  };

  connect() {
    // Numbers default to 0, so this prevents the game from thinking the piece at (0,0) is selected.
    this.selectedPieceXValue = null;
    this.selectedPieceYValue = null;
  }

  selectSquare(event) {
    const square = event.currentTarget;
    const dataset = square.dataset;
    const squareX = parseInt(dataset.squareX);
    const squareY = parseInt(dataset.squareY);

    const clickedSquareHasPiece = () => dataset.color.length > 0;

    const clickedPieceIsAlreadySelected = () => {
      return this.selectedPieceXValue === squareX &&
             this.selectedPieceYValue === squareY;
    };

    const deselectPiece = () => {
      this.selectedPieceXValue = null;
      this.selectedPieceYValue = null;
      this.selectedPieceColorValue = null;

      this.removeTargets();
    };

    const clickedPieceBelongsToPlayer = () => dataset.imageClass === "current-player";
    const clickedPieceIsCurrentColor = () => dataset.color === this.currentColorValue;

    const selectClickedPiece = () => {
      this.selectedPieceXValue = squareX;
      this.selectedPieceYValue = squareY;
      this.selectedPieceColorValue = dataset.color;

      this.setTargetMoves(dataset.pieceKind);
    };

    const squareIsValidMove = () => square.classList.contains("target-move");
    const createMove = () => {
      const params = {
        game_id: this.gameIdValue,
        color: this.selectedPieceColorValue,
        src_x: this.selectedPieceXValue,
        src_y: this.selectedPieceYValue,
        dest_x: squareX,
        dest_y: squareY,
      };
      deselectPiece();
      utils.postJson("/moves", params);
    };

    // TODO if a square is a valid target move and also has a piece, it should be interpreted as clicking the making
    // the target move, not selecting the new piece
    if (clickedSquareHasPiece()) {
      if (clickedPieceIsAlreadySelected()) {
        deselectPiece();
      } else {
        if (clickedPieceBelongsToPlayer() && clickedPieceIsCurrentColor()) {
          selectClickedPiece();
        }
      }
    } else {
      if (this.selectedPieceXValue) {
        if (squareIsValidMove()) {
          createMove();
        }
      }
    }

    document.$(".selected-piece")?.classList.remove("selected-piece");
    document.$(`.piece-${this.selectedPieceXValue}-${this.selectedPieceYValue}`)?.classList.add("selected-piece");
  }

  removeTargets() {
    [...document.$$(".target-move")].forEach((element) => element.classList.remove("target-move"));
  }

  setTargetMoves(pieceKind) {
    this.removeTargets();
    const moves = {
      knight: () => this.getKnightMoves(),
      bishop: () => this.getBishopMoves(),
      rook: () => this.getRookMoves(),
      queen: () => this.getBishopMoves().concat(this.getRookMoves()),
      king: () => this.getKingMoves(),
    }[pieceKind]();

    moves.forEach((move) => {
      if (this.isOnBoard(move)) {
        document.$(`.square-${move.x}-${move.y}`)?.classList.add("target-move");
      }
    })
  }

  isOnBoard(target) {
    const boardSize = this.boardSizeValue;
    const onBoard = (coord) => (0 <= coord && coord < boardSize);

    return onBoard(target.x) && onBoard(target.y);
  }

  getKnightMoves() {
    const x = this.selectedPieceXValue;
    const y = this.selectedPieceYValue;

    return [
      { x: x + 1, y: y + 2 },
      { x: x + 1, y: y - 2 },
      { x: x - 1, y: y + 2 },
      { x: x - 1, y: y - 2 },
      { x: x + 2, y: y + 1 },
      { x: x + 2, y: y - 1 },
      { x: x - 2, y: y + 1 },
      { x: x - 2, y: y - 1 },
    ];
  }

  getBishopMoves() {
    const upLeft = this.getMovesInDirection({ x: -1, y: -1 });
    const downLeft = this.getMovesInDirection({ x: 1, y: -1 });
    const upRight = this.getMovesInDirection({ x: -1, y: 1 });
    const downRight = this.getMovesInDirection({ x: 1, y: 1 });

    return upLeft.concat(downLeft, upRight, downRight);
  }

  getRookMoves() {
    // These direction names are a little inaccurate, since the board is reflected based on team and color. So "up"
    // won't necessarily be the upward squares visually.
    const up = this.getMovesInDirection({ y: -1 });
    const down = this.getMovesInDirection({ y: 1 });
    const left = this.getMovesInDirection({ x: -1 });
    const right = this.getMovesInDirection({ x: 1 });

    return up.concat(down, left, right);
  }

  getKingMoves() {
    const x = this.selectedPieceXValue;
    const y = this.selectedPieceYValue;

    return [
      { x: x - 1, y: y - 1 },
      { x: x + 1, y: y - 1 },
      { x: x - 1, y: y + 1 },
      { x: x + 1, y: y + 1 },

      { x: x + 0, y: y - 1 },
      { x: x + 0, y: y + 1 },

      { x: x - 1, y: y + 0 },
      { x: x + 1, y: y + 0 },
    ];
  }

  getMovesInDirection(delta) {
    const moves = [];
    let target = {
      x: this.selectedPieceXValue + (delta.x || 0),
      y: this.selectedPieceYValue + (delta.y || 0),
    };

    while (this.isOnBoard(target)) {
      moves.push({ ...target });

      target.x += (delta.x || 0);
      target.y += (delta.y || 0);
    }

    return moves;
  }
}
