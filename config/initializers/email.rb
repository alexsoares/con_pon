
require 'smtp_tls'
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.smtp_settings = {
   :address => "smtp.gmail.com",
   :port => 587,
   :authentication => :plain,
   :user_name => "no-reply@ribeirosoares.com", #Você pode usar o Google Apps!
   :password => 's3inf09'
}

