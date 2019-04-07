module DidYouMean
  # spell checker for a dictionary that has a tree structure
  class TreeSpellChecker
    attr_reader :dictionary, :all_states, :separator, :augment

    # The dictionary is a list of possible words that
    # match a misspelling. The dictionary should be
    # tree structured with a single character separator
    # e.g 'spec/models/goals_spec_rb'. The separator
    # cannot be alphabetical, '@' or '.'.
    def initialize(dictionary:, separator: '/', augment: nil)
      @dictionary = dictionary
      @separator = separator
      @augment = augment
      @all_states = parse_dimensions
    end

    def correct(input)
      states = plausible_states input
      return no_idea(input) if states.empty?
      suggestions = find_suggestions input, states
      return no_idea(input) if suggestions.empty?
      suggestions
    end

    private

    def find_suggestions(input, states)
      nodes = states[0].product(*states[1..-1])
      paths = possible_paths nodes
      leaf = input.split(separator).last
      ideas = find_ideas(paths, leaf)
      ideas.compact.flatten
    end

    def no_idea(input)
      return [] unless augment
      ::DidYouMean::SpellChecker.new(dictionary: dictionary).correct(input)
    end

    def find_ideas(paths, leaf)
      paths.map do |path|
        names = find_leaves(path)
        ideas = CorrectElement.new.call names, leaf
        if ideas.empty?
          nil
        elsif names.include? leaf
          [path + separator + leaf]
        else
          ideas.map { |str| path + separator + str }
        end
      end
    end

    def find_leaves(path)
      dictionary.map do |str|
        next unless str.include? "#{path}#{separator}"
        str.gsub("#{path}#{separator}", '')
      end.compact
    end

    def possible_paths(nodes)
      nodes.map do |node|
        node.join separator
      end
    end

    def plausible_states(input)
      elements = input.split(separator)[0..-2]
      elements.each_with_index.map do |element, i|
        next if all_states[i].nil?
        CorrectElement.new.call all_states[i], element
      end.compact
    end

    def parse_dimensions
      leafless = remove_leaves      
      elements_a = find_elements leafless
      elements_a.map do |elements|
        elements.to_set.to_a
      end
    end

    def remove_leaves
      dictionary.map do |a|
        elements = a.split(separator)
        elements[0..-2]
      end.to_set.to_a
    end

    def find_elements(leafless)
      max_elements = leafless.map(&:size).max
      elements_a = Array.new(max_elements) { [] }
      (0...max_elements).each do |i|
        leafless.each do |elements|
          elements_a[i] << elements[i] unless elements[i].nil?
        end
      end
      elements_a
    end
  end

  class CorrectElement
    def initialize
    end

    def call(names, element)
      return names if names.size == 1
      str = normalize element
      return [str] if names.include? str
      checker = ::DidYouMean::SpellChecker.new(dictionary: names)
      checker.correct(str)
    end

    private

    def normalize(leaf)
      str = leaf.dup
      str.downcase!
      return str unless str.include? '@'
      str.tr!('@', '  ')
    end
  end
end
