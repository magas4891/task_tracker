import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import csrfToken from "../scripts/csrfToken";

// Connects to data-controller="task"
export default class extends Controller {
  static values = { url: String }

  connect() {
  }

  create() {
    const categoryId = this.element.getAttribute('data-category-category-id-value');
    const list = $(this.element).find('ul');
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
    $('#task-content').css('right', 0);
  }

  close() {
    const taskContent= $('#task-content');
    taskContent.css('right', '-100%');
    taskContent.empty();
  }

  get url() {
    return this.urlValue;
  }
}
