# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::NegatedWhile do
  subject(:cop) { described_class.new }

  it 'registers an offense for while with exclamation point condition' do
    inspect_source(cop,
                   ['while !a_condition',
                    '  some_method',
                    'end',
                    'some_method while !a_condition'
                   ])
    expect(cop.messages).to eq(
      ['Favor `until` over `while` for negative conditions.'] * 2)
  end

  it 'registers an offense for until with exclamation point condition' do
    inspect_source(cop,
                   ['until !a_condition',
                    '  some_method',
                    'end',
                    'some_method until !a_condition'
                   ])
    expect(cop.messages)
      .to eq(['Favor `while` over `until` for negative conditions.'] * 2)
  end

  it 'registers an offense for while with "not" condition' do
    inspect_source(cop,
                   ['while (not a_condition)',
                    '  some_method',
                    'end',
                    'some_method while not a_condition'])
    expect(cop.messages).to eq(
      ['Favor `until` over `while` for negative conditions.'] * 2)
    expect(cop.offenses.map(&:line)).to eq([1, 4])
  end

  it 'accepts an while where only part of the contition is negated' do
    inspect_source(cop,
                   ['while !a_condition && another_condition',
                    '  some_method',
                    'end',
                    'while not a_condition or another_condition',
                    '  some_method',
                    'end',
                    'some_method while not a_condition or other_cond'])
    expect(cop.messages).to be_empty
  end

  it 'autocorrects by replacing while not with until' do
    corrected = autocorrect_source(cop, 'something while !x.even?')
    expect(corrected).to eq 'something until x.even?'
  end

  it 'autocorrects by replacing until not with while' do
    corrected = autocorrect_source(cop, 'something until !x.even?')
    expect(corrected).to eq 'something while x.even?'
  end
end
