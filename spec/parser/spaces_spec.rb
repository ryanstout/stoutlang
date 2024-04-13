require 'spec_helper'

describe StoutLangParser do
  describe "spaces" do
    it 'should match spaces and line breaks' do
      ast = Parser.new.parse(" \n", wrap_root: false)
    end

    it 'should match only spaces on space rule' do
      ast = Parser.new.parse(" ", rule: 'space', wrap_root: false)
    end

    it 'should match spaces or line breaks, or spaces and line breaks on the spbr rule' do
      ast = Parser.new.parse(" \n ", rule: 'spbr', wrap_root: false)
    end
  end
end
