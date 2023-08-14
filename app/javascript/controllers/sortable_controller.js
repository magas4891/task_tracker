import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["categories", "tasks"];

  connect() {
    console.log("112345777");
    this.tasksTargets.forEach((e) => {
      var taskSortable = Sortable.create(e, {
        group: 'tasks',
        handle: '.task-handle'
      });
    });

    this.categoriesTargets.forEach((e) => {
      var categorySortable = Sortable.create(e, {
        group: 'categories',
        handle: '.category-handle'
      });
    });
  }
}
