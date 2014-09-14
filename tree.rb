# Represents a tree data structure
class Tree
  attr_accessor :father, :children, :type

  def initialize type, father
    @children = []
	@type = type
    @father = father
  end

  # Adds a new child to the tree
  def add_child type
    c = Tree.new type, self
    @children << c
	c
  end

  # Makes a depth-first search in the tree, executing blocks
  def depth param, before, after
    before.call self, param
	
	@children.each do |child|
	  child.depth param, before, after
	end

    after.call self, param
  end

  def depth_print
    before = lambda { |tree, p| print '(', tree.type }
    after = lambda { |tree, p| print ')' }

	depth nil, before, after
  end

  def sentence
    before = lambda { |tree, p| p << tree.type if tree.children.empty? }
    after = lambda { |tree, p| p }

	depth [], before, after
  end

protected

  def build_sentence sentence
    sentence << type if @children.empty?

	@children.each do |child|
	  child.build_sentence sentence
	end

	sentence
  end
end
