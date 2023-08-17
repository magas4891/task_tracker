import { Controller } from "@hotwired/stimulus"
import $ from 'jquery'
import { Popover } from "bootstrap/dist/js/bootstrap.esm.js";
import Sortable from "sortablejs";
import csrfToken from '../scripts/csrfToken';

// Connects to data-controller="category"
export default class extends Controller {
  static targets = ["name", "input", "nameInput", 'dropdown'];
  static values = { url: String };

  showInput() {
    // Disabling Drag-and-Drop while editing
    const sortables = Sortable.get(document.getElementById('categories'))
    sortables.option('disabled', true)

    const nameElement = $(this.element).find('#categoryName');
    const name = $(this.element).data('categoryName');

    // Create the <input> element
    const inputElement = $('<input>', {
      type: 'text',
      class: 'mt-1',
      'data-category-target': 'nameInput',
      value: name
    });

    // Create the <span> element and append the <input> element to it
    const spanElement = $('<span>', {
      'data-category-target': 'input',
    }).append(inputElement);

    // Append the <span> element to a target element (e.g., a parent container)
    $(nameElement).html(spanElement);

    // Move focus to END of input field
    const input = $(nameElement).find('input')[0];
    const end = input.value.length;
    input.setSelectionRange(end, end);
    input.focus();

    inputElement.on("keydown", (event) => this.handleKeyDown(event, name, this.element));
    inputElement.on('blur', () => this.restoreTitle(this.element, name));
  }

  async handleKeyDown(event, name, elem) {
    if (event.key === "Enter") {
      event.preventDefault();
      const form = this.nameInputTarget;
      const newName = this.nameInputTarget.value;
      const data = { name: newName };

      try {
        const response = await fetch(this.urlValue, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify(data)
        });

        if (!response.ok) {
          const errors = await response.json();
          this.showPopover(form, errors.join(', '));

          return;
        }
        const html = await response.text(); // Turbo Stream message
        Turbo.renderStreamMessage(html);
      } catch (error) {
        console.error('Fetch error:', error);
      }
    } else if (event.key === "Escape") {
      this.restoreTitle(elem, name);
    }
  }

  restoreTitle(elem, name) {
    // Swapping element with original content
    const originalSpan = `<span data-category-target="name">${name}</span>
      <div class="dropdown ms-2" data-category-target="dropdown">
        <button class="btn" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <i class="fa-solid fa-ellipsis no-drug"></i>
        </button>
        <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
          <a href="#" data-action="category#showInput:prevent" class="dropdown-item">Rename</a>
          <a href="#" data-action="category#destroy:prevent" class="dropdown-item">Delete</a>
        </div>
      </div>`
    $(elem).find('#categoryName').html(originalSpan);

    // Enabling Drag-and-Drop
    const sortables = Sortable.get(document.getElementById('categories'));
    sortables.option('disabled', false);
  }

  showPopover(element, message) {
    const popover = new Popover(element, {
      title: 'Error',
      content: message
    });
    popover.show();

    // Hide the popover after a delay
    setTimeout(() => {
      popover.hide();
    }, 3000);
  }

  destroy() {
    fetch(this.urlValue, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        Accept: "text/vnd.turbo-stream.html"
      }
    })
        .then((response) => response.text())
        .then((html) => { Turbo.renderStreamMessage(html) });
  }
}
