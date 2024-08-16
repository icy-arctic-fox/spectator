module Spectator::Core
  alias Tag = String | Bool
  alias Tags = Hash(String, Tag)
  alias TagModifiers = Hash(String, Tag | Nil)

  module Taggable
    abstract def tags? : TagModifiers?

    def tags : Tags
      if parent_tags = parent.try &.tags
        Taggable.merge_tags(parent_tags, tags?)
      else
        Taggable.merge_tags(Tags.new, tags?)
      end
    end

    def skip?
      tags = self.tags
      tags["skip"]? || tags["pending"]?
    end

    def print_tags(io : IO) : Nil
      io << '{'
      tags.each_with_index do |(key, value), index|
        io << key << ": "
        value.inspect(io)
        io << ", " if index < tags.size - 1
      end
      io << '}'
    end

    def self.create_tags(names : Tuple, values : NamedTuple) : TagModifiers?
      return if names.empty? && values.empty?
      tags = TagModifiers.new
      names.each do |name|
        tags[name.to_s] = true
      end
      values.each do |key, value|
        tags[key.to_s] = value
      end
      tags
    end

    def self.create_and_merge_tags(
      tags_a : Tuple, tagged_values_a : NamedTuple,
      *tags_b, **tagged_values_b
    ) : TagModifiers?
      tags = create_tags(tags_b, tagged_values_b)
      return if tags.nil? && tags_a.empty? && tagged_values_a.empty?

      tags ||= TagModifiers.new
      tags_a.each do |name|
        key = name.to_s
        value = tags[key]?
        # Override non-strings with true.
        # Keep the existing value if it is a string.
        # Additionally, false is changed to true.
        unless value && value.is_a?(String)
          tags[key] = true
        end
      end

      # All existing tagged values are overridden
      tagged_values_a.each do |key, value|
        tags[key.to_s] = value
      end
      tags
    end

    def self.merge_tags(a : Tags, b : Tags | TagModifiers) : Tags
      b.each do |key, value|
        if value.nil?
          a.delete(key)
        else
          a[key] = value
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
