# typed: strict
# frozen_string_literal: true

class Object
  #: -> bool
  def blank?
    false
  end
end

class NilClass
  #: -> bool
  def blank?
    true
  end
end

class String
  #: -> bool
  def blank?
    strip.empty?
  end
end
