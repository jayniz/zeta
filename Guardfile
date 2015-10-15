guard :bundler do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard :rspec, cmd: 'TEST=1 rspec', all_on_start: true do
  watch(%r{^spec/.+\.rb$})  { "spec" }
  watch(%r{^lib/(.+)\.rb$})  { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
end
