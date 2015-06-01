# Load the rails application
require File.expand_path('../application', __FILE__)
 
# Initialize the rails application
LibraryManager::Application.initialize!

#Please change '*' to your AWS key when you use search form.
Amazon::Ecs.options = { #api key .
  :associate_tag => '*',
  :AWS_access_key_id => '*',
  :AWS_secret_key => '*',
	:country => '*'
}
 
