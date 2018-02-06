require File.join(File.dirname(__FILE__), '..', 'context.rb')

token_test('simple variable declaration', [
  'ほげは42',
  '[{:type=>:variable_assignment, :variable_name=>"ほげ", :value=>"42"}]'
])

token_test('variable declaration with spacing', [
  'ほげ は 42',
  '[{:type=>:variable_assignment, :variable_name=>"ほげ", :value=>"42"}]'
])

token_test('variable declaration with string', [
  'ほげは「ふが」',
  '[{:type=>:variable_assignment, :variable_name=>"ほげ", :value=>"「ふが」"}]'
])

token_test('assignment using existing variable', [
  'ほげは42',
  '[{:type=>:variable_assignment, :variable_name=>"ほげ", :value=>"42"}]'
], [
  'ふがはほげ',
  '[{:type=>:variable_assignment, :variable_name=>"ふが", :value=>"ほげ"}]'
])

token_test('resolve ambiguous assignment', [
  'はは42',
  '[{:type=>:variable_assignment, :variable_name=>"は", :value=>"42"}]'
], [
  'ははははははは',
  '[{:type=>:variable_assignment, :variable_name=>"ははははは", :value=>"は"}]'
])

token_test('assignment using undefined variable', [
  'ほげはふが',
  '[{:type=>:misc, :token=>"ほげはふが"}]'
])

token_test('assignment using undefined variable (exact format)', [
  'ほげ は ふが',
  'undefined variable: ふが'
])
