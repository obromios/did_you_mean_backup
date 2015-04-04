require_relative 'test_helper'

class SimilarMethodFinderTest < Minitest::Test
  class User
    def friends; end
    def first_name; end
    def descendants; end

    protected
    def the_protected_method; end

    private
    def friend; end
    def the_private_method; end

    class << self
      def load; end
    end
  end

  module UserModule
    def from_module; end
  end

  def setup
    user = User.new.extend(UserModule)

    @error_from_instance_method = assert_raises(NoMethodError){ user.flrst_name }
    @error_from_private_method  = assert_raises(NoMethodError){ user.friend }
    @error_from_module_method   = assert_raises(NoMethodError){ user.fr0m_module }
    @error_from_class_method    = assert_raises(NoMethodError){ User.l0ad }
  end

  def test_similar_words
    assert_suggestion "first_name",  @error_from_instance_method.suggestions
    assert_suggestion "friends",     @error_from_private_method.suggestions
    assert_suggestion "from_module", @error_from_module_method.suggestions
    assert_suggestion "load",        @error_from_class_method.suggestions
  end

  def test_did_you_mean?
    assert_match "Did you mean? #first_name",  @error_from_instance_method.did_you_mean?
    assert_match "Did you mean? #friends",     @error_from_private_method.did_you_mean?
    assert_match "Did you mean? #from_module", @error_from_module_method.did_you_mean?
    assert_match "Did you mean? #load",        @error_from_class_method.did_you_mean?
  end

  def test_similar_words_for_long_method_name
    error = assert_raises(NoMethodError){ User.new.dependents }
    assert_suggestion "descendants", error.suggestions
  end

  def test_private_methods_should_not_be_suggested
    error = assert_raises(NoMethodError){ User.new.the_protected_method }
    refute_includes error.suggestions, 'the_protected_method'

    error = assert_raises(NoMethodError){ User.new.the_private_method }
    refute_includes error.suggestions, 'the_private_method'
  end

  def test_corrects_incorrect_ivar_name
    skip if RUBY_ENGINE == 'rbx'

    @number = 1
    error = assert_raises(NoMethodError) { @nubmer.zero? }

    assert_suggestion "number", error.suggestions
    assert_match "Did you mean? @number", error.did_you_mean?
  end
end
