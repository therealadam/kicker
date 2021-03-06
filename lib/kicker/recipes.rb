RECIPES_DIR      = File.expand_path('../recipes', __FILE__)
USER_RECIPES_DIR = File.expand_path('~/.kick')

$:.unshift(RECIPES_DIR)
$:.unshift(USER_RECIPES_DIR) if File.exist?(USER_RECIPES_DIR)

module Kernel
  def recipe(name, &block)
    Kicker::Recipes.recipe(name, &block)
  end
end

class Kicker
  module Recipes
    class << self
      def recipes
        @recipes ||= {}
      end
      
      def recipe(name, &block)
        name = name.to_sym
        if block_given?
          recipes[name] = block
        else
          if recipe = recipes[name]
            recipe.call
          else
            raise LoadError, "Recipe `#{name}' does not exist."
          end
        end
      end
      
      def recipe_files
        Dir.glob(File.join(RECIPES_DIR, '*.rb')) + Dir.glob(File.join(USER_RECIPES_DIR, '*.rb'))
      end
    end
    
    # We don't want this option to show up at the end
    require 'execute_cli_command'
    recipe_files.each { |file| require file }
  end
end