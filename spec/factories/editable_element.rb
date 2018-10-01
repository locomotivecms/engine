# encoding: utf-8

FactoryBot.define do

  factory :editable_element, class: Locomotive::EditableText do
    slug { 'editable-element' }
    block { 'main' }
    hint { 'hint' }
    content { 'Lorem ipsum' }
    priority { 0 }
    disabled { false }
  end

end
