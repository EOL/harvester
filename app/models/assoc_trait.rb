# An measurement formed by combining a "measurment or fact" with an "association"
class AssocTrait < ActiveRecord::Base
  belongs_to :resource, inverse_of: :assoc_traits
  belongs_to :harvest, inverse_of: :assoc_traits
  belongs_to :trait, inverse_of: :assoc_traits
  belongs_to :predicate_term, class_name: 'Term'
  belongs_to :object_term, class_name: 'Term'
  belongs_to :units_term, class_name: 'Term'
  belongs_to :statistical_method_term, class_name: 'Term'

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
