import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import csrfToken from "../scripts/csrfToken";

// Connects to data-controller="task"
export default class extends Controller {
  static values = { url: String }
  static targets = ["descriptionView", "descriptionForm"]

  connect() {
  }

  showDescriptionForm() {
    if (this.hasDescriptionViewTarget && this.hasDescriptionFormTarget) {
      this.descriptionViewTarget.style.display = "none"
      this.descriptionFormTarget.style.display = "block"
      this.syncTrixEditorContent()
      this.customizeTrixToolbar()
    }
  }

  // Trix doesn't load initial content when the editor was inside display:none — sync from the hidden input or from the view
  syncTrixEditorContent() {
    const form = this.descriptionFormTarget.querySelector("form")
    if (!form) return
    const trixEditor = form.querySelector("trix-editor")
    if (!trixEditor?.editor) return
    const inputId = trixEditor.getAttribute("input")
    const hiddenInput = inputId ? document.getElementById(inputId) : null
    let html = hiddenInput?.value?.trim()
    if (!html && this.hasDescriptionViewTarget) {
      const viewContent = this.descriptionViewTarget.querySelector(".trix-content")
      if (viewContent) html = viewContent.innerHTML.trim()
    }
    if (html) trixEditor.editor.loadHTML(html)
  }

  customizeTrixToolbar() {
    const fa_style = "fa-sharp fa-solid";
    console.log(this.element);
    // const field_container = this.element.closest(".task-description-form");
    const trix_toolbar = this.element.querySelector(".trix-button-row");
    console.log(trix_toolbar);

    const button_bold = trix_toolbar.querySelector(".trix-button--icon-bold");
    console.log(button_bold);
    button_bold.innerHTML = `<i class="${fa_style} fa-plus"></i>`;

    // const button_italic = trix_toolbar.querySelector(".trix-button--icon-italic");
    // console.log(button_italic);
    // button_italic.innerHTML = `<i class="${fa_style} fa-italic"></i>`;

    // const button_underline = trix_toolbar.querySelector(".trix-button--icon-underline");
    // button_underline.innerHTML = `<i class="${fa_style} fa-underline"></i>`;
    
    
  }

  hideDescriptionForm() {
    if (this.hasDescriptionViewTarget && this.hasDescriptionFormTarget) {
      this.descriptionViewTarget.style.display = ""
      this.descriptionFormTarget.style.display = "none"
    }
  }

  create() {
    const categoryId = this.element.getAttribute('data-category-category-id-value');
    console.log(categoryId);
    const list = $(this.element).find('ul');
    console.log(list);
    const newTaskFrame = $('<turbo_frame>', {
      id: 'new_task'
    });
    list.prepend(newTaskFrame);
    let url = '/tasks/new';
    if ( categoryId ) {
      url += `?categoryId=${categoryId}`
    }
    fetch(url)
        .then((response) => response.text())
        .then((html) => {
          Turbo.renderStreamMessage(html);

          const observer = new MutationObserver((mutationsList) => {
            for (const mutation of mutationsList) {
              const frameContent = mutation.target;
              if (frameContent && frameContent.id === 'new_task') {
                // this.scrollToLastCard();
                // this.disableAnotherMenu(true);
                const closeButton = frameContent.querySelector('.remove-task');
                const nameInput = frameContent.querySelector('input#task_title');
                if (closeButton) {
                  nameInput.focus();
                  closeButton.addEventListener('click', () => {
                    frameContent.remove();

                  });
                  nameInput.addEventListener('keydown', (event) => {
                    if (event.key === 'Escape') {
                      frameContent.remove();
                    }
                  });
                }
              }
            }
          });

          observer.observe(document.getElementById('new_task'), { childList: true, subtree: true });
        });
  }

  show() {
    fetch(this.url, {
      headers: { Accept: 'text/vnd.turbo-stream.html' }
    })
        .then((response) => response.text())
        .then((html) => { Turbo.renderStreamMessage(html) })
        .catch((error) => {
          console.error('Error fetching task details:', error);
        });
    $('#task-panel-wrapper').css('right', 0);
  }

  close() {
    const wrapper = $('#task-panel-wrapper');
    wrapper.css('right', '-100%');
    $('#task-content').empty();
  }

  edit() {
    const editableElement = event.target;
    editableElement.contentEditable = true;
    editableElement.focus();
    let timeouts = [];

    $(editableElement).one('focusout', (event) => {
      timeouts.push(setTimeout(() => this.handleSubmit(event, editableElement, this.url, timeouts), 100));
    })
    $(editableElement).on('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault();
        timeouts.push(setTimeout(() => this.handleSubmit(event, editableElement, this.url, timeouts), 100));
      }
    });
  }

  handleSubmit(e, elem, url, timeouts) {
    this.saveChanges(e, elem, url);
    timeouts.forEach((timeout) => clearTimeout(timeout));
  }

  saveChanges(e, elem, url, timeouts) {
    console.log(elem);
    const newValue = elem.innerText;
    elem.contentEditable = false;
    $(elem).off('keydown')
    const field = elem.classList.value.split('-')[1];
    console.log(field);
    const data = {
      task:{
        [field]: newValue
      }
    }
    console.log(data);
    fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          Accept: 'text/vnd.turbo-stream.html'
        },
        body: JSON.stringify(data)
    })
        .then((response) => response.text())
        .then((html) => { Turbo.renderStreamMessage(html) })
        .catch((err) => console.error('Task update failed:', err));
  }

  get url() {
    return this.urlValue;
  }
}
