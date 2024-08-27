module Spectator::Core
  alias Tags = Hash(String, String)
  alias TagModifiers = Hash(String, String?)

  module Taggable
    abstract def tags : TagModifiers?

    def all_tags : Tags
      if parent_tags = parent.try &.all_tags
        Taggable.merge_tags(parent_tags, tags)
      else
        Taggable.merge_tags(Tags.new, tags)
      end
    end

    def skip?
      tags = self.all_tags
      tags["skip"]? || tags["pending"]?
    end

    def print_tags(io : IO) : Nil
      io << '{'
      all_tags.each_with_index do |(key, value), index|
        io << key << ": "
        value.inspect(io)
        io << ", " if index < all_tags.size - 1
      end
      io << '}'
    end

    def self.create_tags(tags : Tuple, tagged_values : NamedTuple) : TagModifiers?
      return if tags.empty? && tagged_values.empty?
      apply_tag_modifiers(TagModifiers.new, tags, tagged_values)
    end

    def self.create_and_merge_tags(
      tags_a : Tuple, tagged_values_a : NamedTuple,
      *tags_b, **tagged_values_b
    ) : TagModifiers?
      tags = create_tags(tags_b, tagged_values_b)
      return if tags.nil? && tags_a.empty? && tagged_values_a.empty?
      apply_tag_modifiers(tags || TagModifiers.new, tags_a, tagged_values_a)
    end

    private def self.apply_tag_modifiers(hash, tags : Tuple, tagged_values : NamedTuple)
      tags.each do |name|
        key = name.to_s
        # Prevent overwriting existing tag values.
        hash[key] = key unless hash.has_key?(key)
      end

      tagged_values.each do |key, value|
        key = key.to_s
        hash[key] = value ? value.to_s : nil
      end
      hash
    end

    def self.merge_tags(a : Tags, b : Tags | TagModifiers) : Tags
      b.each do |key, value|
        if value
          a[key] = value
        else
          a.delete(key)
        end
      end
      a
    end

    def self.merge_tags(a : Nil, b : Tags | TagModifiers) : Tags
      merge_tags(Tags.new, b)
    end

    def self.merge_tags(a : Tags, b : Nil) : Tags
      a
    end

    def self.merge_tags(a : Nil, b : Nil) : Nil
    end
  end
end
