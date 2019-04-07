require 'test_helper'
require_relative 'human_typo'

class HumanTypoTest < Minitest::Test
  def setup
    @input = 'spec/services/anything_spec'
    @sh = TreeSpell::HumanTypo.new(@input, lambda: 0.05)
    @len = @input.length
  end

  def test_changes
    # srand seed ensures all four actions are called
    srand 247_696_449
    sh = TreeSpell::HumanTypo.new(@input, lambda: 0.20)
    word_error = sh.call
    assert_equal word_error, 'spec/suervcieq/anythin_gpec'
  end

  def test_check_input
    assert_raises(StandardError) { TreeSpell::HumanTypo.new('tiny') }
  end
end
