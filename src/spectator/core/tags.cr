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
  end
end
