class AddPositionToModels < ActiveRecord::Migration[7.0]
  def up
    add_column :categories, :position,:integer,null: false, default: 1
    add_column :tasks, :position,:integer,null: false, default: 1
    # execute <<~SQL.squish
    #   alter table categories add constraint unique_dashboard_id_position unique (dashboard_id, position) deferrable initially deferred;
    # SQL
    # execute <<~SQL.squish
    #   alter table tasks add constraint unique_category_id_position unique (category_id, position, user_id) deferrable initially deferred;
    # SQL
  end

  def down
    # execute <<~SQL.squish
    #   alter table categories drop constraint unique_dashboard_id_position;
    #   alter table tasks drop constraint unique_category_id_position;
    # SQL
    remove_column :categories, :position, :integer, null: false, default: 1
    remove_column :tasks, :position, :integer, null: false, default: 1
  end
end
