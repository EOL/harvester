module Store
  module Nodes
    def to_nodes_pk(field, val)
      @models[:node] ||= {}
      @models[:node][:resource_pk] = val
    end

    def to_nodes_page_id(field, val)
      @models[:node] ||= {}
      @models[:node][:page_id] = val
      # TODO: we shouldn't trust this unless it came from Resource #1; add some code in the names-matcher to check.
    end

    def to_nodes_landmark(field, val)
      @models[:node] ||= {}
      @models[:node][:landmark] = Node.landmarks.keys[val.to_i] # TODO: this is not working. Take what they give us.
    end

    def to_nodes_scientific(field, val)
      @models[:node] ||= {}
      @models[:scientific_name] ||= {}
      name = val =~ /^".*"$/ ? val.sub(/^"/, '').sub(/"$/, '') : val
      @models[:scientific_name][:verbatim] = name
    end

    def to_nodes_parent_fk(field, val)
      @models[:node] ||= {}
      # It seems the intent of a '0' in this column really is a blank, since there are no IDs that match '0' in these
      # resources.
      val = nil if val == '0'
      @models[:node][:parent_resource_pk] = val
    end

    def to_nodes_ancestor(field, val)
      @models[:ancestors] ||= {}
      @models[:ancestors][field.submapping] = val
    end

    def to_nodes_rank(field, val)
      @models[:node] ||= {}
      @models[:node][:rank_verbatim] = val
    end

    def to_nodes_further_information_url(field, val)
      @models[:node] ||= {}
      @models[:node][:further_information_url] = val
    end

    def to_nodes_dataset_id(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:dataset_id] = val
    end

    def to_taxonomic_status(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:taxonomic_status_verbatim] = val
    end

    def to_nodes_ref_fks(field, val)
      @models[:node] ||= {}
      @models[:node][:ref_sep] ||= field.submapping
      @models[:node][:ref_fks] = val
    end

    def to_nodes_accepted_name_fk(field, val)
      # TODO: What we really want to do here is, if there is a value here, move all of the fields from the node to the
      # scientific name, but that's hairy and I don't want to do it right now. Soon.
      @models[:scientific_name] ||= {}
      if accepted_name_is_synonym?(val)
        # NOTE: no, we cannot create a synonym object here, because there may be other methods invoked that will add to
        # the scientific name, and I don't want to write branching code in every one of them. This will be handled by
        # the model builder:
        @models[:scientific_name][:synonym_of] = val
      else
        # Really, nothing to do. It's a normal row, treat it normally.
      end
    end

    # KS: "Note that a few data sets have acceptedNameUsageID values also for preferred names, in those cases
    # acceptedNameUsageID=taxonID for preferred names and acceptedNameUsageID≠taxonID for non-preferred names"
    def accepted_name_is_synonym?(val)
      @models[:node] && @models[:node][:resource_pk] && @models[:node][:resource_pk] != val
    end

    def to_nodes_remarks(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:remarks] = val
    end

    def to_nodes_publication(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:publication] = val
    end

    def to_nodes_source_ref_fk(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:ref_fk] = val
    end

    def to_nodes_identifiers(field, val)
      @models[:identifiers] ||= []
      @models[:identifiers] += val.split(/,\s*/)
    end

    def to_nodes_dataset_name(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:dataset_name] = val
    end

    def to_nodes_name_according_to(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:name_according_to] = val
    end
  end
end
