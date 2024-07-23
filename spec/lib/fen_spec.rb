# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fen do
  let(:fen) { Fen.new(8) }

  it "is created with an empty board" do
    expect(fen.rows.length).to eq(8)
    expect(fen.rows.first).to eq("8")
    expect(fen.to_s).to eq("8/8/8/8/8/8/8/8")
  end

  describe "characters" do
    it "uses 'i' instead of 'b' for bishops (to support base16 numbers)" do
      expect {
        fen.add_piece(TOP, BLACK, BISHOP, 0)
      }.to change { fen.rows.first }.from("8").to("i7")
    end

    it "uses separate characters for pieces on different teams" do
      # Using the char after the TOP char (except for queen, which would conflict with rook).
      fen.add_piece(TOP, BLACK, KNIGHT, 0)
      fen.add_piece(TOP, BLACK, BISHOP, 1)
      fen.add_piece(TOP, BLACK, ROOK, 2)
      fen.add_piece(TOP, BLACK, QUEEN, 3)
      fen.add_piece(TOP, BLACK, KING, 4)

      fen.add_piece(BOTTOM, BLACK, KNIGHT, 8)
      fen.add_piece(BOTTOM, BLACK, BISHOP, 9)
      fen.add_piece(BOTTOM, BLACK, ROOK, 10)
      fen.add_piece(BOTTOM, BLACK, QUEEN, 11)
      fen.add_piece(BOTTOM, BLACK, KING, 12)

      expect(fen.rows[0]).to eq("nirqk3")
      expect(fen.rows[1]).to eq("mjsul3")
    end
  end

  describe "larger boards" do
    let(:fen) { Fen.new(12) }

    it "uses base16 so numbers are only 1 digit" do
      expect(fen.rows.length).to eq(12)
      expect(fen.rows.first).to eq("c")
      expect(fen.to_s).to eq("c/c/c/c/c/c/c/c/c/c/c/c")
    end

    it "can add pieces" do
      expect {
        fen.add_piece(TOP, WHITE, ROOK, 0)
      }.to change { fen.rows.first }.from("c").to("Rb")

      expect {
        fen.add_piece(TOP, WHITE, ROOK, 11)
      }.to change { fen.rows.first }.to("RaR")
    end

    it "can remove pieces" do
      fen.add_piece(TOP, WHITE, ROOK, 4)
      fen.add_piece(TOP, BLACK, ROOK, 5)
      fen.add_piece(TOP, BLACK, QUEEN, 2)

      expect {
        fen.remove_piece(5)
      }.to change { fen.rows[0] }.from("2q1Rr6").to("2q1R7")

      expect {
        fen.remove_piece(4)
      }.to change { fen.rows[0] }.to("2q9")

      expect {
        fen.remove_piece(3)
      }.not_to change { fen.rows[0] }
    end
  end

  describe "add_piece" do
    it "beginning of row" do
      expect {
        fen.add_piece(TOP, WHITE, ROOK, 0)
      }.to change { fen.rows.first }.from("8").to("R7")
    end

    it "middle of row" do
      expect {
        fen.add_piece(TOP, WHITE, ROOK, 4)
      }.to change { fen.rows.first }.from("8").to("4R3")

      expect {
        fen.add_piece(TOP, BLACK, ROOK, 5)
      }.to change { fen.rows.first }.to("4Rr2")

      expect {
        fen.add_piece(TOP, BLACK, QUEEN, 2)
      }.to change { fen.rows.first }.to("2q1Rr2")
    end

    it "end of row" do
      expect {
        fen.add_piece(TOP, WHITE, ROOK, 7)
      }.to change { fen.rows.first }.from("8").to("7R")
    end

    it "last row" do
      expect {
        fen.add_piece(TOP, BLACK, BISHOP, 60)
      }.to change { fen.rows.last }.from("8").to("4i3")

      expect {
        fen.add_piece(TOP, WHITE, QUEEN, 63)
      }.to change { fen.rows.last }.to("4i2Q")
    end
  end

  describe "remove_piece" do
    it "removes piece from a square" do
      fen.add_piece(TOP, WHITE, ROOK, 4)
      fen.add_piece(TOP, BLACK, ROOK, 5)
      fen.add_piece(TOP, BLACK, QUEEN, 2)

      expect {
        fen.remove_piece(5)
      }.to change { fen.rows[0] }.from("2q1Rr2").to("2q1R3")

      expect {
        fen.remove_piece(4)
      }.to change { fen.rows[0] }.to("2q5")

      expect {
        fen.remove_piece(3)
      }.not_to change { fen.rows[0] }
    end
  end

  describe "to_s" do
    it "joins rows with '/'" do
      fen.add_piece(TOP, WHITE, ROOK, 4)
      fen.add_piece(TOP, BLACK, ROOK, 5)
      fen.add_piece(TOP, BLACK, QUEEN, 2)

      fen.add_piece(TOP, BLACK, BISHOP, 60)
      fen.add_piece(TOP, WHITE, QUEEN, 63)

      expect(fen.to_s).to eq("2q1Rr2/8/8/8/8/8/8/4i2Q")
    end
  end
end
