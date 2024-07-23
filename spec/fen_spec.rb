# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fen do
  let(:fen) { Fen.new(8) }

  it "is created with an empty board" do
    expect(fen.rows.length).to eq(8)
    expect(fen.rows.first).to eq("8")
    expect(fen.to_s).to eq("8/8/8/8/8/8/8/8")
  end

  it "uses 'p' instead of 'b' for bishops" do
    expect {
      fen.add_piece(BLACK, BISHOP, 0)
    }.to change { fen.rows.first }.from("8").to("p7")
  end

  describe "larger boards" do
    let(:fen) { Fen.new(12) }

    it "uses base16 so no numbers are more than 1 digit" do
      expect(fen.rows.length).to eq(12)
      expect(fen.rows.first).to eq("c")
      expect(fen.to_s).to eq("c/c/c/c/c/c/c/c/c/c/c/c")
    end

    it "can add pieces" do
      expect {
        fen.add_piece(WHITE, ROOK, 0)
      }.to change { fen.rows.first }.from("c").to("Rb")

      expect {
        fen.add_piece(WHITE, ROOK, 11)
      }.to change { fen.rows.first }.to("RaR")
    end

    it "can remove pieces" do
      fen.add_piece(WHITE, ROOK, 4)
      fen.add_piece(BLACK, ROOK, 5)
      fen.add_piece(BLACK, QUEEN, 2)

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
        fen.add_piece(WHITE, ROOK, 0)
      }.to change { fen.rows.first }.from("8").to("R7")
    end

    it "middle of row" do
      expect {
        fen.add_piece(WHITE, ROOK, 4)
      }.to change { fen.rows.first }.from("8").to("4R3")

      expect {
        fen.add_piece(BLACK, ROOK, 5)
      }.to change { fen.rows.first }.to("4Rr2")

      expect {
        fen.add_piece(BLACK, QUEEN, 2)
      }.to change { fen.rows.first }.to("2q1Rr2")
    end

    it "end of row" do
      expect {
        fen.add_piece(WHITE, ROOK, 7)
      }.to change { fen.rows.first }.from("8").to("7R")
    end

    it "last row" do
      expect {
        fen.add_piece(BLACK, BISHOP, 60)
      }.to change { fen.rows.last }.from("8").to("4p3")

      expect {
        fen.add_piece(WHITE, QUEEN, 63)
      }.to change { fen.rows.last }.to("4p2Q")
    end
  end

  describe "remove_piece" do
    it "removes piece from a square" do
      fen.add_piece(WHITE, ROOK, 4)
      fen.add_piece(BLACK, ROOK, 5)
      fen.add_piece(BLACK, QUEEN, 2)

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
      fen.add_piece(WHITE, ROOK, 4)
      fen.add_piece(BLACK, ROOK, 5)
      fen.add_piece(BLACK, QUEEN, 2)

      fen.add_piece(BLACK, BISHOP, 60)
      fen.add_piece(WHITE, QUEEN, 63)

      expect(fen.to_s).to eq("2q1Rr2/8/8/8/8/8/8/4p2Q")
    end
  end
end
