# Represents a tree data structure
class Tree
  attr_accessor :father, :children, :type

  def initialize type, father = nil
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
  def depth param, before, after, iteration = nil
    before.call self, param

    @children.each_with_index do |child, index|
      p_aux = param
      param = iteration.call(param, index) unless iteration.nil?
      child.depth param, before, after, iteration
      param = p_aux
    end

    after.call self, param
  end

  def show
    before = lambda { |tree, p| print '(', tree.type }
    after = lambda { |tree, p| print ')' }

    depth nil, before, after
  end

  def copy
    tree = self

    path = path_from_root
    tree = tree.root

    before = lambda { |t, cp| t.children.each { |c| cp.add_child c.type } }
    iteration = lambda { |cp, index| cp.children[index] }
    after = lambda { |t, cp| }
    
    new_copy = Tree.new tree.type
    tree.depth new_copy, before, after, iteration
    new_copy = new_copy.walk path

    return new_copy
  end

  # Gets the sentence associated with the leaves of the tree
  def sentence
    before = lambda { |tree, p| p << tree.type if tree.children.empty? }
    after = lambda { |tree, p| p }

    depth [], before, after
  end

  # Gets the tree's root
  def root
    tree = self
    tree = tree.father until tree.father.nil?
    tree
  end

  # Find the path to this node from the root, and returns as a list of
  # the children indices
  def path_from_root
    path = []
    tree = self

    until tree.father.nil?
      tree.father.children.each_with_index do |c, i|
        if c.object_id == tree.object_id
          path << i
          tree = tree.father
          break
        end
      end
    end

    return path.reverse
  end

  # Walks a path in the tree, returning the final node
  def walk path
    tree = self

    path.each do |index|
      break if tree.children.empty?
      tree = tree.children[index]
    end

    return tree
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
