import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import csrfToken from '../scripts/csrfToken';

export default class extends Controller {
  static targets = ["categories", "tasks"];

  connect() {
    this.tasksTargets.forEach((e) => {
      const taskSortable = Sortable.create(e, {
        group: 'tasks',
        handle: '.task-handle',
        swapThreshold: 1,
        animation: 150,
        onEnd: function(evt) {
          const { newIndex, oldIndex, from, to } = evt;

          if ( from === to && newIndex === oldIndex ) { return false }

          const data = {
            new_position: newIndex + 1,
            old_position: oldIndex + 1,
            from: from.dataset.categoryId,
            to: to.dataset.categoryId
          }

          fetch('/dashboards/tasks_reorder', {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': csrfToken,
              Accept: "text/vnd.turbo-stream.html"
            },
            body: JSON.stringify(data)
          });
        }
      });
    });

    this.categoriesTargets.forEach((e) => {
      const categorySortable = Sortable.create(e, {
        group: 'categories',
        filter: '.no-drug',
        swapThreshold: 1,
        animation: 150,
        onEnd: function(evt) {
          const { newIndex, oldIndex } = evt;

          if ( newIndex === oldIndex ) { return false }

          const data = {
            new_position: newIndex + 1,
            old_position: oldIndex + 1
          }

          fetch('/dashboards/categories_reorder', {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': csrfToken,
              Accept: "text/vnd.turbo-stream.html"
            },
            body: JSON.stringify(data)
          });
        }
      });
    });
  }
}
