# https://techlife.cookpad.com/entry/a-guide-to-monkey-patchers
Dir[Rails.root.join('lib/monkey_patches/**/*.rb')].sort.each do |file|
  require file
end