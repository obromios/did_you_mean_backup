# spell checker for a dictionary that has a tree structure
class TreeSpellChecker
  attr_reader :dictionary, :all_states, :separator

  def initialize(dictionary:, separator: '/')
    @dictionary = dictionary
    @separator = separator
    @all_states = parse
  end

  def correct(input)
    states = plausible_states input
    return [] if states.empty?
    nodes = states[0].product(*states[1..-1])
    paths = possible_paths nodes
    suffix = input.split(separator).last
    ideas = find_ideas(paths, suffix)
    ideas.compact.flatten
  end

  private

  def find_ideas(paths, suffix)
    paths.map do |path|
      names = base_names(path)
      ideas = check_names names, suffix
      if ideas.empty?
        nil
      elsif names.include? suffix
        [path + separator + suffix]
      else
        ideas.map { |str| path + separator + str }
      end
    end
  end

  def check_names(names, suffix)
    if names.include? suffix
      suffix
    else
      checker = ::DidYouMean::SpellChecker.new(dictionary: names)
      checker.correct(suffix)
    end
  end

  def base_names(node)
    dictionary.map do |str|
      str.gsub("#{node}#{separator}", '') if str.include? "#{node}/"
    end.compact
  end

  def possible_paths(nodes)
    nodes.map do |node|
      node.join separator
    end
  end

  def plausible_states(input)
    elements = input.split(separator)[0..-2]
    elements.each_with_index.map do |str, i|
      next if all_states[i].nil?
      if all_states[i].include? str
        [str]
      else
        checker = ::DidYouMean::SpellChecker.new(dictionary: all_states[i])
        checker.correct(str)
      end
    end.compact
  end

  def parse
    parts_a = dictionary.map do |a|
      parts = a.split(separator)
      parts[0..-2]
    end.to_set.to_a
    max_parts = parts_a.map { |parts| parts.size }.max
    nodes =Array.new(max_parts){[]}
    (0...max_parts).each do |i|
      parts_a.each do |parts|
        nodes[i] << parts[i] unless parts[i].nil?
      end
    end
    nodes.map do |node|
      node.to_set.to_a
    end
  end
end