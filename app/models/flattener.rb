class Flattener
  attr_reader :ancestry

  def self.flatten(resource, process)
    flattener = self.new(resource, process)
    flattener.flatten
  end

  def initialize(resource, process)
    @resource = resource
    @process = process
  end

  def flatten
    @process.run_step('Flattener#flatten') do
      study_resource
      if @children.empty?
        @process.warn('Flattener: no children found, aborting flatten')
        return nil
      end
      @process.run_step('Flattener#build_ancestry') { build_ancestry }
      count = build_node_ancestors
      if count.zero?
        @process.warn('Flattener: nothing to flatten! (Completely flat resource?)')
      else
        @process.run_step('Flattener#propagate_ancestor_ids') { propagate_ancestor_ids }
      end
    end
  end

  private

  def study_resource
    @process.starting('Flattener#study_resource')
    @children = {}
    Node.where(resource_id: @resource.id).harvested.pluck_in_batches(:id, :parent_id) do |batch|
      batch.each do |row|
        entry = row.first
        parent = row.last
        @children[parent] ||= []
        @children[parent] << entry
      end
    end
  end

  def build_ancestry
    @ancestry = {}
    @time = Time.now
    @process.enter_group do |harv_proc|
      @harv_proc = harv_proc
      walk_down_tree(nil, [])
    end
    @time = nil
  end

  def walk_down_tree(id, ancestors)
    return unless @children.has_key?(id)
    ancestors_here = ancestors.dup
    ancestors_here << id
    @children[id].each do |child_id|
      @ancestry[child_id] = ancestors_here
      if (@ancestry.keys.size % 10_000).zero?
        @harv_proc.update_group(@ancestry.keys.size, Time.now - @time)
        @time = Time.now
      end
      # @process.info("ancestry now has #{}") if (@ancestry.keys.size % 10_000).zero?
      walk_down_tree(child_id, ancestors_here)
    end
  end

  def build_node_ancestors
    @process.info("#{@ancestry.keys.size} ancestry keys")
    count = 0
    @process.run_step(:build_node_ancestors) do
      remove_ancestors_natively(@resource.id)
      @process.info('old ancestors deleted.')
      @node_ancestors = []
      ancestry_size = @ancestry.keys.size
      ancestry_index = 0
      time = Time.now
      @process.enter_group(ancestry_size) do |harv_proc|
        @ancestry.each_key do |child|
          ancestry_index += 1
          @ancestry[child].each_with_index do |ancestor, depth|
            next if ancestor.nil? # No need to store this one.
            @node_ancestors <<
              NodeAncestor.new(node_id: child, ancestor_id: ancestor, resource_id: @resource.id, depth: depth)
            next if @node_ancestors.size < 100_000
            count += update_tables
            harv_proc.update_group(ancestry_index, Time.now - time)
            time = Time.now
            @node_ancestors = []
          end
        end
      end
    end
    count += update_tables
  end

  def remove_ancestors_natively(resource_id)
    NodeAncestor.connection.execute("DELETE FROM node_ancestors WHERE resource_id = #{resource_id}")
  end

  def update_tables
    # TODO: error-handling
    if @node_ancestors.any?
      NodeAncestor.import! @node_ancestors
    end
    @node_ancestors.size
  end

  def propagate_ancestor_ids
    NodeAncestor.propagate_id(fk: 'ancestor_id', other: 'nodes.id', set: 'ancestor_fk', with: 'resource_pk',
                              resource_id: @resource.id)
  end
end
