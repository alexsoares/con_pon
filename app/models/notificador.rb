class Notificador < ActionMailer::Base
  def notificar(user)
    recipients user.email
    from  "no-reply@ribeirosoares.com"
    subject "Usuário Cadastrado com sucesso"
    body :user => user
  end

  def forgot_password(user)
		setup_email(user)
		@subject    += 'Você solicitou a mudança da sua senha'
		@body[:url]  = "http://localhost:3000/reset_password/#{user.password_reset_code}"
	end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "no-reply@ribeirosoares.com"
      @subject     = "Esqueceu sua senha "
      @sent_on     = Time.now
      @body[:user] = user
    end


end
