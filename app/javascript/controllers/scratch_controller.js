import { Controller } from "@hotwired/stimulus"

console.log("loading scratch controller");

export default class extends Controller {
  connect() {
    console.log("connected scratch controller");
  }
}
