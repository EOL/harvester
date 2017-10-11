class Node < ActiveRecord::Base
  searchkick

  belongs_to :resource, inverse_of: :nodes
  belongs_to :harvest, inverse_of: :nodes
  belongs_to :scientific_name, inverse_of: :nodes

  has_many :scientific_names, inverse_of: :node, dependent: :destroy
  has_many :media, inverse_of: :node, dependent: :destroy
  has_many :vernaculars, inverse_of: :node, dependent: :destroy
  has_many :occurrences, inverse_of: :node
  has_many :traits, inverse_of: :node
  has_many :identifiers, inverse_of: :node

  scope :root, -> { where('parent_id IS NULL') }
  scope :published, -> { where(removed_by_harvest_id: nil) }

  # NOTE: special scope used by Searchkick
  scope :search_import, -> { where('page_id IS NOT NULL').includes(:parent, :scientific_name, :scientific_names, :children) }

  acts_as_nested_set scope: :resource_id, dependent: :nullify

  # NOTE: special method used by Searchkick
  def search_data
    {
      id: id,
      resource_id: resource_id,
      page_id: page_id,
      authors: authors,
      synonyms: scientific_names.map(&:canonical),
      synonym_authors: all_authors,
      canonical: canonical,
      ancestor_page_ids: ancestors.map(&:page_id).compact,
      children: child_names,
      is_hybrid: scientific_name.try(:hybrid?),
      is_virus: scientific_name.try(:virus?),
      is_surrogate: scientific_name.try(:surrogate?)
    }
  end

  def self.native_virus
    @native_virus ||= where(resource_id: 1, canonical: 'Viruses') # Or we could look for page_id: 5006 ... but hey.
  end

  def authors
    scientific_name.authors if scientific_name && scientific_name.is_used_for_merges?
  end

  def all_authors
    scientific_names.used_for_merges.flat_map(&:authors) if scientific_names
  end

  def needs_to_be_mapped?
    return true if page_id.blank?
    return true if in_unmapped_area?
    # TODO: This won't actually happen; add these cases natively to the harvester (set the page_id to nil).
    # TODO: Think about what would happen if DWH changed Animalia and was reharvested. Does EVERYTHING get re-matched?
    return true if scientific_name.changed?
  end

  def child_names
    children.map(&:canonical)
  end

  def map_to_page(page_id)
    puts "@@ Yay! we matched node #{id} to page #{page_id}."
    update_attribute(:page_id, page_id)
  end

  def create_new_page(page_id)
    puts "VV BOO! We couldn't match node #{id}, so we're making a new page #{page_id}"
    update_attributes(page_id: page_id, in_unmapped_area: true)
  end

  def name # NOTE: just shorthand for common way of representing objects. Like #to_s...
    canonical
  end
end
