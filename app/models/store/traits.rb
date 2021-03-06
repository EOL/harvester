module Store
  module Traits
    # NOTE: this is unused. ...I'm actually just keeping it here for reference ...and future use!
    @header_to_uri = {
      'Measurement ID' => 'http://rs.tdwg.org/dwc/terms/measurementID',
      'Occurrence ID' => 'http://rs.tdwg.org/dwc/terms/occurrenceID',
      'MeasurementOfTaxon' => 'http://eol.org/schema/measurementOfTaxon',
      'Association ID' => 'http://eol.org/schema/associationID',
      'Parent Measurement ID' => 'http://eol.org/schema/parentMeasurementID',
      'Measurement Type' => 'http://rs.tdwg.org/dwc/terms/measurementType',
      'Measurement Value' => 'http://rs.tdwg.org/dwc/terms/measurementValue',
      'Unit' => 'http://rs.tdwg.org/dwc/terms/measurementUnit',
      'Accuracy' => 'http://rs.tdwg.org/dwc/terms/measurementAccuracy',
      'Statistical Method' => 'http://eol.org/schema/terms/statisticalMethod',
      'Determined Date' => 'http://rs.tdwg.org/dwc/terms/measurementDeterminedDate',
      'Determined By' => 'http://rs.tdwg.org/dwc/terms/measurementDeterminedBy',
      'Measurement Method' => 'http://rs.tdwg.org/dwc/terms/measurementMethod',
      'Remarks' => 'http://rs.tdwg.org/dwc/terms/measurementRemarks',
      'Source' => 'http://purl.org/dc/terms/source',
      'Citation' => 'http://purl.org/dc/terms/bibliographicCitation',
      'Contributor' => 'http://purl.org/dc/terms/contributor'
    }
    def to_traits_pk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:resource_pk] = val
    end

    def to_traits_occurrence_fk(field, val)
      @models[:trait] ||= {}
      if @models[:trait][:parent_pk] # Not allowed! Ignore it.
        @process.debug('SKIPPING occurrence FK. Not allowed; parent_pk present!') if field.debugging
        return
      end
      @models[:trait][:occurrence_resource_pk] = val
    end

    def to_traits_measurement_of_taxon(_, val)
      @models[:trait][:of_taxon] = looks_true?(val)
    end

    def to_traits_parent_pk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:occurrence_resource_pk] = nil # Not allowed!
      @models[:trait][:parent_pk] = val
    end

    def to_traits_parent_eol_pk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:occurrence_resource_pk] = nil # Not allowed!
      @models[:trait][:parent_eol_pk] = val
    end

    def to_traits_predicate(_, val)
      @models[:trait] ||= {}
      @models[:trait][:predicate] = val
    end

    def to_traits_value(_, val)
      @models[:trait] ||= {}
      @models[:trait][:value] = val
    end

    def to_traits_units(_, val)
      @models[:trait] ||= {}
      @models[:trait][:units] = val
    end

    def to_traits_contributor(_, val)
      @models[:trait] ||= {}
      @models[:trait][:contributor] = val
    end

    def to_traits_determined_by(_, val)
      @models[:trait] ||= {}
      @models[:trait][:determined_by] = val
    end

    def to_traits_compiler(_, val)
      @models[:trait] ||= {}
      @models[:trait][:compiler] = val
    end

    def to_traits_statistical_method(_, val)
      @models[:trait] ||= {}
      @models[:trait][:statistical_method] = val
    end

    def to_traits_source(_, val)
      @models[:trait] ||= {}
      @models[:trait][:source] = val
    end

    def to_traits_ref_fks(field, val)
      @models[:trait] ||= {}
      @models[:trait][:ref_sep] ||= field.submapping
      @process.debug("Set ref_sep to #{field.submapping}") if field.debugging
      @models[:trait][:ref_fks] = val
    end

    def to_traits_assoc_node_fk(_, val)
      @models[:trait] ||= {}
      @models[:trait][:assoc_resource_pk] = val
    end

    def to_traits_meta(field, val)
      @models[:trait] ||= {}
      @models[:trait][:meta] ||= {}
      @process.debug("Set meta #{field.submapping}.") if field.debugging
      @models[:trait][:meta][field.submapping] = val
    end
  end
end
