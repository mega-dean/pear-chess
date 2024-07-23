# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Sessions", type: :request) do
  context "logging in" do
    let!(:user) {
      User.create!(username: "username", email: "email@example.com", password: "password")
    }

    it "creates a session when params are valid" do
      params = {
        session: {
          username: "username",
          password: "password",
        },
      }

      post session_path(params)

      expect(request.env[:clearance].current_user).to eq(user)
    end

    it "does not create a session when username is invalid" do
      params = {
        session: {
          username: "no",
          password: "password",
        },
      }

      post session_path(params)

      expect(request.env[:clearance].current_user).to be(nil)
      expect(flash.alert).to eq(I18n.t("username_not_found", username: "no"))
    end
  end
end
