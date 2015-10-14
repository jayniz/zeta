guard :bundler do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard :rspec, cmd: 'rspec', all_on_start: true do
  watch(%r{^spec/.+$})  { "spec" }
  watch(%r{^lib/(.+)\.rb$})  { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
end
