import { Controller } from '@hotwired/stimulus';
import $ from 'jquery';

// Connects to data-controller="selects"
export default class extends Controller {
  connect() {
    document.addEventListener('turbo:frame-load', () => {
      const select = $('#task_category_id');
      if (select.length > 0) {
        select.select2({
          tags: true,
          createTag: function (params) {
            var term = $.trim(params.term);

            if (term === '') { return null; }

            return {
              id: term,
              text: term,
              newTag: true
            }
          }
        });
      }
    });
    $(document).on('select2:select', '#task_category_id', function(e) {
      const tag_params = e.params.data;

      if (tag_params['newTag'] === true) {
        const submitBtn = $('input[type="submit"]')[0];
        const select = $('#task_category_id');
        const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
        const data = {
          name: tag_params['text'],
          newTag: true
        }

        submitBtn.disabled = true;

        fetch('/categories', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify(data)
        })
            .then(response => { return response.json(); })
            .then(data => {
              const newId = data['new_category']['id'];
              const option = select.find('option').filter( function () {
                return $(this).val() === data['new_category']['name'];
              });
              option.val(newId);
            })
            .catch(error => {
              console.error('Error:', error);

            });
        select.val(null).trigger('change');
        submitBtn.disabled = false;
      }
    });
  }
}
