class CalculosController < ApplicationController
  before_filter :load_professors
  require_role "admin", :except => ['relatorio_ficha']

  layout :define_layout

  def define_layout
      current_user.layout
  end

  def index
  end
  
  def calcula_pontuacao
      # se o método é get, o formulário ainda não foi enviado, mostramos o form vazio
    if request.get?
      @calculo = Calculo.new
    else
      # aqui recebemos o formulário por post, vamos criar o nosso objeto
      # usando os parâmetros vindos do formulário
      @calculo = Calculo.new( params['contact'] )
      # o método save (que foi sobreescrito) vai ativar a validação
      Professor.connection.execute("CALL calcula_pontuacao(" + ((@calculo.professor_id).to_s) + ")")
      @trabalho = Trabalhado.find_by_sql("SELECT * FROM trabalhados where professor_id = " + @calculo.professor_id.to_s + " and ano_letivo = " + $data.to_s)
      flash[:notice] = 'CALCULOS REALIZADOS PARA O PROFESSOR: ' + Professor.find(@calculo.professor_id).nome
      render :action => 'dias_calculados'
    end
  end

  def efetivar_iniciar_ano
    @inicia_ano = Professor.find(:all)
    for professor in @inicia_ano
      @acum_prof = AcumTrab.find_all_by_professor_id(professor.id)
      for acum_prof in @acum_prof
        @acum_prof2 = AcumTrab.find(acum_prof.id)
        @acum_prof2.verifica = 2
        @acum_prof2.status = 0
        @acum_prof2.save
      end
    end

    render :nothing => true
  end

  def iniciar_ano
  end


  def arrumar_titulos    
  end

  def efetiva_arrumar_titulos
    @id_professor = Professor.all
    for professor in @id_professor
      titulos_anuais = TituloProfessor.sum('pontuacao_titulo', :conditions => ["professor_id = " +(professor.id).to_s + " and (titulo_id = 6 or titulo_id = 7 or titulo_id = 8)"])
      @professor = Professor.find(professor.id)
      @professor.total_titulacao= @professor.total_titulacao - titulos_anuais
      @professor.save
    end
    render :action => 'arrumar_titulos'
  end

  def ficha_automatica    
  end

  def efetivar_ficha_automatica
    @professor= Professor.all
    for ficha in @professor
      @log = Log.new
      @log.log(current_user.id, ficha.id, "Criado a ficha de pontuacao via ficha automática para : #{ficha.id} - #{ficha.nome}")
      @log.save!

      @existe = Trabalhado.find_all_by_professor_id(ficha.id, :conditions => ['ano_letivo = ?',$data])
      @possui_ficha = Ficha.find_all_by_professor_id(ficha.id,:conditions =>['ano_letivo = ?',$data])
      @contagem_finalizada = AcumTrab.find_all_by_professor_id(ficha.id, :conditions => ['status = 1'])

      if @contagem_finalizada.present?
        if !@possui_ficha.present?
          if @existe.count == 2 then
            @fichas = Ficha.new
              @fichas.professor_id = ficha.id
              @acum_trab_ficha = AcumTrab.find_by_professor_id(ficha.id)
              @fichas.acum_trab_id = @acum_trab_ficha.id
              @fichas.tot_acum_ant_trab = @acum_trab_ficha.tot_acum_ant_trab
              @fichas.tot_acum_ant_efet = @acum_trab_ficha.tot_acum_ant_efet
              @fichas.tot_acum_ant_rede = @acum_trab_ficha.tot_acum_ant_rede
              @fichas.tot_acum_ant_unid = @acum_trab_ficha.tot_acum_ant_unid
              @fichas.tot_acum_trab = @acum_trab_ficha.tot_acum_trab
              @fichas.tot_acum_efet = @acum_trab_ficha.tot_acum_efet
              @fichas.tot_acum_rede = @acum_trab_ficha.tot_acum_rede
              @fichas.tot_acum_unid = @acum_trab_ficha.tot_acum_unid
              @fichas.tot_geral_trab = @acum_trab_ficha.tot_geral_trab
              @fichas.tot_geral_efet = @acum_trab_ficha.tot_geral_efet
              @fichas.tot_geral_rede = @acum_trab_ficha.tot_geral_rede
              @fichas.tot_geral_unid = @acum_trab_ficha.tot_geral_unid
              @fichas.valor_trab = @acum_trab_ficha.valor_trab
              @fichas.valor_efet = @acum_trab_ficha.valor_efet
              @fichas.valor_rede = @acum_trab_ficha.valor_rede
              @fichas.valor_unid = @acum_trab_ficha.valor_unid
              @fichas.trabalhado_anterior_id = Trabalhado.find_by_professor_id(ficha.id, :conditions => ['ano_letivo = ? and ano = ?',$data, (($data.to_i) -1).to_s]).id
              @fichas.trabalhado_atual_id = Trabalhado.find_by_professor_id(ficha.id, :conditions => ['ano_letivo = ? and ano = ?',$data, $data]).id
              @fichas.total_geral = Professor.find(ficha.id).pontuacao_final
              @fichas.total_titulacao = Professor.find(ficha.id).total_titulacao
              @fichas.total_trabalhado = Professor.find(ficha.id).total_trabalhado
              @fichas.ano_letivo = $data
            @fichas.save
          end
        end
      end
    end    
    @professor_com_ficha = Ficha.paginate(:all,:page=>params[:page],:per_page =>25,:conditions => ['ano_letivo = ?', $data])
    redirect_to(relatorio_ficha_path)

  end
  
  def relatorio_ficha

    if params[:search].blank?
      if current_user.regiao_id == 53 or current_user.regiao_id == 52 then
        @professor_com_ficha = Ficha.paginate(:all,:page=>params[:page],:per_page =>25,:conditions => ['ano_letivo = ?', $data])
      else
        @professor_com_ficha = Ficha.paginate(:all,:page=>params[:page],:per_page =>25,:conditions => ['ano_letivo = ? and (sede_id = ? or sede_id = 54)', $data, current_user.regiao_id])
      end
    else
      if current_user.regiao_id == 53 or current_user.regiao_id == 52 then
        @professor_com_ficha = Ficha.paginate(:all,:joins => :professor,:page=>params[:page],:per_page =>25,:conditions => ['ano_letivo = ? and professors.matricula = ?', $data,params[:search]])
      else
        @professor_com_ficha = Ficha.paginate(:all,:joins => :professor,:page=>params[:page],:per_page =>25,:conditions => ['ano_letivo = ? and (sede_id = ? or sede_id = 54)  and professors.matricula = ?', $data, current_user.regiao_id,params[:search]])
      end

    end
  end

  protected

  def load_professors
    @professors = Professor.find(:all, :order => "matricula")
    @professor = Professor.find(:all, :include => :fichas)
  end


end
