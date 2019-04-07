require 'test_helper'
require_relative 'human_typo'

class HumanTypoTest < Minitest::Test
  def setup
    @input = 'spec/services/anything_spec'
    @sh = TreeSpell::HumanTypo.new(@input)
    @len = @input.length
  end

  def test_for_change
    refute_match @sh.call, @input
  end

  def test_check_input
    assert_raises(StandardError) { TreeSpell::HumanTypo.new('tiny') }
  end
end

