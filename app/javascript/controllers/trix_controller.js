import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Trix controller connected');

    const fa_style = "fa-sharp fa-solid";

    const field_container = this.element.closest(".task-description-form");
    const trix_toolbar = field_container.querySelector(".trix-button-row");

    console.log(trix_toolbar);
    
    const button_bold = trix_toolbar.querySelector(".trix-button--icon-bold");
    button_bold.innerHTML = `<i class="${fa_style} fa-bold"></i>`;

    const button_italic = trix_toolbar.querySelector(".trix-button--icon-italic");
    button_italic.innerHTML = `<i class="${fa_style} fa-italic"></i>`;

    const button_underline = trix_toolbar.querySelector(".trix-button--icon-underline");
    button_underline.innerHTML = `<i class="${fa_style} fa-underline"></i>`;
    
  }
}
