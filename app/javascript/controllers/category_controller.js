import { Controller } from '@hotwired/stimulus';
import $ from 'jquery';
import { Popover } from 'bootstrap/dist/js/bootstrap.esm.js';
import Sortable from 'sortablejs';
import csrfToken from '../scripts/csrfToken';

// Connects to data-controller="category"
export default class extends Controller {
  static targets = ['name', 'input', 'nameInput', 'dropdown'];
  static values = { url: String, categoryId: Number };

  create() {
    const newCategoryFrame = $('<turbo_frame>', {
      id: 'new_category'
    });
    $(this.element).after(newCategoryFrame);
    fetch(`/categories/new?prevCategoryId=${this.categoryId}`,)
        .then((response) => response.text())
        .then((html) => {
          Turbo.renderStreamMessage(html);

          // Wait for the frame to be appended asynchronously
          const observer = new MutationObserver((mutationsList) => {
            for (const mutation of mutationsList) {
              const frameContent = mutation.target;
              if (frameContent && frameContent.id === 'new_category') {
                const closeButton = frameContent.querySelector('.remove-category');
                if (closeButton) {
                  closeButton.addEventListener('click', (event) => {
                    event.preventDefault();
                    newCategoryFrame.remove();
                  });
                }
              }
            }
          });

          observer.observe(document.getElementById('new_category'), { childList: true, subtree: true });
        });
  }

  destroy() {
    fetch(this.url, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        Accept: 'text/vnd.turbo-stream.html'
      }
    })
        .then((response) => response.text())
        .then((html) => { Turbo.renderStreamMessage(html) });
  }

  showInput() {
    // Disabling Drag-and-Drop while editing
    const sortables = Sortable.get(document.getElementById('namedCategories'));
    sortables.option('disabled', true);

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
    // const end = input.value.length;
    // input.setSelectionRange(end, end);
    input.focus();

    inputElement.on('keydown', (event) => this.handleKeyDown(event, name, this.element));
    inputElement.on('blur', () => this.restoreTitle(this.element, name));
  }

  async handleKeyDown(event, name, elem) {
    if (event.key === "Enter") {
      event.preventDefault();
      const input = this.nameInputTarget;
      const newName = this.newName;
      const data = { name: newName };

      try {
        const response = await fetch(this.url, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify(data)
        });

        if (!response.ok) {
          const errors = await response.json();
          this.showPopover(input, errors.join(', '));

          return;
        }
        const html = await response.text(); // Turbo Stream message
        Turbo.renderStreamMessage(html);
      } catch (error) {
        console.error('Fetch error:', error);
      }
    } else if (event.key === 'Escape') {
      this.restoreTitle(elem, name);
    }
  }

  restoreTitle(elem, name) {
    // Swapping element with original content
    const originalSpan = `<span data-category-target='name'>${name}</span>
      <div class='dropdown ms-2' data-category-target='dropdown'>
        <button class='btn' type='button' id='dropdownMenuButton' data-bs-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
          <i class='fa-solid fa-ellipsis no-drug'></i>
        </button>
        <div class='dropdown-menu' aria-labelledby='dropdownMenuButton'>
          <a href='#' data-action='category#showInput:prevent' class='dropdown-item'>Rename</a>
          <a href='#' data-action='category#destroy:prevent' class='dropdown-item'>Delete</a>
        </div>
      </div>`;
    $(elem).find('#categoryName').html(originalSpan);

    // Enabling Drag-and-Drop
    const sortables = Sortable.get(document.getElementById('namedCategories'));
    sortables.option('disabled', false);
  }

  removeFrame() {
    console.log('1111111111111111111111')
  }

  showPopover(element, message) {
    const popover = new Popover(element, {
      title: 'Error',
      content: message,
      placement: 'top',
      template: "<div class='popover bs-popover-top' role='tooltip'><div class='popover-arrow'></div><h3 class='popover-header bg-danger text-white'></h3><div class='popover-body bg-light'></div></div>",
      animation: true
    });
    popover.show();

    // Hide the popover after a delay
    setTimeout(() => {
      popover.hide();
    }, 3000);
  }

  get url() {
    return this.urlValue;
  }

  get categoryId() {
    return this.categoryIdValue;
  }

  get newName() {
    return this.nameInputTarget.value;
  }
}
