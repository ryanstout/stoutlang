require 'spec_helper'

describe StoutLangParser do

  describe "effects" do
    it 'should track effect types through method calls and defs' do
      code = <<-CODE
      struct Test {
        def say_hi(name: Str) { PrintIO.emit() }
      }
      CODE

      ast = Parser.new.parse(code)

      def_node = ast.block.expressions[0].block.expressions[0]
      def_node.prepare

      expect(def_node.effects).to eq([Type.new(name='PrintIO')])
    end

    it 'should track nested effect types through calls and defs' do
      code = <<-CODE
      struct Test {
        def say_hi(name: Str) {
          PrintAction.emit()
        }

        def save(name: Str) {
          say_hi(name)
          SaveAction.emit()
        }
      }
      CODE

      ast = Parser.new.parse(code)

      hi_node = ast.block.expressions[0].block.expressions[0]
      save_node = ast.block.expressions[0].block.expressions[1]
      ast.prepare

      expect(save_node.effects).to eq([Type.new(name="PrintAction"), Type.new(name="SaveAction")])
    end

    it 'should track nested effect types through calls and defs2' do
      code = <<-CODE
      struct Ok {
        def initialize(name: Str) {
          # some comment

        }

        def load_something() {
          FileReadAction.emit()
        }

        def log(str: Str) {
          print(str)
        }

        def print(str: Str) {
          PrintAction.emit()
        }

        def load_and_print(str: Str) {
          log(str)
          load_something()
        }
      }
      CODE
      ast = Parser.new.parse(code)

      load_and_print_node = ast.block.expressions[0].block.expressions[4]
      ast.prepare

      expect(load_and_print_node.effects).to eq([Type.new(name='PrintAction'), Type.new(name='FileReadAction')])
    end
  end
end
